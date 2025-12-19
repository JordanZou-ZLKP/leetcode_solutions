-spec find_all_people(N :: integer(), Meetings :: [[integer()]], FirstPerson :: integer()) -> [integer()].
find_all_people(N, Meetings, FirstPerson) ->
    RawData = [{T, X, Y} || [X, Y, T] <- Meetings],
    SortedMeetings = lists:keysort(1, RawData),
    KnownSet = gb_sets:from_list([0, FirstPerson]),
    FinalSet = solve_timeline(SortedMeetings, KnownSet),
    gb_sets:to_list(FinalSet).

solve_timeline([], KnownSet) ->
    KnownSet;
solve_timeline([{Time, X, Y} | Rest], KnownSet) ->
    {Batch, NextRest} = collect_batch(Time, Rest, [{X, Y}]),
    NewKnownSet = process_batch(Batch, KnownSet),
    solve_timeline(NextRest, NewKnownSet).

collect_batch(Time, [{T, X, Y} | Rest], Acc) when T =:= Time ->
    collect_batch(Time, Rest, [{X, Y} | Acc]);
collect_batch(_Time, Rest, Acc) ->
    {Acc, Rest}.

process_batch(Batch, KnownSet) ->
    Graph = build_graph(Batch, maps:new()),
    NodesInBatch = maps:keys(Graph),
    Seeds = [P || P <- NodesInBatch, gb_sets:is_member(P, KnownSet)],
    case Seeds of
        [] -> 
            KnownSet;
        _ ->
            dfs_component(Seeds, Graph, KnownSet)
    end.

build_graph([], Map) -> Map;
build_graph([{U, V} | Rest], Map) ->
    Map1 = add_edge(U, V, Map),
    Map2 = add_edge(V, U, Map1),
    build_graph(Rest, Map2).

add_edge(U, V, Map) ->
    case maps:find(U, Map) of
        {ok, Neighbors} -> maps:put(U, [V | Neighbors], Map);
        error -> maps:put(U, [V], Map)
    end.

dfs_component([], _Graph, KnownSet) ->
    KnownSet;
dfs_component([Node | RestSeeds], Graph, KnownSet) ->
    Neighbors = maps:get(Node, Graph, []),
    UnknownNeighbors = [N || N <- Neighbors, not gb_sets:is_member(N, KnownSet)],
    case UnknownNeighbors of
        [] ->
            dfs_component(RestSeeds, Graph, KnownSet);
        _ ->
            NewKnownSet = lists:foldl(fun(N, Set) -> gb_sets:add(N, Set) end, KnownSet, UnknownNeighbors),
            NewStack = UnknownNeighbors ++ RestSeeds,
            dfs_component(NewStack, Graph, NewKnownSet)
    end.
    