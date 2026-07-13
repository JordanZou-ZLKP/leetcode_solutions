-spec path_existence_queries(N :: integer(), Nums :: [integer()], MaxDiff :: integer(), Queries :: [[integer()]]) -> [integer()].
path_existence_queries(_N, Nums, MaxDiff, Queries) ->
    ValTuple = list_to_tuple(Nums),
    UniqueValsList = lists:usort(Nums),
    M = length(UniqueValsList),
    UniqueVals = list_to_tuple(UniqueValsList),
    ValToIdMap = maps:from_list(lists:zip(UniqueValsList, lists:seq(1, M))),
    CompTuple = list_to_tuple(build_comp(UniqueValsList, MaxDiff)),
    R_list = build_r(1, UniqueVals, M, MaxDiff, 1),
    Up0 = list_to_tuple([V || {_, V} <- R_list]),
    UpTuple = generate_ups(1, 17, [Up0], M),
    [ans_query(Q, ValTuple, ValToIdMap, CompTuple, UpTuple) || Q <- Queries].

build_comp([], _) -> 
    [];
build_comp([H|T], MaxDiff) -> 
    build_comp(T, H, 1, MaxDiff, [1]).

build_comp([], _, _, _, Acc) -> 
    lists:reverse(Acc);
build_comp([H|T], Prev, CurrComp, MaxDiff, Acc) ->
    NewComp = if H - Prev =< MaxDiff -> CurrComp; true -> CurrComp + 1 end,
    build_comp(T, H, NewComp, MaxDiff, [NewComp | Acc]).

build_r(P1, _UniqueVals, M, _MaxDiff, _P2) when P1 =:= M ->
    [{M, M}];
build_r(P1, UniqueVals, M, MaxDiff, P2) ->
    Val1 = element(P1, UniqueVals),
    NewP2 = advance_p2(Val1, UniqueVals, M, MaxDiff, P2),
    [{P1, NewP2} | build_r(P1+1, UniqueVals, M, MaxDiff, NewP2)].

advance_p2(Val1, UniqueVals, M, MaxDiff, P2) ->
    if P2 < M ->
        NextVal = element(P2+1, UniqueVals),
        if NextVal - Val1 =< MaxDiff ->
            advance_p2(Val1, UniqueVals, M, MaxDiff, P2+1);
        true -> 
            P2
        end;
    true -> 
        P2
    end.

generate_ups(Step, MaxStep, Acc, _M) when Step > MaxStep ->
    list_to_tuple(lists:reverse(Acc));
generate_ups(Step, MaxStep, [Prev | _] = Acc, M) ->
    NextUp = list_to_tuple([element(element(I, Prev), Prev) || I <- lists:seq(1, M)]),
    generate_ups(Step+1, MaxStep, [NextUp | Acc], M).

ans_query([U, V], ValTuple, ValToIdMap, CompTuple, UpTuple) ->
    if U =:= V -> 
        0;
    true ->
        ValU = element(U+1, ValTuple),
        ValV = element(V+1, ValTuple),
        if ValU =:= ValV -> 
            1;
        true ->
            IdU = maps:get(ValU, ValToIdMap),
            IdV = maps:get(ValV, ValToIdMap),
            {MinId, MaxId} = if IdU < IdV -> {IdU, IdV}; true -> {IdV, IdU} end,
            Comp1 = element(MinId, CompTuple),
            Comp2 = element(MaxId, CompTuple),
            if Comp1 =/= Comp2 -> 
                -1;
            true ->
                calculate_dist(MinId, MaxId, UpTuple, 17, 0)
            end
        end
    end.

calculate_dist(_Curr, _Target, _UpTuple, K, Steps) when K < 0 ->
    Steps + 1;
calculate_dist(Curr, Target, UpTuple, K, Steps) ->
    UpK = element(K+1, UpTuple),
    Next = element(Curr, UpK),
    if Next < Target ->
        calculate_dist(Next, Target, UpTuple, K-1, Steps + (1 bsl K));
    true ->
        calculate_dist(Curr, Target, UpTuple, K-1, Steps)
    end.