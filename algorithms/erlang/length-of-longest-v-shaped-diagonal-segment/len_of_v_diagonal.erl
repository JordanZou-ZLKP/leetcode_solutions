-spec len_of_v_diagonal(Grid :: [[integer()]]) -> integer().
-define(DIRS, {{1, 1}, {1, -1}, {-1, -1}, {-1, 1}}).

len_of_v_diagonal(Grid) ->
    Rows = length(Grid),
    Cols = length(hd(Grid)),
    
    %% 1. 数据结构优化：List -> Tuple，实现 O(1) 随机访问
    %% GridT[Row][Col] (1-based index)
    GridT = list_to_tuple([list_to_tuple(Row) || Row <- Grid]),

    %% 2. DP 表初始化：使用 counters 模拟 C++ 的 int dp[][][][] 数组
    %% 状态总数 = Rows * Cols * 4(方向) * 2(是否转向)
    %% 我们使用扁平化索引映射这 4 个维度
    Size = Rows * Cols * 8, 
    DP = counters:new(Size, [write_concurrency]), 
    %% counters 默认为 0，对应 C++ 代码中我们需要判断 != -1 (这里 0 表示未计算)

    %% 3. 主循环：遍历所有格子寻找起点
    solve_loop(1, 1, Rows, Cols, GridT, DP, 0).

%% 遍历行结束
solve_loop(R, _C, Rows, _Cols, _GridT, _DP, Max) when R > Rows -> 
    Max;
%% 换行
solve_loop(R, C, Rows, Cols, GridT, DP, Max) when C > Cols -> 
    solve_loop(R + 1, 1, Rows, Cols, GridT, DP, Max);
%% 遍历单元格
solve_loop(R, C, Rows, Cols, GridT, DP, Max) ->
    Val = get_cell(GridT, R, C),
    NewMax = case Val of
        1 ->
            %% 对应 C++: if (grid[i][j]==1)
            %% 尝试从 4 个方向出发，dfs(i, j, d, 0, 2)
            M0 = dfs(R, C, 0, 0, 2, Rows, Cols, GridT, DP),
            M1 = dfs(R, C, 1, 0, 2, Rows, Cols, GridT, DP),
            M2 = dfs(R, C, 2, 0, 2, Rows, Cols, GridT, DP),
            M3 = dfs(R, C, 3, 0, 2, Rows, Cols, GridT, DP),
            lists:max([Max, M0, M1, M2, M3]);
        _ ->
            Max
    end,
    solve_loop(R, C + 1, Rows, Cols, GridT, DP, NewMax).

%% =============================================================================
%% DFS 核心逻辑 (完全对应 C++ dfs 函数)
%% States: R, C, Dir(0-3), Turn(0-1), Nxt(期望的下一个值 0或2)
%% =============================================================================
dfs(R, C, Dir, Turn, Nxt, Rows, Cols, GridT, DP) ->
    %% 计算扁平化索引 (1-based)
    %% Index = [ (Row-1)*Cols + (Col-1) ] * 8 + Dir*2 + Turn + 1
    Idx = ((((R - 1) * Cols + (C - 1)) * 4 + Dir) * 2 + Turn) + 1,
    
    %% 检查记忆化 (if dp[...] != -1)
    case counters:get(DP, Idx) of
        0 -> 
            %% 未计算，开始计算
            Ans1 = 1, %% 基础长度包含当前点
            
            %% Logic 1: 沿当前方向移动 (Move in current direction)
            {Dr, Dc} = element(Dir + 1, ?DIRS),
            NextR = R + Dr,
            NextC = C + Dc,
            
            Ans2 = case is_valid(NextR, NextC, Rows, Cols) of
                true ->
                    case get_cell(GridT, NextR, NextC) of
                        Nxt -> 
                            %% 递归调用，nxt^2 (C++) 等价于 2 - Nxt (Erlang)
                            1 + dfs(NextR, NextC, Dir, Turn, 2 - Nxt, Rows, Cols, GridT, DP);
                        _ -> 
                            Ans1
                    end;
                false -> 
                    Ans1
            end,

            %% Logic 2: 尝试转向 (Try turning)
            FinalAns = case Turn of
                0 -> %% if (!turn)
                    NewDir = (Dir + 1) rem 4, %% (dir+1)%4
                    {TurnDr, TurnDc} = element(NewDir + 1, ?DIRS),
                    TurnR = R + TurnDr,
                    TurnC = C + TurnDc,
                    
                    case is_valid(TurnR, TurnC, Rows, Cols) of
                        true ->
                            case get_cell(GridT, TurnR, TurnC) of
                                Nxt ->
                                    %% 转向后 turn 变为 1
                                    TurnLen = 1 + dfs(TurnR, TurnC, NewDir, 1, 2 - Nxt, Rows, Cols, GridT, DP),
                                    max(Ans2, TurnLen);
                                _ ->
                                    Ans2
                            end;
                        false ->
                            Ans2
                    end;
                1 ->
                    Ans2
            end,
            
            %% 写入缓存 return dp[...] = ans
            counters:put(DP, Idx, FinalAns),
            FinalAns;
            
        StoredVal ->
            StoredVal
    end.

%% 辅助函数
get_cell(GridT, R, C) ->
    element(C, element(R, GridT)).

is_valid(R, C, Rows, Cols) ->
    R >= 1 andalso R =< Rows andalso C >= 1 andalso C =< Cols.