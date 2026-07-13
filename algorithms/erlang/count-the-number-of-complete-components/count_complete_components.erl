-spec count_complete_components(N :: integer(), Edges :: [[integer()]]) -> integer().
count_complete_components(N, Edges) ->
    Graph = build_graph(Edges, maps:from_list([{I, []} || I <- lists:seq(0, N-1)])),
    {_, Count} = lists:foldl(
        fun(Node, {Visited, Ans}) ->
            case maps:is_key(Node, Visited) of
                true -> 
                    {Visited, Ans};
                false ->
                    {NewVisited, CompNodes} = dfs(Node, Graph, Visited#{Node => true}, [Node]),
                    V = length(CompNodes),
                    TotalDegree = lists:sum([length(maps:get(Nod, Graph)) || Nod <- CompNodes]),
                    NewAns = if TotalDegree =:= V * (V - 1) -> Ans + 1; true -> Ans end,
                    {NewVisited, NewAns}
            end
        end,
        {#{}, 0},
        lists:seq(0, N - 1)
    ),
    Count.

build_graph([], Graph) -> 
    Graph;
build_graph([[U, V] | Rest], Graph) ->
    G1 = maps:update_with(U, fun(L) -> [V | L] end, [V], Graph),
    G2 = maps:update_with(V, fun(L) -> [U | L] end, [U], G1),
    build_graph(Rest, G2).

dfs(Node, Graph, Visited, Acc) ->
    lists:foldl(
        fun(Neighbor, {CurrVisited, CurrAcc}) ->
            case maps:is_key(Neighbor, CurrVisited) of
                true -> 
                    {CurrVisited, CurrAcc};
                false ->
                    dfs(Neighbor, Graph, CurrVisited#{Neighbor => true}, [Neighbor | CurrAcc])
            end
        end,
        {Visited, Acc},
        maps:get(Node, Graph)
    ).