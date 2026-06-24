-spec zig_zag_arrays(N :: integer(), L :: integer(), R :: integer()) -> integer().
zig_zag_arrays(N, L, R) ->
    M = R - L + 1,
    T = build_T(M),
    V0 = build_V0(M),
    TN_minus_2 = mat_pow(T, N - 2, M),
    VN_minus_2 = mat_vec_mul(TN_minus_2, V0, M),
    Total = sum_tuple(VN_minus_2, M, 1, 0),
    (Total * 2) rem 1000000007.

build_T(M) ->
    list_to_tuple(
        [list_to_tuple(
            [if C > M - R + 1 -> 1; true -> 0 end || C <- lists:seq(1, M)]
        ) || R <- lists:seq(1, M)]
    ).

build_V0(M) ->
    list_to_tuple([V - 1 || V <- lists:seq(1, M)]).

identity_matrix(M) ->
    list_to_tuple(
        [list_to_tuple(
            [if R =:= C -> 1; true -> 0 end || C <- lists:seq(1, M)]
        ) || R <- lists:seq(1, M)]
    ).

transpose(Mat, M) ->
    list_to_tuple(
        [list_to_tuple(
            [element(C, element(R, Mat)) || R <- lists:seq(1, M)]
        ) || C <- lists:seq(1, M)]
    ).

matrix_mul_T(A, B_T, M) ->
    list_to_tuple(
        [list_to_tuple(
            [dot_product(element(R, A), element(C, B_T), M, 1, 0) || C <- lists:seq(1, M)]
        ) || R <- lists:seq(1, M)]
    ).

dot_product(RowA, ColB, M, K, Acc) when K > M ->
    Acc rem 1000000007;
dot_product(RowA, ColB, M, K, Acc) ->
    dot_product(RowA, ColB, M, K + 1, Acc + element(K, RowA) * element(K, ColB)).

mat_pow(_Base, 0, M) ->
    identity_matrix(M);
mat_pow(Base, 1, _M) ->
    Base;
mat_pow(Base, P, M) ->
    Half = mat_pow(Base, P div 2, M),
    Half_T = transpose(Half, M),
    HalfSq = matrix_mul_T(Half, Half_T, M),
    case P rem 2 of
        0 -> HalfSq;
        1 ->
            HalfSq_T = transpose(HalfSq, M),
            matrix_mul_T(Base, HalfSq_T, M)
    end.

mat_vec_mul(A, V, M) ->
    list_to_tuple(
        [dot_product(element(R, A), V, M, 1, 0) || R <- lists:seq(1, M)]
    ).

sum_tuple(_Tuple, M, K, Acc) when K > M ->
    Acc rem 1000000007;
sum_tuple(Tuple, M, K, Acc) ->
    sum_tuple(Tuple, M, K + 1, Acc + element(K, Tuple)).