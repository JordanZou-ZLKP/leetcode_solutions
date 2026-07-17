-spec gcd_values(Nums :: [integer()], Queries :: [integer()]) -> [integer()].
gcd_values(Nums, Queries) ->
    FreqMap = lists:foldl(fun(X, Acc) ->
        maps:update_with(X, fun(V) -> V + 1 end, 1, Acc)
    end, #{}, Nums),
    MaxNum = lists:max(Nums),
    ExactMap = build_exact(MaxNum, FreqMap, MaxNum, #{}),
    PrefixList = build_prefix(1, MaxNum, ExactMap, 0, []),
    PrefixTuple = erlang:list_to_tuple(PrefixList),
    lists:map(fun(Q) -> binary_search(PrefixTuple, Q, 1, tuple_size(PrefixTuple)) end, Queries).

build_exact(0, _, _, ExactMap) -> 
    ExactMap;
build_exact(X, FreqMap, MaxNum, ExactMap) ->
    CntX = count_multiples(X, X, FreqMap, MaxNum, 0),
    PairsX = (CntX * (CntX - 1)) div 2,
    ExactX = subtract_multiples(X + X, X, MaxNum, ExactMap, PairsX),
    build_exact(X - 1, FreqMap, MaxNum, maps:put(X, ExactX, ExactMap)).

count_multiples(Curr, _, _, MaxNum, Acc) when Curr > MaxNum -> 
    Acc;
count_multiples(Curr, Step, FreqMap, MaxNum, Acc) ->
    Count = case maps:find(Curr, FreqMap) of
        {ok, V} -> V;
        error -> 0
    end,
    count_multiples(Curr + Step, Step, FreqMap, MaxNum, Acc + Count).

subtract_multiples(Curr, _, MaxNum, _, Acc) when Curr > MaxNum -> 
    Acc;
subtract_multiples(Curr, Step, MaxNum, ExactMap, Acc) ->
    Val = case maps:find(Curr, ExactMap) of
        {ok, V} -> V;
        error -> 0
    end,
    subtract_multiples(Curr + Step, Step, MaxNum, ExactMap, Acc - Val).

build_prefix(X, MaxNum, _, _, Acc) when X > MaxNum -> 
    lists:reverse(Acc);
build_prefix(X, MaxNum, ExactMap, Sum, Acc) ->
    Val = case maps:find(X, ExactMap) of
        {ok, V} -> V;
        error -> 0
    end,
    if Val > 0 ->
        NewSum = Sum + Val,
        build_prefix(X + 1, MaxNum, ExactMap, NewSum, [{NewSum, X} | Acc]);
       true ->
        build_prefix(X + 1, MaxNum, ExactMap, Sum, Acc)
    end.

binary_search(Tuple, Q, Low, High) when Low =< High ->
    Mid = Low + (High - Low) div 2,
    {Sum, GCD} = element(Mid, Tuple),
    if Sum > Q ->
        if Mid == 1 -> GCD;
           true ->
            {PrevSum, _} = element(Mid - 1, Tuple),
            if PrevSum =< Q -> GCD;
               true -> binary_search(Tuple, Q, Low, Mid - 1)
            end
        end;
       true ->
        binary_search(Tuple, Q, Mid + 1, High)
    end.