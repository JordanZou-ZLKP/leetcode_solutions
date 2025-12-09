-spec intersection_size_two(Intervals :: [[integer()]]) -> integer().
intersection_size_two(Intervals) ->
    SortFun = fun([S1, E1], [S2, E2]) ->
        if
            E1 < E2 -> true;
            E1 > E2 -> false;
            true -> S1 > S2
        end
    end,
    SortedIntervals = lists:sort(SortFun, Intervals),
    solve(SortedIntervals, -1, -1, 0).

solve([], _, _, Acc) ->
    Acc;
solve([[S, E] | T], P1, P2, Acc) ->
    if
        S =< P1 ->
            solve(T, P1, P2, Acc);
        S =< P2 ->
            solve(T, P2, E, Acc + 1);
        true ->
            solve(T, E - 1, E, Acc + 2)
    end.