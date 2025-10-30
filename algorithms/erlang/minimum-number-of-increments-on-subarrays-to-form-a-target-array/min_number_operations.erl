-spec min_number_operations(Target :: [integer()]) -> integer().
min_number_operations([]) ->
    0;
min_number_operations([Head | Tail]) ->
    min_number_operations(Tail, Head, Head).

min_number_operations([], _Prev, Acc) ->
    Acc;
min_number_operations([H | T], Prev, Acc) ->
    Diff = max(0, H - Prev),
    NewAcc = Acc + Diff,
    min_number_operations(T, H, NewAcc).