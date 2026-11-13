-spec count_non_decreasing_subarrays(Nums :: [integer()], K :: integer()) -> integer().
count_non_decreasing_subarrays(Nums, K) ->
    Tuple = list_to_tuple(Nums),
    N = tuple_size(Tuple),
    Q = queue:new(),
    loop(N, N, Q, 0, 0, K, Tuple, 0).

loop(0, _, _, _, _, _, _, Ans) ->
    Ans;
loop(I, J, Q, SumM, SumA, K, Tuple, Ans) ->
    Val = element(I, Tuple),
    {Q1, AddCount, SumM1} = collapse(Q, Val, 1, SumM),
    Q2 = queue:in_r({Val, AddCount}, Q1),
    SumM2 = SumM1 + Val * AddCount,
    SumA1 = SumA + Val,
    {Q3, SumM3, SumA2, J1} = shrink(Q2, SumM2, SumA1, J, K, Tuple),
    loop(I - 1, J1, Q3, SumM3, SumA2, K, Tuple, Ans + (J1 - I + 1)).

collapse(Q, Val, Count, SumM) ->
    case queue:out(Q) of
        {empty, _} ->
            {Q, Count, SumM};
        {{value, {V, C}}, Q1} ->
            if
                V =< Val ->
                    collapse(Q1, Val, Count + C, SumM - V * C);
                true ->
                    {Q, Count, SumM}
            end
    end.

shrink(Q, SumM, SumA, J, K, Tuple) ->
    if
        SumM - SumA > K ->
            ValToRemove = element(J, Tuple),
            NewSumA = SumA - ValToRemove,
            {{value, {V, C}}, Q1} = queue:out_r(Q),
            NewQ = if
                C == 1 -> Q1;
                true -> queue:in({V, C - 1}, Q1)
            end,
            NewSumM = SumM - V,
            shrink(NewQ, NewSumM, NewSumA, J - 1, K, Tuple);
        true ->
            {Q, SumM, SumA, J}
    end.

