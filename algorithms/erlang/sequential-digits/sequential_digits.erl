-spec sequential_digits(Low :: integer(), High :: integer()) -> [integer()].
sequential_digits(Low, High) ->
    MinLen = length(integer_to_list(Low)),
    MaxLen = length(integer_to_list(High)),
    Base = "123456789",
    lists:filter(
        fun(Num) -> Num >= Low andalso Num =< High end,
        [list_to_integer(lists:sublist(Base, Start, Len)) ||
            Len <- lists:seq(MinLen, MaxLen),
            Start <- lists:seq(1, 10 - Len)]
    ).