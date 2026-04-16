-spec minimum_total_distance(Robot :: [integer()], Factory :: [[integer()]]) -> integer().
minimum_total_distance(Robot, Factory) ->
    SortedRobots = lists:sort(Robot),
    SortedFactories = lists:sort(fun([P1, _], [P2, _]) -> P1 =< P2 end, Factory),
    N = length(SortedRobots),
    FlatFactories = lists:flatmap(
        fun([P, L]) -> lists:duplicate(min(L, N), P) end,
        SortedFactories
    ),
    Inf = 1000000000000000000,
    InitDP = [0 | lists:duplicate(N, Inf)],
    UpdateDP = fun F([R | Rs], [PrevI0, PrevI1 | PrevRest], P, Acc) ->
                       NextVal = min(PrevI1, PrevI0 + abs(R - P)),
                       F(Rs, [PrevI1 | PrevRest], P, [NextVal | Acc]);
                   F([], [_], _, Acc) ->
                       lists:reverse(Acc)
               end,
    FinalDP = lists:foldl(
        fun(P, PrevDP) ->
            UpdateDP(SortedRobots, PrevDP, P, [0])
        end,
        InitDP,
        FlatFactories
    ),
    lists:last(FinalDP).