-spec min_operations(S :: unicode:unicode_binary(), K :: integer()) -> integer().
min_operations(S, K) ->
    N = byte_size(S),
    Z = count_zeros(S, 0),
    solve(Z, Z, N, K, 0).

count_zeros(<<>>, Acc) ->
    Acc;
count_zeros(<<$0, Rest/binary>>, Acc) ->
    count_zeros(Rest, Acc + 1);
count_zeros(<<_, Rest/binary>>, Acc) ->
    count_zeros(Rest, Acc).

solve(0, _, _, _, Steps) ->
    Steps;
solve(_, _, N, _, Steps) when Steps > N ->
    -1;
solve(L, R, N, K, Steps) ->
    LNext = next_l(L, R, K),
    RNext = next_r(L, R, N, K),
    solve(LNext, RNext, N, K, Steps + 1).

next_l(L, R, K) ->
    if
        K < L -> L - K;
        K > R -> K - R;
        (K - L) rem 2 =:= 0 -> 0;
        true -> 1
    end.

next_r(L, R, N, K) ->
    LOnes = N - R,
    ROnes = N - L,
    MinOnes = if
        K < LOnes -> LOnes - K;
        K > ROnes -> K - ROnes;
        (K - LOnes) rem 2 =:= 0 -> 0;
        true -> 1
    end,
    N - MinOnes.