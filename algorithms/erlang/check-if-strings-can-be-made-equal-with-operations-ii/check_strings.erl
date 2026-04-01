-spec check_strings(S1 :: unicode:unicode_binary(), S2 :: unicode:unicode_binary()) -> boolean().
check_strings(S1, S2) ->
    count(S1, 0, #{}, #{}) =:= count(S2, 0, #{}, #{}).

count(<<C, Rest/binary>>, 0, Even, Odd) ->
    count(Rest, 1, Even#{C => maps:get(C, Even, 0) + 1}, Odd);
count(<<C, Rest/binary>>, 1, Even, Odd) ->
    count(Rest, 0, Even, Odd#{C => maps:get(C, Odd, 0) + 1});
count(<<>>, _, Even, Odd) ->
    {Even, Odd}.