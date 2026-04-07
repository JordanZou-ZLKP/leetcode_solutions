-spec maximum_amount(Coins :: [[integer()]]) -> integer().
maximum_amount(Coins) ->
    [FirstRow | _] = Coins,
    N = length(FirstRow),
    InitTop = lists:duplicate(N, {-1000000000, -1000000000, -1000000000}),
    InitLeft = {0, -1000000000, -1000000000},
    FinalDp = process_rows(Coins, InitTop, InitLeft),
    {R0, R1, R2} = lists:last(FinalDp),
    max(R0, max(R1, R2)).

process_rows([], PrevTop, _) ->
    PrevTop;
process_rows([Row | Rest], PrevTop, LeftBase) ->
    NewRowDp = process_row(Row, PrevTop, LeftBase, []),
    process_rows(Rest, NewRowDp, {-1000000000, -1000000000, -1000000000}).

process_row([], [], _, Acc) ->
    lists:reverse(Acc);
process_row([V | Vs], [Top | Tops], Left, Acc) ->
    {T0, T1, T2} = Top,
    {L0, L1, L2} = Left,
    B0 = max(T0, L0),
    B1 = max(T1, L1),
    B2 = max(T2, L2),
    NewDp = if
        V < 0 ->
            {add(B0, V), max(add(B1, V), B0), max(add(B2, V), B1)};
        true ->
            {add(B0, V), add(B1, V), add(B2, V)}
    end,
    process_row(Vs, Tops, NewDp, [NewDp | Acc]).

add(-1000000000, _) -> -1000000000;
add(X, V) -> X + V.