-spec minimum_pushes(Word :: unicode:unicode_binary()) -> integer().
minimum_pushes(Word) ->
    FreqMap = count_freqs(Word, #{}),
    Counts = lists:reverse(lists:sort(maps:values(FreqMap))),
    calc_pushes(Counts, 0, 0).

count_freqs(<<Char:8, Rest/binary>>, Acc) ->
    count_freqs(Rest, maps:update_with(Char, fun(V) -> V + 1 end, 1, Acc));
count_freqs(<<>>, Acc) ->
    Acc.

calc_pushes([Count | Tail], Index, Total) ->
    Multiplier = (Index div 8) + 1,
    calc_pushes(Tail, Index + 1, Total + (Count * Multiplier));
calc_pushes([], _, Total) ->
    Total.