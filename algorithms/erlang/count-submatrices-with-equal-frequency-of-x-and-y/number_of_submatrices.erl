-spec number_of_submatrices(Grid :: [[char()]]) -> integer().
number_of_submatrices(Grid) ->
    InitColSums = [{0, 0} || _ <- hd(Grid)],
    count_submatrices(Grid, InitColSums, 0).

count_submatrices([], _, TotalCount) ->
    TotalCount;
count_submatrices([Row | Rest], ColSums, TotalCount) ->
    {NewColSums, NewTotalCount} = process_row(Row, ColSums, 0, 0, [], TotalCount),
    count_submatrices(Rest, lists:reverse(NewColSums), NewTotalCount).

process_row([], [], _, _, AccCols, Count) ->
    {AccCols, Count};
process_row([C | Cs], [{PrevX, PrevY} | ColSums], RowX, RowY, AccCols, Count) ->
    NewRowX = RowX + is_x(C),
    NewRowY = RowY + is_y(C),
    NewColX = PrevX + NewRowX,
    NewColY = PrevY + NewRowY,
    NewCount = if
        NewColX =:= NewColY, NewColX > 0 -> Count + 1;
        true -> Count
    end,
    process_row(Cs, ColSums, NewRowX, NewRowY, [{NewColX, NewColY} | AccCols], NewCount).

is_x($X) -> 1;
is_x("X") -> 1;
is_x(_) -> 0.

is_y($Y) -> 1;
is_y("Y") -> 1;
is_y(_) -> 0.