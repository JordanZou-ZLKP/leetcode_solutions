-spec min_sum_square_diff(Nums1 :: [integer()], Nums2 :: [integer()], K1 :: integer(), K2 :: integer()) -> integer().
min_sum_square_diff(Nums1, Nums2, K1, K2) ->
    Diffs = lists:reverse(lists:sort(lists:zipwith(fun(X, Y) -> abs(X - Y) end, Nums1, Nums2)), [0]),
    reduce(Diffs, K1 + K2, 1).

reduce([0 | _], _, _) ->
    0;
reduce([H1, H2 | T], K, Count) ->
    Cost = (H1 - H2) * Count,
    if
        K >= Cost ->
            reduce([H2 | T], K - Cost, Count + 1);
        true ->
            Red = K div Count,
            Rem = K rem Count,
            Val1 = H1 - Red - 1,
            Val2 = H1 - Red,
            Sq1 = Val1 * Val1 * Rem,
            Sq2 = Val2 * Val2 * (Count - Rem),
            Sq1 + Sq2 + sum_sq([H2 | T])
    end.

sum_sq(L) ->
    lists:foldl(fun(X, Acc) -> X * X + Acc end, 0, L).

