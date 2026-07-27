-spec unique_xor_triplets(Nums :: [integer()]) -> integer().
unique_xor_triplets(Nums) ->
    U = lists:usort(Nums),
    PBits = generate_pbits(U, 0),
    UBits = lists:foldl(fun(X, Acc) -> Acc bor (1 bsl X) end, 0, U),
    count_valid_t(0, 2047, U, UBits, PBits, 0).

generate_pbits([], Acc) ->
    Acc;
generate_pbits([X | Rest], Acc) ->
    NewAcc = add_pairs(X, Rest, Acc),
    generate_pbits(Rest, NewAcc).

add_pairs(_X, [], Acc) ->
    Acc;
add_pairs(X, [Y | Rest], Acc) ->
    add_pairs(X, Rest, Acc bor (1 bsl (X bxor Y))).

count_valid_t(T, Max, _U, _UBits, _PBits, Acc) when T > Max ->
    Acc;
count_valid_t(T, Max, U, UBits, PBits, Acc) ->
    case (UBits band (1 bsl T)) =/= 0 of
        true ->
            count_valid_t(T + 1, Max, U, UBits, PBits, Acc + 1);
        false ->
            case check_t(T, U, PBits) of
                true ->
                    count_valid_t(T + 1, Max, U, UBits, PBits, Acc + 1);
                false ->
                    count_valid_t(T + 1, Max, U, UBits, PBits, Acc)
            end
    end.

check_t(_T, [], _PBits) ->
    false;
check_t(T, [X | Rest], PBits) ->
    Target = T bxor X,
    case (PBits band (1 bsl Target)) =/= 0 of
        true ->
            true;
        false ->
            check_t(T, Rest, PBits)
    end.