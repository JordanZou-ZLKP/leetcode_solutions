-spec zig_zag_arrays(N :: integer(), L :: integer(), R :: integer()) -> integer().
zig_zag_arrays(1, L, R) ->
    R - L + 1;
zig_zag_arrays(N, L, R) ->
    K = R - L + 1,
    Init = lists:duplicate(K, 1),
    FinalA = step(N - 1, Init),
    Sum = lists:foldl(
        fun(X, Acc) -> (X + Acc) rem 1000000007 end, 
        0, 
        FinalA
    ),
    (Sum * 2) rem 1000000007.

step(0, A) ->
    A;
step(Count, A) ->
    NextA = fold_and_reverse(A, 0, []),
    step(Count - 1, NextA).

fold_and_reverse([], _Sum, Acc) ->
    Acc;
fold_and_reverse([H | T], Sum, Acc) ->
    NextSum = (Sum + H) rem 1000000007,
    fold_and_reverse(T, NextSum, [Sum | Acc]).