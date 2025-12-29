-spec min_score_triangulation(Values :: [integer()]) -> integer().
min_score_triangulation(Values) ->

    N = length(Values),
    % 将列表转换为元组以便 O(1) 访问元素
    V = list_to_tuple(Values),
    
    % DP 状态存储在 Map 中: Key = {i, j}, Value = MinScore
    % 我们采用自底向上的方式（Iterative DP）
    % 外层循环：区间长度 Len 从 3 到 N
    FinalMemo = lists:foldl(fun(Len, MemoAcc) ->
        
        % 内层循环：起始位置 i 从 0 到 N - Len
        lists:foldl(fun(I, InnerMemo) ->
            J = I + Len - 1,
            
            % 在 i 和 j 之间寻找分割点 k，使分数最小
            % k 的范围是 i+1 到 j-1
            MinScore = find_min_score(I, J, I + 1, J - 1, V, InnerMemo, infinity),
            
            % 更新 DP 表
            maps:put({I, J}, MinScore, InnerMemo)
        end, MemoAcc, lists:seq(0, N - Len))
        
    end, #{}, lists:seq(3, N)),
    
    % 返回整个多边形 (0 到 N-1) 的最小得分
    maps:get({0, N - 1}, FinalMemo).

%% 辅助函数：遍历 k 寻找最小值
find_min_score(_I, _J, K, EndK, _V, _Memo, CurrentMin) when K > EndK ->
    CurrentMin;
find_min_score(I, J, K, EndK, V, Memo, CurrentMin) ->
    % 获取左边部分 dp[i][k] 的值 (如果是相邻点则为0)
    LeftScore = get_score(I, K, Memo),
    % 获取右边部分 dp[k][j] 的值
    RightScore = get_score(K, J, Memo),
    
    % 当前三角形 (i, k, j) 的权重
    % 注意：Erlang tuple 索引从 1 开始，所以需要 +1
    TriangleVal = element(I + 1, V) * element(K + 1, V) * element(J + 1, V),
    
    TotalScore = LeftScore + RightScore + TriangleVal,
    
    NewMin = min(CurrentMin, TotalScore),
    find_min_score(I, J, K + 1, EndK, V, Memo, NewMin).

%% 从 Map 中获取分数，如果区间长度小于 2 (不存在于 Map) 则返回 0
get_score(I, J, _Memo) when J < I + 2 -> 0;
get_score(I, J, Memo) -> maps:get({I, J}, Memo).