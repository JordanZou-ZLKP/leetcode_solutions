-spec number_of_special_chars(Word :: unicode:unicode_binary()) -> integer().
number_of_special_chars(Word) ->
    count_chars(Word, 0, 0).

count_chars(<<C, Rest/binary>>, L, U) when C >= $a ->
    count_chars(Rest, L bor (1 bsl (C - $a)), U);
count_chars(<<C, Rest/binary>>, L, U) ->
    count_chars(Rest, L, U bor (1 bsl (C - $A)));
count_chars(<<>>, L, U) ->
    popcount(L band U).

popcount(0) ->
    0;
popcount(N) ->
    1 + popcount(N band (N - 1)).