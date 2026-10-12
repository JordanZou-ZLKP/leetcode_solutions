-spec sum_of_squares(Nums :: [integer()]) -> integer().
sum_of_squares(Nums) ->
    N = length(Nums),
    loop(Nums, 1, N, 0).

loop([], _I, _N, Acc) ->
    Acc;
loop([H | T], I, N, Acc) when N rem I =:= 0 ->
    loop(T, I + 1, N, Acc + H * H);
loop([_ | T], I, N, Acc) ->
    loop(T, I + 1, N, Acc).
