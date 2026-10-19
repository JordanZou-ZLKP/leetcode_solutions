-spec target_indices(Nums :: [integer()], Target :: integer()) -> [integer()].
target_indices(Nums, Target) ->
    {Less, Equal} = count_nums(Nums, Target, 0, 0),
    if
        Equal =:= 0 -> [];
        true -> lists:seq(Less, Less + Equal - 1)
    end.

count_nums([], _Target, Less, Equal) ->
    {Less, Equal};
count_nums([H | T], Target, Less, Equal) when H < Target ->
    count_nums(T, Target, Less + 1, Equal);
count_nums([H | T], Target, Less, Equal) when H =:= Target ->
    count_nums(T, Target, Less, Equal + 1);
count_nums([_H | T], Target, Less, Equal) ->
    count_nums(T, Target, Less, Equal).

