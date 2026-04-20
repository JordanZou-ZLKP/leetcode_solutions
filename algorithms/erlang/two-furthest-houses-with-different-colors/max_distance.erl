-spec max_distance(Colors :: [integer()]) -> integer().
max_distance(Colors) ->
    First = hd(Colors),
    RevColors = lists:reverse(Colors),
    Last = hd(RevColors),
    N = length(Colors),
    max(find_dist(Colors, Last, 1, N), find_dist(RevColors, First, 1, N)).

find_dist([H | _], Target, Idx, N) when H =/= Target ->
    N - Idx;
find_dist([_ | T], Target, Idx, N) ->
    find_dist(T, Target, Idx + 1, N).