-spec count_binary_substrings(S :: unicode:unicode_binary()) -> integer().

count_binary_substrings(<<>>) ->
    0;
count_binary_substrings(<<First:8, Rest/binary>>) ->
    count_groups(Rest, First, 1, 0, 0).

count_groups(<<>>, _, CurrCount, PrevCount, Total) ->
    Total + erlang:min(PrevCount, CurrCount);
count_groups(<<Char:8, Rest/binary>>, Char, CurrCount, PrevCount, Total) ->
    count_groups(Rest, Char, CurrCount + 1, PrevCount, Total);
count_groups(<<Char:8, Rest/binary>>, _, CurrCount, PrevCount, Total) ->
    count_groups(Rest, Char, 1, CurrCount, Total + erlang:min(PrevCount, CurrCount)).