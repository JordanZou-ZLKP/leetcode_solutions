-spec min_jumps(Nums :: [integer()]) -> integer().

min_jumps([_]) -> 0;
min_jumps(Nums) ->
    N = length(Nums),
    PrimeToIndices = build_map(Nums, 1, #{}),
    T = list_to_tuple(Nums),
    Queue = queue:in({1, 0}, queue:new()),
    VisitedIdx = #{1 => true},
    VisitedPrime = #{},
    bfs(Queue, VisitedIdx, VisitedPrime, T, PrimeToIndices, N).

build_map([], _, Map) -> Map;
build_map([X | Rest], Idx, Map) ->
    Factors = factors(X),
    NewMap = lists:foldl(fun(F, Acc) ->
        Acc#{F => [Idx | maps:get(F, Acc, [])]}
    end, Map, Factors),
    build_map(Rest, Idx + 1, NewMap).

factors(X) -> factors(X, 2, []).
factors(1, _, Acc) -> Acc;
factors(X, 2, Acc) when X rem 2 == 0 -> factors(remove_factor(X, 2), 3, [2 | Acc]);
factors(X, 2, Acc) -> factors(X, 3, Acc);
factors(X, P, Acc) when P * P > X -> [X | Acc];
factors(X, P, Acc) when X rem P == 0 -> factors(remove_factor(X, P), P + 2, [P | Acc]);
factors(X, P, Acc) -> factors(X, P + 2, Acc).

remove_factor(X, P) when X rem P == 0 -> remove_factor(X div P, P);
remove_factor(X, _) -> X.

is_prime(1) -> false;
is_prime(2) -> true;
is_prime(3) -> true;
is_prime(X) when X < 2; X rem 2 == 0 -> false;
is_prime(X) -> is_prime(X, 3).
is_prime(X, P) when P * P > X -> true;
is_prime(X, P) when X rem P == 0 -> false;
is_prime(X, P) -> is_prime(X, P + 2).

bfs(Queue, VisitedIdx, VisitedPrime, T, PrimeToIndices, TargetN) ->
    case queue:out(Queue) of
        {empty, _} -> -1;
        {{value, {Idx, Steps}}, Q1} ->
            Neighbors1 = if Idx > 1 -> [Idx - 1]; true -> [] end ++
                         if Idx < TargetN -> [Idx + 1]; true -> [] end,
            Val = element(Idx, T),
            {Neighbors2, VP2} = case is_prime(Val) of
                true ->
                    case maps:is_key(Val, VisitedPrime) of
                        true -> {Neighbors1, VisitedPrime};
                        false ->
                            Muls = maps:get(Val, PrimeToIndices, []),
                            {Neighbors1 ++ Muls, VisitedPrime#{Val => true}}
                    end;
                false -> {Neighbors1, VisitedPrime}
            end,
            case process_neighbors(Neighbors2, Q1, VisitedIdx, Steps, TargetN) of
                {found, Ans} -> Ans;
                {Q2, VI2, -1} -> bfs(Q2, VI2, VP2, T, PrimeToIndices, TargetN)
            end
    end.

process_neighbors([], Q, VI, _Steps, _TargetN) ->
    {Q, VI, -1};
process_neighbors([TargetN | _], _Q, _VI, Steps, TargetN) ->
    {found, Steps + 1};
process_neighbors([NextIdx | Rest], Q, VI, Steps, TargetN) ->
    case maps:is_key(NextIdx, VI) of
        true -> process_neighbors(Rest, Q, VI, Steps, TargetN);
        false ->
            process_neighbors(Rest, queue:in({NextIdx, Steps + 1}, Q), VI#{NextIdx => true}, Steps, TargetN)
    end.