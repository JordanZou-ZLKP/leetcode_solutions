-spec closed_island(Grid :: [[integer()]]) -> integer().
closed_island([]) ->
    0;
closed_island(Grid) ->
    M = length(Grid),
    N = length(hd(Grid)),
    Map = build_map(Grid, 0, #{}),
    count_closed(Map, maps:keys(Map), 0, M, N).

build_map([], _, Map) ->
    Map;
build_map([Row | Rest], R, Map) ->
    NewMap = build_row(Row, R, 0, Map),
    build_map(Rest, R + 1, NewMap).

build_row([], _, _, Map) ->
    Map;
build_row([0 | Rest], R, C, Map) ->
    build_row(Rest, R, C + 1, maps:put({R, C}, true, Map));
build_row([1 | Rest], R, C, Map) ->
    build_row(Rest, R, C + 1, Map).

count_closed(_, [], Count, _, _) ->
    Count;
count_closed(Map, [Key | Rest], Count, M, N) ->
    case maps:is_key(Key, Map) of
        true ->
            {IsClosed, NewMap} = dfs([Key], Map, true, M, N),
            NewCount = if IsClosed -> Count + 1; true -> Count end,
            count_closed(NewMap, Rest, NewCount, M, N);
        false ->
            count_closed(Map, Rest, Count, M, N)
    end.

dfs([], Map, IsClosed, _, _) ->
    {IsClosed, Map};
dfs([{R, C} | Stack], Map, IsClosed, M, N) ->
    case maps:take({R, C}, Map) of
        error ->
            dfs(Stack, Map, IsClosed, M, N);
        {_, Map1} ->
            CurrentClosed = (R > 0) andalso (R < M - 1) andalso (C > 0) andalso (C < N - 1),
            Neighbors = [{R + 1, C}, {R - 1, C}, {R, C + 1}, {R, C - 1}],
            dfs(Neighbors ++ Stack, Map1, IsClosed andalso CurrentClosed, M, N)
    end.

