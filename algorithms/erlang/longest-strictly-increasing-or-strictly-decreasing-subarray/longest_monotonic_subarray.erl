-spec longest_monotonic_subarray(Nums :: [integer()]) -> integer().
longest_monotonic_subarray([]) ->
    0;
longest_monotonic_subarray([H | T]) ->
    find_longest(T, H, 1, 1, 1).

find_longest([], _, _, _, Max) ->
    Max;
find_longest([H | T], Prev, Inc, _, Max) when H > Prev ->
    NewInc = Inc + 1,
    NewMax = max(Max, NewInc),
    find_longest(T, H, NewInc, 1, NewMax);
find_longest([H | T], Prev, _, Dec, Max) when H < Prev ->
    NewDec = Dec + 1,
    NewMax = max(Max, NewDec),
    find_longest(T, H, 1, NewDec, NewMax);
find_longest([H | T], _, _, _, Max) ->
    find_longest(T, H, 1, 1, Max).
