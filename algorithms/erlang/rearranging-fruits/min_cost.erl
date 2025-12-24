-spec min_cost(Basket1 :: [integer()], Basket2 :: [integer()]) -> integer().
min_cost(Basket1, Basket2) ->
    % 1. 计算全局最小值，用于优化交换策略
    GlobalMin = lists:min(Basket1 ++ Basket2),
    
    % 2. 构建平衡 Map (Basket1 +1, Basket2 -1)
    % 这一步时间复杂度 O(N)
    BalanceMap = build_balance_map(Basket1, Basket2),
    
    % 3. 分析 Map，检查可行性并生成待交换列表
    % 这一步时间复杂度 O(N)
    case generate_excess_list(maps:to_list(BalanceMap), []) of
        {error, impossible} ->
            -1;
        ExcessList ->
            % 4. 计算成本
            % 排序复杂度 O(K log K)，其中 K <= N
            SortedExcess = lists:sort(ExcessList),
            SwapsNeeded = length(SortedExcess) div 2,
            
            % 取出前半部分（较小的值）
            {SmallHalf, _} = lists:split(SwapsNeeded, SortedExcess),
            
            % 累加成本：min(当前值, 2 * 全局最小值)
            calculate_total_cost(SmallHalf, GlobalMin, 0)
    end.

%% ---------------------------------------------------------
%% 辅助函数
%% ---------------------------------------------------------

%% 构建平衡 Map
build_balance_map(L1, L2) ->
    M1 = update_counts(L1, 1, maps:new()),
    update_counts(L2, -1, M1).

update_counts([], _Delta, Map) ->
    Map;
update_counts([H|T], Delta, Map) ->
    NewMap = maps:update_with(H, fun(V) -> V + Delta end, Delta, Map),
    update_counts(T, Delta, NewMap).

%% 生成待交换列表 (Excess List)
%% 如果发现奇数差值，立即返回错误
generate_excess_list([], Acc) ->
    Acc;
generate_excess_list([{_Val, 0} | T], Acc) ->
    generate_excess_list(T, Acc);
generate_excess_list([{Val, Count} | T], Acc) ->
    % 绝对值
    AbsCount = abs(Count),
    case AbsCount rem 2 of
        1 -> {error, impossible}; % 奇数个差异，无法平分
        0 ->
            % 需要移动的数量是差异的一半
            NumToMove = AbsCount div 2,
            NewAcc = add_copies(Val, NumToMove, Acc),
            generate_excess_list(T, NewAcc)
    end.

%% 将 Val 添加 N 次到列表中
add_copies(_Val, 0, Acc) -> Acc;
add_copies(Val, N, Acc) -> add_copies(Val, N-1, [Val | Acc]).

%% 计算总成本
calculate_total_cost([], _GlobalMin, Total) ->
    Total;
calculate_total_cost([Val | T], GlobalMin, Total) ->
    % 核心逻辑：直接交换成本是 Val，借用全局最小值的成本是 2 * GlobalMin
    Cost = min(Val, 2 * GlobalMin),
    calculate_total_cost(T, GlobalMin, Total + Cost).