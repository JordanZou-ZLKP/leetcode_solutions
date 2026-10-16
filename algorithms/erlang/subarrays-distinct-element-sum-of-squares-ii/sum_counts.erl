-spec sum_counts(Nums :: [integer()]) -> integer().
sum_counts(Nums) ->
    N = length(Nums),
    solve(Nums, 1, N, nil, #{}, 0, 0).

solve([], _J, _N, _Tree, _LastMap, _CurSqSum, TotalAns) ->
    TotalAns;
solve([X | Rest], J, N, Tree, LastMap, CurSqSum, TotalAns) ->
    L = maps:get(X, LastMap, 0) + 1,
    {RangeSum, NewTree} = update_query(Tree, 1, N, L, J),
    NewSqSum = (CurSqSum + 2 * RangeSum + (J - L + 1)) rem 1000000007,
    NewTotalAns = (TotalAns + NewSqSum) rem 1000000007,
    solve(Rest, J + 1, N, NewTree, LastMap#{X => J}, NewSqSum, NewTotalAns).

update_query(nil, TL, TR, L, R) ->
    update_query({0, 0, nil, nil}, TL, TR, L, R);
update_query({Sum, Lazy, Left, Right}, TL, TR, TL, TR) ->
    Len = TR - TL + 1,
    {Sum, {Sum + Len, Lazy + 1, Left, Right}};
update_query({Sum, Lazy, Left, Right}, TL, TR, L, R) ->
    Mid = (TL + TR) bsr 1,
    Len = R - L + 1,
    if
        R =< Mid ->
            {OldSum, NewLeft} = update_query(Left, TL, Mid, L, R),
            {OldSum + Lazy * Len, {Sum + Len, Lazy, NewLeft, Right}};
        L > Mid ->
            {OldSum, NewRight} = update_query(Right, Mid + 1, TR, L, R),
            {OldSum + Lazy * Len, {Sum + Len, Lazy, Left, NewRight}};
        true ->
            {OldSumL, NewLeft} = update_query(Left, TL, Mid, L, Mid),
            {OldSumR, NewRight} = update_query(Right, Mid + 1, TR, Mid + 1, R),
            {OldSumL + OldSumR + Lazy * Len, {Sum + Len, Lazy, NewLeft, NewRight}}
    end.

