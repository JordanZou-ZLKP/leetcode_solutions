-spec count_covered_buildings(N :: integer(), Buildings :: [[integer()]]) -> integer().
count_covered_buildings(N, Buildings) ->
    {RowMin, RowMax, ColMin, ColMax} = 
        lists:foldl(fun update_maps/2, {#{}, #{}, #{}, #{}}, Buildings),
    Count = lists:foldl(fun([X, Y], Acc) ->
        MinCol = maps:get(X, RowMin),
        MaxCol = maps:get(X, RowMax),
        MinRow = maps:get(Y, ColMin),
        MaxRow = maps:get(Y, ColMax),
        if 
            MinCol < Y andalso MaxCol > Y andalso MinRow < X andalso MaxRow > X ->
                Acc + 1;
            true ->
                Acc
        end
    end, 0, Buildings),
    Count.

update_maps([X, Y], {RowMin, RowMax, ColMin, ColMax}) ->
    NewRowMin = update_min_map(RowMin, X, Y),
    NewRowMax = update_max_map(RowMax, X, Y),
    NewColMin = update_min_map(ColMin, Y, X),
    NewColMax = update_max_map(ColMax, Y, X),
    {NewRowMin, NewRowMax, NewColMin, NewColMax}.

update_min_map(Map, Key, Value) ->
    case maps:find(Key, Map) of
        error -> 
            maps:put(Key, Value, Map);
        {ok, OldValue} when Value < OldValue ->
            maps:put(Key, Value, Map);
        {ok, _} ->
            Map
    end.

update_max_map(Map, Key, Value) ->
    case maps:find(Key, Map) of
        error -> 
            maps:put(Key, Value, Map);
        {ok, OldValue} when Value > OldValue ->
            maps:put(Key, Value, Map);
        {ok, _} ->
            Map
    end.