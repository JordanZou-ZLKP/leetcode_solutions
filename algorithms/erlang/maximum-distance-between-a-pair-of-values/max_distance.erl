-spec max_distance(Nums1 :: [integer()], Nums2 :: [integer()]) -> integer().
max_distance(Nums1, Nums2) ->
    find_dist(Nums1, Nums2, 0, 0, 0).

find_dist([], _, _, _, Max) ->
    Max;
find_dist(_, [], _, _, Max) ->
    Max;
find_dist(L1, [_ | T2], I, J, Max) when I > J ->
    find_dist(L1, T2, I, J + 1, Max);
find_dist([H1 | _] = L1, [H2 | T2], I, J, Max) when H1 =< H2 ->
    find_dist(L1, T2, I, J + 1, max(Max, J - I));
find_dist([_ | T1], L2, I, J, Max) ->
    find_dist(T1, L2, I + 1, J, Max).