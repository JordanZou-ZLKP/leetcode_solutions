-spec number_of_substrings(S :: unicode:unicode_binary()) -> integer().
number_of_substrings(S) ->
    count_substrings(S, 1, 0, 0, 0, 0).

count_substrings(<<>>, _, _, _, _, Total) ->
    Total;
count_substrings(<<$a, Rest/binary>>, Idx, _, B, C, Total) ->
    count_substrings(Rest, Idx + 1, Idx, B, C, Total + min(Idx, min(B, C)));
count_substrings(<<$b, Rest/binary>>, Idx, A, _, C, Total) ->
    count_substrings(Rest, Idx + 1, A, Idx, C, Total + min(A, min(Idx, C)));
count_substrings(<<$c, Rest/binary>>, Idx, A, B, _, Total) ->
    count_substrings(Rest, Idx + 1, A, B, Idx, Total + min(A, min(B, Idx))).