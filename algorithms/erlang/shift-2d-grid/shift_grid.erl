-spec shift_grid(Grid :: [[integer()]], K :: integer()) -> [[integer()]].
shift_grid(Grid, K) ->
    Flat = lists:flatten(Grid),
    Total = length(Flat),
    Cols = length(hd(Grid)),
    Shift = K rem Total,
    {P1, P2} = lists:split(Total - Shift, Flat),
    rebuild(P2 ++ P1, Cols).

rebuild([], _) ->
    [];
rebuild(List, Cols) ->
    {Row, Rest} = lists:split(Cols, List),
    [Row | rebuild(Rest, Cols)].