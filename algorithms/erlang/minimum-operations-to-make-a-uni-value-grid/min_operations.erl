-spec min_operations(Grid :: [[integer()]], X :: integer()) -> integer().
min_operations(Grid, X) ->
    Flat = [V || R <- Grid, V <- R],
    [First | _] = Flat,
    Rem = First rem X,
    case lists:all(fun(E) -> E rem X =:= Rem end, Flat) of
        false -> -1;
        true ->
            Sorted = lists:sort(Flat),
            Len = length(Sorted),
            Median = lists:nth(Len div 2 + 1, Sorted),
            lists:foldl(fun(E, Acc) -> Acc + abs(E - Median) div X end, 0, Sorted)
    end.