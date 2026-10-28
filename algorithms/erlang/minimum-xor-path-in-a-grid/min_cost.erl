-spec min_cost(Grid :: [[integer()]]) -> integer().
min_cost([Row1 | RestRows]) ->
    [H | T] = Row1,
    InitFirstRow = build_first_row(T, H, [[H]]),
    FinalRowState = lists:foldl(fun process_row/2, InitFirstRow, RestRows),
    lists:min(lists:last(FinalRowState)).

build_first_row([], _PrevVal, AccState) ->
    lists:reverse(AccState);
build_first_row([Val | Rest], PrevVal, AccState) ->
    NewVal = PrevVal bxor Val,
    build_first_row(Rest, NewVal, [[NewVal] | AccState]).

process_row(RowVals, PrevRowState) ->
    [Val1 | RestVals] = RowVals,
    [Prev1 | RestPrevState] = PrevRowState,
    New1 = lists:usort([X bxor Val1 || X <- Prev1]),
    process_cells(RestVals, RestPrevState, New1, [New1]).

process_cells([], [], _LeftState, AccRowState) ->
    lists:reverse(AccRowState);
process_cells([Val | RestVals], [UpState | RestUpState], LeftState, AccRowState) ->
    NewState = lists:usort([X bxor Val || X <- LeftState ++ UpState]),
    process_cells(RestVals, RestUpState, NewState, [NewState | AccRowState]).

