-spec sum_and_multiply(N :: integer()) -> integer().
sum_and_multiply(N) ->
    Str = integer_to_list(N),
    {X, Sum} = lists:foldl(
        fun
            ($0, Acc) -> Acc;
            (C, {AccX, AccSum}) ->
                Val = C - $0,
                {AccX * 10 + Val, AccSum + Val}
        end,
        {0, 0},
        Str
    ),
    X * Sum.