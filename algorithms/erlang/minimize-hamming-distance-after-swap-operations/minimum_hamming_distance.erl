-spec minimum_hamming_distance(Source :: [integer()], Target :: [integer()], AllowedSwaps :: [[integer()]]) -> integer().
minimum_hamming_distance(Source, Target, AllowedSwaps) ->
    N = length(Source),
    ST = list_to_tuple(Source),
    TT = list_to_tuple(Target),
    Adj = build_adj(AllowedSwaps, maps:new()),
    Groups = components(N, Adj),
    calc_diff(Groups, ST, TT, N).

build_adj([], Adj) ->
    Adj;
build_adj([[U, V] | Rest], Adj) ->
    Adj1 = maps:update_with(U, fun(L) -> [V | L] end, [V], Adj),
    Adj2 = maps:update_with(V, fun(L) -> [U | L] end, [U], Adj1),
    build_adj(Rest, Adj2).

components(N, Adj) ->
    {_, Groups} = lists:foldl(
        fun(I, {Visited, Acc}) ->
            case maps:is_key(I, Visited) of
                true -> {Visited, Acc};
                false ->
                    {NewVisited, Group} = bfs([I], Adj, Visited, []),
                    {NewVisited, [Group | Acc]}
            end
        end, {maps:new(), []}, lists:seq(0, N - 1)),
    Groups.

bfs([], _Adj, Visited, Group) ->
    {Visited, Group};
bfs([Node | Queue], Adj, Visited, Group) ->
    case maps:is_key(Node, Visited) of
        true ->
            bfs(Queue, Adj, Visited, Group);
        false ->
            Visited1 = maps:put(Node, true, Visited),
            Neighbors = maps:get(Node, Adj, []),
            bfs(Neighbors ++ Queue, Adj, Visited1, [Node | Group])
    end.

calc_diff([], _ST, _TT, Diff) ->
    Diff;
calc_diff([Group | Rest], ST, TT, Diff) ->
    SourceElements = [element(I + 1, ST) || I <- Group],
    TargetElements = [element(I + 1, TT) || I <- Group],
    SourceCounts = lists:foldl(
        fun(E, Acc) -> maps:update_with(E, fun(C) -> C + 1 end, 1, Acc) end,
        maps:new(),
        SourceElements
    ),
    Matches = count_matches(TargetElements, SourceCounts, 0),
    calc_diff(Rest, ST, TT, Diff - Matches).

count_matches([], _Counts, Matches) ->
    Matches;
count_matches([E | Rest], Counts, Matches) ->
    case maps:find(E, Counts) of
        error ->
            count_matches(Rest, Counts, Matches);
        {ok, 0} ->
            count_matches(Rest, Counts, Matches);
        {ok, C} ->
            count_matches(Rest, maps:put(E, C - 1, Counts), Matches + 1)
    end.