-spec min_operations(Nums :: [integer()]) -> integer().
min_operations(Nums) ->
    N = length(Nums),
    if
        N =< 1 -> 0;
        true ->
            [First | Rest] = Nums,
            Idx0 = if First == 0 -> 0; true -> -1 end,
            check(Rest, First, First, 1, Idx0, 0, 0, N)
    end.

check([], First, Last, _Idx, Idx0, IncCount, DecCount, N) ->
    IncC = if First == (Last + 1) rem N -> IncCount + 1; true -> IncCount end,
    DecC = if First == (Last - 1 + N) rem N -> DecCount + 1; true -> DecCount end,
    Res1 = if
        IncC == N ->
            if
                Idx0 == 0 -> 0;
                true -> min(Idx0, N - Idx0 + 2)
            end;
        true -> infinity
    end,
    Res2 = if
        DecC == N -> min(((Idx0 + 1) rem N) + 1, N - Idx0);
        true -> infinity
    end,
    Min = min(Res1, Res2),
    if Min == infinity -> -1; true -> Min end;
check([X | Rest], First, Prev, Idx, Idx0, IncCount, DecCount, N) ->
    NextIdx0 = if X == 0 -> Idx; true -> Idx0 end,
    NextInc = if X == (Prev + 1) rem N -> IncCount + 1; true -> IncCount end,
    NextDec = if X == (Prev - 1 + N) rem N -> DecCount + 1; true -> DecCount end,
    check(Rest, First, X, Idx + 1, NextIdx0, NextInc, NextDec, N).

