-spec find_safe_walk(Grid :: [[integer()]], Health :: integer()) -> boolean().
find_safe_walk(Grid, Health) ->
    M = length(Grid),
    N = length(hd(Grid)),
    GridMap = build_map(Grid, 0, #{}),
    StartVal = maps:get({0, 0}, GridMap),
    if StartVal >= Health -> false;
       true ->
           Q = queue:in({0, 0, StartVal}, queue:new()),
           Visited = #{{0, 0} => StartVal},
           bfs(Q, Visited, GridMap, M, N, Health)
    end.

build_map([], _, Map) -> Map;
build_map([Row | Rest], R, Map) ->
    build_map(Rest, R + 1, build_row(Row, R, 0, Map)).

build_row([], _, _, Map) -> Map;
build_row([Val | Rest], R, C, Map) ->
    build_row(Rest, R, C + 1, Map#{{R, C} => Val}).

bfs(Q, Visited, GridMap, M, N, Health) ->
    case queue:out(Q) of
        {empty, _} -> false;
        {{value, {R, C, Cost}}, Q1} ->
            if R =:= M - 1, C =:= N - 1 -> true;
               true ->
                   Neighbors = [{R-1, C}, {R+1, C}, {R, C-1}, {R, C+1}],
                   {NewQ, NewVisited} = process_neighbors(Neighbors, Cost, Q1, Visited, GridMap, M, N, Health),
                   bfs(NewQ, NewVisited, GridMap, M, N, Health)
            end
    end.

process_neighbors([], _, Q, Visited, _, _, _, _) ->
    {Q, Visited};
process_neighbors([{Nr, Nc} | Rest], Cost, Q, Visited, GridMap, M, N, Health) ->
    case (Nr >= 0) andalso (Nr < M) andalso (Nc >= 0) andalso (Nc < N) of
        false -> 
            process_neighbors(Rest, Cost, Q, Visited, GridMap, M, N, Health);
        true ->
            Val = maps:get({Nr, Nc}, GridMap),
            NewCost = Cost + Val,
            case NewCost < maps:get({Nr, Nc}, Visited, infinity) andalso NewCost < Health of
                true ->
                    NewVisited = Visited#{{Nr, Nc} => NewCost},
                    NewQ = case Val of
                        0 -> queue:in_r({Nr, Nc, NewCost}, Q);
                        1 -> queue:in({Nr, Nc, NewCost}, Q)
                    end,
                    process_neighbors(Rest, Cost, NewQ, NewVisited, GridMap, M, N, Health);
                false ->
                    process_neighbors(Rest, Cost, Q, Visited, GridMap, M, N, Health)
            end
    end.