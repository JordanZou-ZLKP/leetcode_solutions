-spec decode_ciphertext(EncodedText :: unicode:unicode_binary(), Rows :: integer()) -> unicode:unicode_binary().

decode_ciphertext(<<>>, _) ->
    <<>>;
decode_ciphertext(EncodedText, Rows) ->
    L = byte_size(EncodedText),
    Cols = L div Rows,
    Chars = build(EncodedText, Rows, Cols, 0, 0, []),
    Bin = list_to_binary(lists:reverse(Chars)),
    Len = find_len(Bin, byte_size(Bin)),
    binary:part(Bin, 0, Len).

build(_Bin, _Rows, Cols, _Row, Col, Acc) when Col >= Cols ->
    Acc;
build(Bin, Rows, Cols, Row, Col, Acc) when Row >= Rows ->
    build(Bin, Rows, Cols, 0, Col + 1, Acc);
build(Bin, Rows, Cols, Row, Col, Acc) when Col + Row >= Cols ->
    build(Bin, Rows, Cols, 0, Col + 1, Acc);
build(Bin, Rows, Cols, Row, Col, Acc) ->
    Idx = Row * Cols + Col + Row,
    C = binary:at(Bin, Idx),
    build(Bin, Rows, Cols, Row + 1, Col, [C | Acc]).

find_len(_Bin, 0) ->
    0;
find_len(Bin, N) ->
    case binary:at(Bin, N - 1) of
        $\s -> find_len(Bin, N - 1);
        _ -> N
    end.