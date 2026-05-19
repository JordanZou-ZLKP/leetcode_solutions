-spec get_common(Nums1 :: [integer()], Nums2 :: [integer()]) -> integer().
get_common([H | _], [H | _]) ->
    H;
get_common([H1 | T1], [H2 | _] = Nums2) when H1 < H2 ->
    get_common(T1, Nums2);
get_common([H1 | _] = Nums1, [H2 | T2]) when H1 > H2 ->
    get_common(Nums1, T2);
get_common(_, _) ->
    -1.