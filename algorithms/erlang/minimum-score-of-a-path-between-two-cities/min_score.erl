-spec min_score(N :: integer(), Roads :: [[integer()]]) -> integer().
min_score(N, Roads) ->
    Graph = build_graph(Roads, maps:new()),
    dfs([1], Graph, #{1 => true}, 1000000).

build_graph([], Graph) ->
    Graph;
build_graph([[U, V, D] | Rest], Graph) ->
    G1 = maps:update_with(U, fun(Edges) -> [{V, D} | Edges] end, [{V, D}], Graph),
    G2 = maps:update_with(V, fun(Edges) -> [{U, D} | Edges] end, [{U, D}], G1),
    build_graph(Rest, G2).

dfs([], _Graph, _Visited, MinScore) ->
    MinScore;
dfs([Node | Stack], Graph, Visited, MinScore) ->
    Edges = maps:get(Node, Graph, []),
    {NewStack, NewVisited, NewMinScore} = process_edges(Edges, Stack, Visited, MinScore),
    dfs(NewStack, Graph, NewVisited, NewMinScore).

process_edges([], Stack, Visited, MinScore) ->
    {Stack, Visited, MinScore};
process_edges([{Neighbor, D} | Rest], Stack, Visited, MinScore) ->
    NextMin = erlang:min(MinScore, D),
    case maps:is_key(Neighbor, Visited) of
        true ->
            process_edges(Rest, Stack, Visited, NextMin);
        false ->
            process_edges(Rest, [Neighbor | Stack], Visited#{Neighbor => true}, NextMin)
    end.