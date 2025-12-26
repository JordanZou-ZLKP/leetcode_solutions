-spec min_operations(Queries :: [[integer()]]) -> integer().
min_operations(Queries) ->
    process_queries(Queries, 0).

%% @private 递归处理每一个查询
process_queries([], TotalOps) ->
    TotalOps;
process_queries([[L, R] | Rest], TotalOps) ->
    %% 计算区间 [L, R] 内所有数字归零所需的总步数
    %% 利用前缀和思想: Sum([L, R]) = G(R) - G(L-1)
    SumR = get_total_steps(R),
    SumL = get_total_steps(L - 1),
    
    RangeSteps = SumR - SumL,
    
    %% 每次操作消耗 2 个步数，向上取整
    %% ceil(x / 2) 等价于 (x + 1) div 2
    Ops = (RangeSteps + 1) div 2,
    
    process_queries(Rest, TotalOps + Ops).

%% @private 计算从 1 到 N 所有数字归零所需的总步数之和
%% 时间复杂度: O(log4 N)
get_total_steps(N) ->
    calc_steps(N, 1, 0).

%% @private 累加每一层级的贡献
%% Threshold 代表 4 的幂次: 1, 4, 16, 64...
calc_steps(N, Threshold, Acc) when Threshold > N ->
    Acc;
calc_steps(N, Threshold, Acc) ->
    %% 在 1 到 N 的范围内，大于等于 Threshold 的数字个数为 (N - Threshold + 1)
    %% 这些数字都贡献了当前这一层的 1 个步数
    Count = N - Threshold + 1,
    calc_steps(N, Threshold * 4, Acc + Count).