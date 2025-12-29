-spec magical_sum(M :: integer(), K :: integer(), Nums :: [integer()]) -> integer().
-define(MOD, 1000000007).

magical_sum(M, K, Nums) ->
    %% 1. 预计算阶乘的逆元，用于计算 1/c!
    %% FactInvList 的第 i 个元素对应 (1/i!) % MOD
    FactInvList = precompute_inv_facts(M, ?MOD),

    %% 2. 初始化 DP 状态
    %% State: #{ {Carry, Used, SetBits} => WeightedSum }
    InitState = #{ {0, 0, 0} => 1 },

    %% 3. 逐个处理 nums 中的数字 (对应二进制的位权重)
    FinalState = lists:foldl(fun(Num, AccMap) ->
        process_layer(Num, AccMap, M, K, FactInvList)
    end, InitState, Nums),

    %% 4. 统计最终结果
    %% 此时 Used 必须等于 M。
    %% 剩余的 Carry 需要继续处理（模拟更高位的进位），统计其中的置位。
    TotalSum = maps:fold(fun({Carry, Used, Bits}, Val, Acc) ->
        if 
            Used == M ->
                FinalBits = Bits + popcount(Carry),
                if 
                    FinalBits == K -> (Acc + Val) rem ?MOD;
                    true -> Acc
                end;
            true -> Acc
        end
    end, 0, FinalState),

    %% 5. 最后乘上 m! (全排列系数)
    FactM = factorial(M),
    (TotalSum * FactM) rem ?MOD.

%% @private
%% 处理一层 DP (即处理 nums 中的一个数字)
process_layer(Num, PrevMap, M, K, FactInvList) ->
    %% 预先计算 Num^c * InvFact[c] for c in 0..M
    %% 这样在内层循环中可以直接查表
    PrecomputedTerms = precompute_terms(Num, M, FactInvList, []),
    TermTuple = list_to_tuple(PrecomputedTerms),

    maps:fold(fun({Carry, Used, Bits}, Count, NextMap) ->
        %% 我们最多还能选 M - Used 个
        MaxTake = M - Used,
        try_counts(0, MaxTake, Carry, Used, Bits, Count, NextMap, TermTuple, K)
    end, #{}, PrevMap).

%% @private
%% 尝试选取 c 个当前数字
try_counts(C, MaxTake, _Carry, _Used, _Bits, _Count, Map, _Terms, _K) when C > MaxTake ->
    Map;
try_counts(C, MaxTake, Carry, Used, Bits, Count, Map, Terms, K) ->
    Sum = Carry + C,
    NewBit = Sum rem 2,
    NewBits = Bits + NewBit,

    %% 剪枝：如果置位数已经超过 K，则不再继续
    if 
        NewBits > K -> 
            try_counts(C + 1, MaxTake, Carry, Used, Bits, Count, Map, Terms, K);
        true ->
            NewCarry = Sum div 2,
            NewUsed = Used + C,
            
            %% 获取预计算的 (Num^C / C!)
            Factor = element(C + 1, Terms), 
            AddedVal = (Count * Factor) rem ?MOD,
            
            Key = {NewCarry, NewUsed, NewBits},
            NewMap = maps:update_with(Key, fun(V) -> (V + AddedVal) rem ?MOD end, AddedVal, Map),
            
            try_counts(C + 1, MaxTake, Carry, Used, Bits, Count, NewMap, Terms, K)
    end.

%% --- 辅助数学函数 ---

%% 计算二进制中 1 的个数
popcount(0) -> 0;
popcount(N) -> (N band 1) + popcount(N bsr 1).

%% 阶乘
factorial(0) -> 1;
factorial(N) -> (N * factorial(N - 1)) rem ?MOD.

%% 模幂
mod_pow(_, 0) -> 1;
mod_pow(B, E) ->
    R = mod_pow((B * B) rem ?MOD, E div 2),
    case E rem 2 of
        1 -> (R * B) rem ?MOD;
        0 -> R
    end.

%% 模逆元 (费马小定理)
mod_inverse(N) -> mod_pow(N, ?MOD - 2).

%% 预计算 (Num^C / C!) for C in 0..M
precompute_terms(_Num, -1, _FactInvList, Acc) -> Acc;
precompute_terms(Num, C, FactInvList, Acc) ->
    %% FactInvList 是 tuple，索引从 1 开始对应 0! 的逆元
    InvFact = element(C + 1, FactInvList), 
    PowVal = mod_pow(Num, C),
    Term = (PowVal * InvFact) rem ?MOD,
    precompute_terms(Num, C - 1, FactInvList, [Term | Acc]).

%% 预计算 1/0!, 1/1!, ..., 1/M!
precompute_inv_facts(M, Mod) ->
    List = [mod_inverse(factorial_raw(I, Mod)) || I <- lists:seq(0, M)],
    list_to_tuple(List).

factorial_raw(0, _) -> 1;
factorial_raw(N, Mod) -> (N * factorial_raw(N - 1, Mod)) rem Mod.