-spec max_number_of_balloons(Text :: unicode:unicode_binary()) -> integer().
max_number_of_balloons(Text) ->
    count(Text, 0, 0, 0, 0, 0).

count(<<>>, B, A, L, O, N) ->
    lists:min([B, A, L div 2, O div 2, N]);
count(<<$b, Rest/binary>>, B, A, L, O, N) ->
    count(Rest, B + 1, A, L, O, N);
count(<<$a, Rest/binary>>, B, A, L, O, N) ->
    count(Rest, B, A + 1, L, O, N);
count(<<$l, Rest/binary>>, B, A, L, O, N) ->
    count(Rest, B, A, L + 1, O, N);
count(<<$o, Rest/binary>>, B, A, L, O, N) ->
    count(Rest, B, A, L, O + 1, N);
count(<<$n, Rest/binary>>, B, A, L, O, N) ->
    count(Rest, B, A, L, O, N + 1);
count(<<_, Rest/binary>>, B, A, L, O, N) ->
    count(Rest, B, A, L, O, N).-spec max_number_of_balloons(Text :: unicode:unicode_binary()) -> integer().
max_number_of_balloons(Text) ->
  .