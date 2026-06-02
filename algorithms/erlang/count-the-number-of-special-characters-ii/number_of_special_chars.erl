-spec number_of_special_chars(Word :: unicode:unicode_binary()) -> integer().
number_of_special_chars(Word) ->
    loop(Word, 0, 0, 0).

loop(<<Char/utf8, Rest/binary>>, SL, SU, INV) when Char >= $a, Char =< $z ->
    Bit = 1 bsl (Char - $a),
    loop(Rest, SL bor Bit, SU, INV bor (SU band Bit));
loop(<<Char/utf8, Rest/binary>>, SL, SU, INV) when Char >= $A, Char =< $Z ->
    Bit = 1 bsl (Char - $A),
    loop(Rest, SL, SU bor Bit, INV);
loop(<<_/utf8, Rest/binary>>, SL, SU, INV) ->
    loop(Rest, SL, SU, INV);
loop(<<>>, SL, SU, INV) ->
    count_bits((SL band SU) band (bnot INV), 0).

count_bits(0, Acc) -> Acc;
count_bits(N, Acc) -> count_bits(N band (N - 1), Acc + 1).