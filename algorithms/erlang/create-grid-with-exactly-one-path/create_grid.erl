-spec create_grid(M :: integer(), N :: integer()) -> [unicode:unicode_binary()].
create_grid(M, N) ->
    First = list_to_binary(lists:duplicate(N, $.)),
    Rest = list_to_binary(lists:duplicate(N - 1, $#) ++ [$.]),
    [First | lists:duplicate(M - 1, Rest)].
