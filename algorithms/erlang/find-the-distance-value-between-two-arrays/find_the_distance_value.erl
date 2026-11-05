-spec find_the_distance_value(Arr1 :: [integer()], Arr2 :: [integer()], D :: integer()) -> integer().
find_the_distance_value(Arr1, Arr2, D) ->
    count_distance(lists:sort(Arr1), lists:sort(Arr2), D, 0).

count_distance([], _, _, Count) ->
    Count;
count_distance(L1, [], _, Count) ->
    Count + length(L1);
count_distance([X | T1] = L1, [Y | T2] = L2, D, Count) ->
    if
        abs(X - Y) =< D ->
            count_distance(T1, L2, D, Count);
        X - Y > D ->
            count_distance(L1, T2, D, Count);
        true ->
            count_distance(T1, L2, D, Count + 1)
    end.

