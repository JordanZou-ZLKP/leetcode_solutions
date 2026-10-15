-spec sum_counts(Nums :: [integer()]) -> integer().
sum_counts(Nums) ->
    N = length(Nums),
    Tree = build(1, N),
    solve(Nums, 1, N, #{}, Tree, 0).

solve([], _Idx, _N, _LastMap, _Tree, Acc) ->
    Acc;
solve([X | Rest], Idx, N, LastMap, Tree, Acc) ->
    Prev = maps:get(X, LastMap, 0),
    NewTree = update(Tree, 1, N, Prev + 1, Idx, 1),
    {_, S2, _, _, _} = NewTree,
    solve(Rest, Idx + 1, N, maps:put(X, Idx, LastMap), NewTree, Acc + S2).

build(L, L) ->
    {0, 0, 0, nil, nil};
build(L, R) ->
    Mid = (L + R) div 2,
    {0, 0, 0, build(L, Mid), build(Mid + 1, R)}.

apply_add({S1, S2, Lazy, Left, Right}, Len, D) ->
    NewS2 = S2 + 2 * D * S1 + Len * D * D,
    NewS1 = S1 + Len * D,
    {NewS1, NewS2, Lazy + D, Left, Right}.

push_down({S1, S2, 0, Left, Right}, _L, _R) ->
    {S1, S2, 0, Left, Right};
push_down({S1, S2, Lazy, Left, Right}, L, R) ->
    Mid = (L + R) div 2,
    NewLeft = apply_add(Left, Mid - L + 1, Lazy),
    NewRight = apply_add(Right, R - Mid, Lazy),
    {S1, S2, 0, NewLeft, NewRight}.

update(Node, L, R, QL, QR, D) when QL =< L, R =< QR ->
    apply_add(Node, R - L + 1, D);
update(Node, L, R, QL, QR, D) ->
    {_, _, _, Left, Right} = push_down(Node, L, R),
    Mid = (L + R) div 2,
    NewLeft = if
        QL =< Mid -> update(Left, L, Mid, QL, QR, D);
        true -> Left
    end,
    NewRight = if
        QR > Mid -> update(Right, Mid + 1, R, QL, QR, D);
        true -> Right
    end,
    {LS1, LS2, _, _, _} = NewLeft,
    {RS1, RS2, _, _, _} = NewRight,
    {LS1 + RS1, LS2 + RS2, 0, NewLeft, NewRight}.

