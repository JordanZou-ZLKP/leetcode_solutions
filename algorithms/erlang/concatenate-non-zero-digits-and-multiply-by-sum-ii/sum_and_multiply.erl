-spec sum_and_multiply(S :: unicode:unicode_binary(), Queries :: [[integer()]]) -> [integer()].
sum_and_multiply(S, Queries) ->
    M = 1000000007,
    {CountAcc, SumAcc, ValAcc} = build_prefix(S, 0, 0, 0, [], [0], [0], M),
    CountTuple = erlang:list_to_tuple(lists:reverse(CountAcc)),
    SumTuple = erlang:list_to_tuple(lists:reverse(SumAcc)),
    ValTuple = erlang:list_to_tuple(lists:reverse(ValAcc)),
    TotalNonZeros = erlang:tuple_size(SumTuple) - 1,
    Pow10Tuple = erlang:list_to_tuple(build_pow10(TotalNonZeros, 1, [], M)),
    [process_query(Q, CountTuple, SumTuple, ValTuple, Pow10Tuple, M) || Q <- Queries].

build_prefix(<<>>, _Count, _Sum, _Val, CAcc, SAcc, VAcc, _M) ->
    {CAcc, SAcc, VAcc};
build_prefix(<<$0, Rest/binary>>, Count, Sum, Val, CAcc, SAcc, VAcc, M) ->
    build_prefix(Rest, Count, Sum, Val, [Count | CAcc], SAcc, VAcc, M);
build_prefix(<<C, Rest/binary>>, Count, Sum, Val, CAcc, SAcc, VAcc, M) ->
    Digit = C - $0,
    NCount = Count + 1,
    NSum = Sum + Digit,
    NVal = (Val * 10 + Digit) rem M,
    build_prefix(Rest, NCount, NSum, NVal, [NCount | CAcc], [NSum | SAcc], [NVal | VAcc], M).

build_pow10(-1, _P, Acc, _M) -> 
    lists:reverse(Acc);
build_pow10(K, P, Acc, M) ->
    build_pow10(K - 1, (P * 10) rem M, [P | Acc], M).

process_query([L, R], CountTuple, SumTuple, ValTuple, Pow10Tuple, M) ->
    CR = erlang:element(R + 1, CountTuple),
    CL = if L == 0 -> 0; true -> erlang:element(L, CountTuple) end,
    if
        CL == CR -> 0;
        true ->
            Len = CR - CL,
            SumR = erlang:element(CR + 1, SumTuple),
            SumL = erlang:element(CL + 1, SumTuple),
            TotalSum = SumR - SumL,
            ValR = erlang:element(CR + 1, ValTuple),
            ValL = erlang:element(CL + 1, ValTuple),
            P10 = erlang:element(Len + 1, Pow10Tuple),
            X = (ValR - ((ValL * P10) rem M) + M) rem M,
            (X * TotalSum) rem M
    end.