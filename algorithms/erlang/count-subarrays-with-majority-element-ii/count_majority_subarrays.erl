-spec count_majority_subarrays(Nums :: [integer()], Target :: integer()) -> integer().
count_majority_subarrays(Nums, Target) ->
    Prefixes = build_prefixes(Nums, Target, 0, [0]),
    {_, Count} = merge_sort(Prefixes),
    Count.

build_prefixes([], _, _, Acc) ->
    lists:reverse(Acc);
build_prefixes([H|T], Target, Sum, Acc) ->
    NewSum = case H of
                 Target -> Sum + 1;
                 _ -> Sum - 1
             end,
    build_prefixes(T, Target, NewSum, [NewSum|Acc]).

merge_sort([]) -> {[], 0};
merge_sort([X]) -> {[X], 0};
merge_sort(List) ->
    Half = length(List) div 2,
    {L, R} = lists:split(Half, List),
    {SortedL, CountL} = merge_sort(L),
    {SortedR, CountR} = merge_sort(R),
    {SortedMerged, CountM} = merge(SortedL, SortedR, [], 0, 0),
    {SortedMerged, CountL + CountR + CountM}.

merge([X|Xs], [Y|Ys], Acc, Count, LP) when X < Y ->
    merge(Xs, [Y|Ys], [X|Acc], Count, LP + 1);
merge([X|Xs], [Y|Ys], Acc, Count, LP) ->
    merge([X|Xs], Ys, [Y|Acc], Count + LP, LP);
merge([], Ys, Acc, Count, LP) ->
    {lists:reverse(Acc, Ys), Count + length(Ys) * LP};
merge(Xs, [], Acc, Count, _LP) ->
    {lists:reverse(Acc, Xs), Count}.