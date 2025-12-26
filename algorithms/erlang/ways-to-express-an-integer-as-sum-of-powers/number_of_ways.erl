-spec number_of_ways(N :: integer(), X :: integer()) -> integer().

-define(MOD, 1000000007).

%% @doc
%% Given two positive integers n and x.
%% Return the number of ways n can be expressed as the sum of the xth power of unique positive integers.

number_of_ways(N, X) ->
    % 1. 生成所有可能的“物品” (v = i^x, v <= n)
    Candidates = generate_powers(N, X, 1, []),
    
    % 2. 初始化 DP 状态。
    % 使用 Map 存储状态 #{Sum => Count}
    % 初始状态：和为 0 的方案数为 1
    InitialDP = #{0 => 1},
    
    % 3. 核心 DP 循环 (0/1 背包逻辑)
    % 遍历每个物品，更新 DP 表
    FinalDP = lists:foldl(fun(Val, CurrentDP) ->
        update_dp(Val, N, CurrentDP)
    end, InitialDP, Candidates),
    
    % 4. 获取目标 N 的方案数，默认为 0
    maps:get(N, FinalDP, 0).

%% 生成 i^x <= N 的列表
generate_powers(N, X, I, Acc) ->
    Val = ipow(I, X),
    if
        Val > N -> lists:reverse(Acc);
        true -> generate_powers(N, X, I + 1, [Val | Acc])
    end.

%% 整数幂运算 (避免 math:pow 的浮点转换)
ipow(Base, Exp) ->
    ipow(Base, Exp, 1).
ipow(_, 0, Acc) -> Acc;
ipow(Base, Exp, Acc) -> ipow(Base, Exp - 1, Base * Acc).

%% 更新 DP 表
%% 对于当前的物品 Val，遍历现有的所有 Sum，计算 NewSum = Sum + Val
%% 如果 NewSum <= N，则将旧 Sum 的方案数累加到 NewSum 中
update_dp(Val, Limit, DP) ->
    % 注意：我们遍历的是 DP (旧状态)，生成的是 AccDP (新状态)
    % 这自然地满足了“每个物品只能使用一次”的限制，
    % 因为我们不会在同一个 fold 过程中使用刚生成的 NewSum 去再次加 Val。
    maps:fold(fun(Sum, Count, AccDP) ->
        NewSum = Sum + Val,
        if
            NewSum =< Limit ->
                OldCount = maps:get(NewSum, AccDP, 0),
                NewCount = (OldCount + Count) rem ?MOD,
                maps:put(NewSum, NewCount, AccDP);
            true ->
                AccDP
        end
    end, DP, DP).