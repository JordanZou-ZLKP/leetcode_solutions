-spec min_deletion_size(Strs :: [unicode:unicode_binary()]) -> integer().

to_list(Ones) ->
    R = [binary_to_list(One) || One <- Ones].

min_deletion_size(Ones) ->
    Strs = to_list(Ones),
    % 1. 为了实现 O(1) 的随机访问，将输入转换为 Tuple of Tuples 结构
    % Rows 格式: {{97, 98, ...}, {100, 101, ...}, ...}
    Rows = list_to_tuple([list_to_tuple(S) || S <- Strs]),
    
    % 获取行数 N 和 列数 M
    NumRows = tuple_size(Rows),
    M = tuple_size(element(1, Rows)),
    
    % 2. 初始化 DP 数组，长度为 M，默认值为 1
    % DP[i] 表示以索引 i 结尾的最长保留子序列长度
    DP = array:new(M, {default, 1}),
    
    % 3. 执行动态规划计算
    FinalDP = solve_dp(0, M, NumRows, Rows, DP),
    
    % 4. 找出 DP 中的最大值 (即保留的最长长度)
    MaxKept = array:foldl(fun(_, Val, Acc) -> max(Val, Acc) end, 0, FinalDP),
    
    % 5. 结果 = 总长度 - 保留的最长长度
    M - MaxKept.

%% 主循环：遍历每一列 I (从 0 到 M-1)
solve_dp(I, M, _NumRows, _Rows, DP) when I == M -> 
    DP;
solve_dp(I, M, NumRows, Rows, DP) ->
    % 对于当前的 I，检查所有之前的 J (0 到 I-1)
    BestLen = find_best_prev(0, I, NumRows, Rows, DP, 1),
    NewDP = array:set(I, BestLen, DP),
    solve_dp(I + 1, M, NumRows, Rows, NewDP).

%% 内部循环：遍历 J < I，寻找可以连接的最佳前驱
find_best_prev(J, I, _, _, _, CurrentMax) when J == I -> 
    CurrentMax;
find_best_prev(J, I, NumRows, Rows, DP, CurrentMax) ->
    LenJ = array:get(J, DP),
    % 优化：只有当 DP[J] + 1 比当前已知的最大值大时，才进行昂贵的兼容性检查
    case (LenJ + 1 > CurrentMax) of
        true ->
            % 检查列 J 和列 I 是否在所有行中都满足非递减关系
            % 注意：tuple 索引是 1-based，所以传入 J+1, I+1
            case is_compatible(1, NumRows, Rows, J + 1, I + 1) of
                true -> find_best_prev(J + 1, I, NumRows, Rows, DP, LenJ + 1);
                false -> find_best_prev(J + 1, I, NumRows, Rows, DP, CurrentMax)
            end;
        false ->
             find_best_prev(J + 1, I, NumRows, Rows, DP, CurrentMax)
    end.

%% 兼容性检查：检查是否所有行 R 满足 Rows[R][J] <= Rows[R][I]
is_compatible(R, NumRows, _, _, _) when R > NumRows -> 
    true;
is_compatible(R, NumRows, Rows, J, I) ->
    Row = element(R, Rows),
    CharJ = element(J, Row),
    CharI = element(I, Row),
    if
        CharJ =< CharI -> is_compatible(R + 1, NumRows, Rows, J, I);
        true -> false
    end.