-spec count_submatrices(Grid :: [[integer()]], K :: integer()) -> integer().
count_submatrices(Grid, K) ->
    InitColSums = [0 || _ <- hd(Grid)],
    count_submatrices(Grid, InitColSums, K, 0).

count_submatrices([], _, _, TotalCount) ->
    TotalCount;
count_submatrices([Row | Rest], ColSums, K, TotalCount) ->
    {NewColSums, NewTotalCount} = process_row(Row, ColSums, 0, [], TotalCount, K),
    case NewColSums of
        [] -> NewTotalCount;
        _ -> count_submatrices(Rest, lists:reverse(NewColSums), K, NewTotalCount)
    end.

process_row([], _, _, AccCols, Count, _) ->
    {AccCols, Count};
process_row(_, [], _, AccCols, Count, _) ->
    {AccCols, Count};
process_row([X | Xs], [C | Cs], RowSum, AccCols, Count, K) ->
    NewC = C + X,
    NewRowSum = RowSum + NewC,
    if
        NewRowSum =< K ->
            process_row(Xs, Cs, NewRowSum, [NewC | AccCols], Count + 1, K);
        true ->
            {AccCols, Count}
    end.