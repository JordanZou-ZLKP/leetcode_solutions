-spec count_islands(Grid :: [[integer()]], K :: integer()) -> integer().
count_islands(Grid, K) ->
    Map = build_map(Grid, 0, #{}),
    count_valid(Map, K, maps:keys(Map), 0).

build_map([], _, Map) ->
    Map;
build_map([Row | Rest], R, Map) ->
    NewMap = build_row(Row, R, 0, Map),
    build_map(Rest, R + 1, NewMap).

build_row([], _, _, Map) ->
    Map;
build_row([0 | Rest], R, C, Map) ->
    build_row(Rest, R, C + 1, Map);
build_row([V | Rest], R, C, Map) ->
    build_row(Rest, R, C + 1, maps:put({R, C}, V, Map)).

count_valid(_, _, [], Count) ->
    Count;
count_valid(Map, K, [Key | Rest], Count) ->
    case maps:is_key(Key, Map) of
        true ->
            {Sum, NewMap} = dfs([Key], Map, 0),
            NewCount = if Sum rem K =:= 0 -> Count + 1; true -> Count end,
            count_valid(NewMap, K, Rest, NewCount);
        false ->
            count_valid(Map, K, Rest, Count)
    end.

dfs([], Map, Sum) ->
    {Sum, Map};
dfs([{R, C} | Stack], Map, Sum) ->
    case maps:take({R, C}, Map) of
        error ->
            dfs(Stack, Map, Sum);
        {V, Map1} ->
            Neighbors = [{R+1, C}, {R-1, C}, {R, C+1}, {R, C-1}],
            dfs(Neighbors ++ Stack, Map1, Sum + V)
    end.

