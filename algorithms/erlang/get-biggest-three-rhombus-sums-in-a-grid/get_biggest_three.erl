-spec get_biggest_three(Grid :: [[integer()]]) -> [integer()].
get_biggest_three(Grid) ->
    TupleGrid = list_to_tuple([list_to_tuple(Row) || Row <- Grid]),
    M = tuple_size(TupleGrid),
    N = tuple_size(element(1, TupleGrid)),
    lists:foldl(
        fun(R, Acc1) ->
            lists:foldl(
                fun(C, Acc2) ->
                    MaxL = min(C - 1, min(N - C, (M - R) div 2)),
                    lists:foldl(
                        fun(L, Acc3) ->
                            Sum = calc_rhombus(TupleGrid, R, C, L),
                            update_top(Sum, Acc3)
                        end, Acc2, lists:seq(0, MaxL))
                end, Acc1, lists:seq(1, N))
        end, [], lists:seq(1, M)).

calc_rhombus(Grid, R, C, 0) ->
    element(C, element(R, Grid));
calc_rhombus(Grid, R, C, L) ->
    sum_edge(Grid, R, C, 1, -1, L, 0) +
    sum_edge(Grid, R + L, C - L, 1, 1, L, 0) +
    sum_edge(Grid, R + 2 * L, C, -1, 1, L, 0) +
    sum_edge(Grid, R + L, C + L, -1, -1, L, 0).

sum_edge(_Grid, _R, _C, _Dr, _Dc, 0, Acc) ->
    Acc;
sum_edge(Grid, R, C, Dr, Dc, Steps, Acc) ->
    Val = element(C, element(R, Grid)),
    sum_edge(Grid, R + Dr, C + Dc, Dr, Dc, Steps - 1, Acc + Val).

update_top(Val, [A, B, C] = L) ->
    if
        Val == A orelse Val == B orelse Val == C -> L;
        Val > A -> [Val, A, B];
        Val > B -> [A, Val, B];
        Val > C -> [A, B, Val];
        true -> L
    end;
update_top(Val, [A, B] = L) ->
    if
        Val == A orelse Val == B -> L;
        Val > A -> [Val, A, B];
        Val > B -> [A, Val, B];
        true -> [A, B, Val]
    end;
update_top(Val, [A] = L) ->
    if
        Val == A -> L;
        Val > A -> [Val, A];
        true -> [A, Val]
    end;
update_top(Val, []) ->
    [Val].