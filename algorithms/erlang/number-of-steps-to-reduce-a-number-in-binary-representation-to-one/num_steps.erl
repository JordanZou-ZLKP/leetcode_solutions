-spec num_steps(S :: unicode:unicode_binary()) -> integer().

num_steps(<<$1>>) ->
    0;
num_steps(<<$1, Rest/binary>>) ->
    Reversed = lists:reverse(binary_to_list(Rest)),
    calc_steps(Reversed, 0, 0).

calc_steps([], Carry, Steps) ->
    Steps + Carry;
calc_steps([$0 | T], 0, Steps) ->
    calc_steps(T, 0, Steps + 1);
calc_steps([$1 | T], 0, Steps) ->
    calc_steps(T, 1, Steps + 2);
calc_steps([$0 | T], 1, Steps) ->
    calc_steps(T, 1, Steps + 2);
calc_steps([$1 | T], 1, Steps) ->
    calc_steps(T, 1, Steps + 1).