-spec remove_covered_intervals(Intervals :: [[integer()]]) -> integer().
remove_covered_intervals(Intervals) ->
    Sorted = lists:sort(fun([L1, R1], [L2, R2]) ->
        if
            L1 =:= L2 -> R1 > R2;
            true -> L1 < L2
        end
    end, Intervals),
    count_remaining(Sorted, -1, 0).

count_remaining([], _, Count) ->
    Count;
count_remaining([[_, R] | T], MaxEnd, Count) when R =< MaxEnd ->
    count_remaining(T, MaxEnd, Count);
count_remaining([[_, R] | T], _, Count) ->
    count_remaining(T, R, Count + 1).