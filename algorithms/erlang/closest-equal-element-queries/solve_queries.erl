-spec solve_queries(Nums :: [integer()], Queries :: [integer()]) -> [integer()].
solve_queries(Nums, Queries) ->
    N = length(Nums),
    IndexedNums = lists:zip(Nums, lists:seq(0, N - 1)),
    ValueMap = lists:foldl(
        fun({Val, Idx}, Acc) ->
            maps:update_with(Val, fun(L) -> [Idx | L] end, [Idx], Acc)
        end,
        maps:new(),
        IndexedNums
    ),
    DistMap = maps:fold(
        fun(_, Indices, Acc) ->
            case Indices of
                [_Idx] ->
                    Acc#{hd(Indices) => -1};
                _ ->
                    Sorted = lists:reverse(Indices),
                    Extended = [lists:last(Sorted)] ++ Sorted ++ [hd(Sorted)],
                    calc_min_dists(Extended, N, Acc)
            end
        end,
        maps:new(),
        ValueMap
    ),
    [maps:get(Q, DistMap) || Q <- Queries].

calc_min_dists([Prev, Curr, Next | Rest], N, Acc) ->
    D1 = min_circ_dist(Curr, Prev, N),
    D2 = min_circ_dist(Curr, Next, N),
    calc_min_dists([Curr, Next | Rest], N, Acc#{Curr => min(D1, D2)});
calc_min_dists(_, _, Acc) ->
    Acc.

min_circ_dist(A, B, N) ->
    Diff = abs(A - B),
    min(Diff, N - Diff).