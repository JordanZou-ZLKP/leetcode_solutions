-spec is_good(Nums :: [integer()]) -> boolean().
is_good(Nums) ->
    L = length(Nums),
    if
        L < 2 -> false;
        true -> check_freq(Nums, L - 1, #{})
    end.

check_freq([], _, _) ->
    true;
check_freq([H | T], Max, Map) when H >= 1, H =< Max ->
    case maps:get(H, Map, 0) of
        0 -> check_freq(T, Max, Map#{H => 1});
        1 when H =:= Max -> check_freq(T, Max, Map#{H => 2});
        _ -> false
    end;
check_freq(_, _, _) ->
    false.