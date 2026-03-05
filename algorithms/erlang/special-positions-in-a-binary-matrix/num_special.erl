-spec num_special(Mat :: [[integer()]]) -> integer().
num_special(Mat) ->
    RowSums = [lists:sum(R) || R <- Mat],
    ColSums = lists:foldl(
        fun(R, Acc) -> lists:zipwith(fun(X, Y) -> X + Y end, R, Acc) end,
        [0 || _ <- hd(Mat)],
        Mat
    ),
    count_special(Mat, RowSums, ColSums, 0).

count_special([], [], _, Acc) -> 
    Acc;
count_special([Row | RestMat], [1 | RestRowSums], ColSums, Acc) ->
    NewAcc = Acc + count_row_specials(Row, ColSums, 0),
    count_special(RestMat, RestRowSums, ColSums, NewAcc);
count_special([_ | RestMat], [_ | RestRowSums], ColSums, Acc) ->
    count_special(RestMat, RestRowSums, ColSums, Acc).

count_row_specials([], [], Acc) -> 
    Acc;
count_row_specials([1 | RestR], [1 | RestC], Acc) ->
    count_row_specials(RestR, RestC, Acc + 1);
count_row_specials([_ | RestR], [_ | RestC], Acc) ->
    count_row_specials(RestR, RestC, Acc).