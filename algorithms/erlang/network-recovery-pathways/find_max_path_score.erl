-spec find_max_path_score(Edges :: [[integer()]], Online :: [boolean()], K :: integer()) -> integer().
find_max_path_score(Edges, Online, K) ->
    N = length(Online),
    TargetNode = N - 1,
    OnlineT = list_to_tuple(Online),
    ValidEdges = [{U, V, Cost} || [U, V, Cost] <- Edges, 
                                  element(U + 1, OnlineT), 
                                  element(V + 1, OnlineT)],
    Adj = lists:foldl(
        fun({U, V, Cost}, Acc) ->
            maps:update_with(U, fun(L) -> [{V, Cost} | L] end, [{V, Cost}], Acc)
        end,
        #{},
        ValidEdges
    ),
    {Visited, TopoOrder} = dfs(0, {#{}, []}, Adj),
    case maps:is_key(TargetNode, Visited) of
        false -> -1;
        true ->
            Costs = [Cost || {_, _, Cost} <- ValidEdges],
            UniqueCosts = lists:usort(Costs),
            CostT = list_to_tuple(UniqueCosts),
            bs(1, tuple_size(CostT), CostT, Adj, TopoOrder, TargetNode, K, -1)
    end.

dfs(Node, {Visited, Order}, Adj) ->
    case maps:is_key(Node, Visited) of
        true -> {Visited, Order};
        false ->
            Visited1 = maps:put(Node, true, Visited),
            Neighbors = maps:get(Node, Adj, []),
            {Visited2, Order1} = lists:foldl(
                fun({V, _Cost}, Acc) ->
                    dfs(V, Acc, Adj)
                end,
                {Visited1, Order},
                Neighbors
            ),
            {Visited2, [Node | Order1]}
    end.

bs(L, R, _CostT, _Adj, _TopoOrder, _TargetNode, _K, Best) when L > R ->
    Best;
bs(L, R, CostT, Adj, TopoOrder, TargetNode, K, Best) ->
    Mid = L + (R - L) div 2,
    MinCost = element(Mid, CostT),
    Dist = check_path(TopoOrder, Adj, MinCost, K, #{0 => 0}),
    case maps:is_key(TargetNode, Dist) of
        true ->
            bs(Mid + 1, R, CostT, Adj, TopoOrder, TargetNode, K, MinCost);
        false ->
            bs(L, Mid - 1, CostT, Adj, TopoOrder, TargetNode, K, Best)
    end.

check_path([], _Adj, _MinCost, _K, Dist) -> Dist;
check_path([U | Rest], Adj, MinCost, K, Dist) ->
    case maps:find(U, Dist) of
        {ok, Du} ->
            Neighbors = maps:get(U, Adj, []),
            NewDist = update_neighbors(Neighbors, MinCost, K, Du, Dist),
            check_path(Rest, Adj, MinCost, K, NewDist);
        error ->
            check_path(Rest, Adj, MinCost, K, Dist)
    end.

update_neighbors([], _MinCost, _K, _Du, Dist) -> Dist;
update_neighbors([{V, Cost} | Rest], MinCost, K, Du, Dist) ->
    if Cost >= MinCost ->
        NewV = Du + Cost;
       true ->
        NewV = infinity
    end,
    if NewV =< K ->
        OldV = maps:get(V, Dist, infinity),
        if NewV < OldV ->
            update_neighbors(Rest, MinCost, K, Du, maps:put(V, NewV, Dist));
           true ->
            update_neighbors(Rest, MinCost, K, Du, Dist)
        end;
       true ->
        update_neighbors(Rest, MinCost, K, Du, Dist)
    end.