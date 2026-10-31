-spec unique_paths(Grid :: [[integer()]]) -> integer().
unique_paths([FirstRow | RestRows]) ->
    N = length(FirstRow),
    InitialDPD = lists:duplicate(N, 0),
    DPD1 = process_row(FirstRow, InitialDPD, 1, []),
    FinalDPD = process_grid(RestRows, DPD1),
    lists:last(FinalDPD).

process_grid([], DPD) ->
    DPD;
process_grid([Row | Rest], DPD) ->
    NextDPD = process_row(Row, DPD, 0, []),
    process_grid(Rest, NextDPD).

process_row([], [], _CurrR, AccDPD) ->
    lists:reverse(AccDPD);
process_row([0 | RestCells], [DPD | RestDPD], CurrR, AccDPD) ->
    Total = (CurrR + DPD) rem 1000000007,
    process_row(RestCells, RestDPD, Total, [Total | AccDPD]);
process_row([1 | RestCells], [DPD | RestDPD], CurrR, AccDPD) ->
    process_row(RestCells, RestDPD, DPD, [CurrR | AccDPD]).

