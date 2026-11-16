-spec minimum_sum_subarray(Nums :: [integer()], L :: integer(), R :: integer()) -> integer().
minimum_sum_subarray(Nums, L, R) ->
    find_min(Nums, L, R, infinity).

find_min([], _L, _R, Min) ->
    case Min of
        infinity -> -1;
        _ -> Min
    end;
find_min([_ | T] = List, L, R, Min) ->
    find_min(T, L, R, check_subarray(List, 0, 1, L, R, Min)).

check_subarray(_, _Sum, Len, _L, R, Min) when Len > R ->
    Min;
check_subarray([], _Sum, _Len, _L, _R, Min) ->
    Min;
check_subarray([H | T], Sum, Len, L, R, Min) ->
    NewSum = Sum + H,
    NextMin = if
        Len >= L, NewSum > 0, Min =:= infinity -> NewSum;
        Len >= L, NewSum > 0, NewSum < Min -> NewSum;
        true -> Min
    end,
    check_subarray(T, NewSum, Len + 1, L, R, NextMin).

