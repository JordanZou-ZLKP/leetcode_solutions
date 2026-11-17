-spec minimum_changes(S :: unicode:unicode_binary(), K :: integer()) -> integer().
minimum_changes(S, K) ->
    Size = byte_size(S),
    TupleS = list_to_tuple(binary_to_list(S)),
    Divs = build_divs(Size),
    CostTuple = build_cost_tuple(TupleS, Size, Divs),
    InitialDP = list_to_tuple([if I == 0 -> 0; true -> infinity end || I <- lists:seq(0, Size)]),
    FinalDP = lists:foldl(
        fun(P, PrevDP) ->
            compute_dp_row(P, Size, PrevDP, CostTuple)
        end, InitialDP, lists:seq(1, K)),
    element(Size + 1, FinalDP).

build_divs(Size) ->
    list_to_tuple([
        if L < 2 -> [];
           true -> [D || D <- lists:seq(1, L div 2), L rem D == 0]
        end
        || L <- lists:seq(1, Size)
    ]).

build_cost_tuple(TupleS, Size, Divs) ->
    list_to_tuple([
        list_to_tuple([
            if J > I -> calc_min_cost(TupleS, I, J - I + 1, element(J - I + 1, Divs));
               true -> infinity
            end
            || J <- lists:seq(1, Size)
        ])
        || I <- lists:seq(1, Size)
    ]).

calc_min_cost(TupleS, I, L, Divisors) ->
    lists:min([cost_for_divisor(TupleS, I, D, L) || D <- Divisors]).

cost_for_divisor(TupleS, I, D, L) ->
    M = L div D,
    lists:sum([
        mismatches_loop(TupleS, I + StartOffset, D, M, 0, M div 2, 0)
        || StartOffset <- lists:seq(0, D - 1)
    ]).

mismatches_loop(_TupleS, _StartIdx, _D, _M, C, Limit, Acc) when C >= Limit -> Acc;
mismatches_loop(TupleS, StartIdx, D, M, C, Limit, Acc) ->
    Idx1 = StartIdx + C * D,
    Idx2 = StartIdx + (M - 1 - C) * D,
    NewAcc = if element(Idx1, TupleS) =:= element(Idx2, TupleS) -> Acc;
                true -> Acc + 1
             end,
    mismatches_loop(TupleS, StartIdx, D, M, C + 1, Limit, NewAcc).

compute_dp_row(P, Size, PrevDP, CostTuple) ->
    MinI = 2 * P,
    list_to_tuple([
        if I < MinI -> infinity;
           true ->
               MinJ_Start = 2 * (P - 1),
               MinJ_End = I - 2,
               lists:min([
                   case element(J + 1, PrevDP) of
                       infinity -> infinity;
                       PrevCost -> PrevCost + element(I, element(J + 1, CostTuple))
                   end
                   || J <- lists:seq(MinJ_Start, MinJ_End)
               ])
        end
        || I <- lists:seq(0, Size)
    ]).

