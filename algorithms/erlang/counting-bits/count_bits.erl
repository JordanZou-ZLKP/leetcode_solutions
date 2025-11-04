-spec count_bits(N :: integer()) -> [integer()].
count_bits(0) ->
    [0];
count_bits(N) when N >= 0 ->
    Ans = array:new(N+1, [{default, 0}]),
    Ans1 = array:set(0, 0, Ans),
    count_bits(1, N, Ans1).

count_bits(I, N, Acc) when I =< N ->
    Value = array:get(I bsr 1, Acc) + (I band 1),
    Acc1 = array:set(I, Value, Acc),
    count_bits(I + 1, N, Acc1);
count_bits(_, _, Acc) ->
    array:to_list(Acc).