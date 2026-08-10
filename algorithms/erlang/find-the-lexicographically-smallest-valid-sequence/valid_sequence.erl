-spec valid_sequence(Word1 :: unicode:unicode_binary(), Word2 :: unicode:unicode_binary()) -> [integer()].
valid_sequence(Word1, Word2) ->
    M = byte_size(Word2),
    N = byte_size(Word1),
    SufList = build_suf(Word1, Word2, N - 1, M - 1, M, [0]),
    find_seq(Word1, Word2, 0, 0, N, M, false, SufList, []).

build_suf(_W1, _W2, -1, _J, _M, Acc) -> 
    Acc;
build_suf(W1, W2, I, J, M, Acc) ->
    if
        J >= 0 ->
            Char1 = binary:at(W1, I),
            Char2 = binary:at(W2, J),
            if
                Char1 =:= Char2 ->
                    build_suf(W1, W2, I - 1, J - 1, M, [M - J | Acc]);
                true ->
                    build_suf(W1, W2, I - 1, J, M, [M - 1 - J | Acc])
            end;
        true ->
            build_suf(W1, W2, I - 1, J, M, [M | Acc])
    end.

find_seq(_W1, _W2, _I, J, _N, M, _Changed, _SufList, Ans) when J =:= M ->
    lists:reverse(Ans);
find_seq(_W1, _W2, I, _J, N, _M, _Changed, _SufList, _Ans) when I =:= N ->
    [];
find_seq(W1, W2, I, J, N, M, Changed, [_ | NextSufList], Ans) ->
    Char1 = binary:at(W1, I),
    Char2 = binary:at(W2, J),
    if
        Char1 =:= Char2 ->
            find_seq(W1, W2, I + 1, J + 1, N, M, Changed, NextSufList, [I | Ans]);
        true ->
            [SufLen | _] = NextSufList,
            RemLen = M - 1 - J,
            if
                (not Changed) andalso (SufLen >= RemLen) ->
                    find_seq(W1, W2, I + 1, J + 1, N, M, true, NextSufList, [I | Ans]);
                true ->
                    find_seq(W1, W2, I + 1, J, N, M, Changed, NextSufList, Ans)
            end
    end.