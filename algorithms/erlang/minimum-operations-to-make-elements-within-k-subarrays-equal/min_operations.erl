-spec min_operations(Nums :: [integer()], X :: integer(), K :: integer()) -> integer().
min_operations(Nums, X, K) ->
    {InitPairs, RestNums} = init_window(X, Nums, 1, []),
    Sorted = lists:sort(InitPairs),
    TargetL = (X + 1) div 2,
    {ListL, ListU} = lists:split(TargetL, Sorted),
    SumL = sum_pairs(ListL, 0),
    SumU = sum_pairs(ListU, 0),
    Lower = gb_sets:from_ordset(ListL),
    Upper = gb_sets:from_ordset(ListU),
    IsOdd = X rem 2,
    Cost0 = window_cost(Lower, SumL, SumU, IsOdd),
    Costs = slide(RestNums, Nums, 1, X + 1, Lower, SumL, Upper, SumU, TargetL, IsOdd, [Cost0]),
    DP1 = prefix_min(Costs),
    dp_layers(K, X, Costs, DP1).

init_window(0, Rest, _Idx, Acc) ->
    {Acc, Rest};
init_window(Cnt, [V | Vs], Idx, Acc) ->
    init_window(Cnt - 1, Vs, Idx + 1, [{V, Idx} | Acc]).

sum_pairs([], Acc) ->
    Acc;
sum_pairs([{V, _} | Rest], Acc) ->
    sum_pairs(Rest, Acc + V).

window_cost(_Lower, SumL, SumU, 0) ->
    SumU - SumL;
window_cost(Lower, SumL, SumU, 1) ->
    {Med, _} = gb_sets:largest(Lower),
    SumU - SumL + Med.

slide([], _OutList, _OutIdx, _InIdx, _Lower, _SumL, _Upper, _SumU, _TargetL, _IsOdd, Acc) ->
    lists:reverse(Acc);
slide([InVal | InRest], [OutVal | OutRest], OutIdx, InIdx, Lower, SumL, Upper, SumU, TargetL, IsOdd, Acc) ->
    InE = {InVal, InIdx},
    OutE = {OutVal, OutIdx},
    MaxL = gb_sets:largest(Lower),
    {Lower1, SumL1, Upper1, SumU1} =
        if
            InE =< MaxL ->
                {gb_sets:insert(InE, Lower), SumL + InVal, Upper, SumU};
            true ->
                {Lower, SumL, gb_sets:insert(InE, Upper), SumU + InVal}
        end,
    {Lower2, SumL2, Upper2, SumU2} =
        if
            OutE =< MaxL ->
                {gb_sets:delete(OutE, Lower1), SumL1 - OutVal, Upper1, SumU1};
            true ->
                {Lower1, SumL1, gb_sets:delete(OutE, Upper1), SumU1 - OutVal}
        end,
    {Lower3, SumL3, Upper3, SumU3} =
        rebalance(gb_sets:size(Lower2), TargetL, Lower2, SumL2, Upper2, SumU2),
    Cost = window_cost(Lower3, SumL3, SumU3, IsOdd),
    slide(InRest, OutRest, OutIdx + 1, InIdx + 1, Lower3, SumL3, Upper3, SumU3, TargetL, IsOdd, [Cost | Acc]).

rebalance(SizeL, TargetL, Lower, SumL, Upper, SumU) when SizeL > TargetL ->
    {{Val, _} = Elem, Lower1} = gb_sets:take_largest(Lower),
    {Lower1, SumL - Val, gb_sets:insert(Elem, Upper), SumU + Val};
rebalance(SizeL, TargetL, Lower, SumL, Upper, SumU) when SizeL < TargetL ->
    {{Val, _} = Elem, Upper1} = gb_sets:take_smallest(Upper),
    {gb_sets:insert(Elem, Lower), SumL + Val, Upper1, SumU - Val};
rebalance(_SizeL, _TargetL, Lower, SumL, Upper, SumU) ->
    {Lower, SumL, Upper, SumU}.

prefix_min([C | Cs]) ->
    prefix_min(Cs, C, [C]).

prefix_min([], _Min, Acc) ->
    lists:reverse(Acc);
prefix_min([C | Cs], Min, Acc) ->
    NewMin = min(Min, C),
    prefix_min(Cs, NewMin, [NewMin | Acc]).

dp_layers(1, _X, _Costs, DP) ->
    lists:last(DP);
dp_layers(RemK, X, Costs, PrevDP) ->
    NextCosts = lists:nthtail(X, Costs),
    NextDP = next_layer(NextCosts, PrevDP),
    dp_layers(RemK - 1, X, NextCosts, NextDP).

next_layer([C | Cs], [P | Ps]) ->
    First = P + C,
    next_layer(Cs, Ps, First, [First]).

next_layer([], _Ps, _Min, Acc) ->
    lists:reverse(Acc);
next_layer([C | Cs], [P | Ps], Min, Acc) ->
    Val = P + C,
    NewMin = min(Min, Val),
    next_layer(Cs, Ps, NewMin, [NewMin | Acc]).

