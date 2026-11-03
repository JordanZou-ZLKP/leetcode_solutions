-spec min_moves(Nums :: [integer()]) -> integer().
min_moves([H|T]) ->
    {Max, Sum, Len} = calc(T, H, H, 1),
    Max * Len - Sum.

calc([H|T], Max, Sum, Len) ->
    NewMax = if H > Max -> H; true -> Max end,
    calc(T, NewMax, Sum + H, Len + 1);
calc([], Max, Sum, Len) ->
    {Max, Sum, Len}.

