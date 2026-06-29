-spec maximum_length(Nums :: [integer()]) -> integer().
maximum_length(Nums) ->
    Sorted = lists:sort(Nums),
    FreqList = rle(Sorted, undefined, 0, []),
    FreqMap = maps:from_list(FreqList),
    Max1 = case maps:find(1, FreqMap) of
        {ok, C} when C rem 2 =:= 0 -> C - 1;
        {ok, C} -> C;
        error -> 1
    end,
    find_max(FreqList, FreqMap, Max1).

rle([], Prev, Count, Acc) ->
    [{Prev, Count} | Acc];
rle([H | T], undefined, 0, Acc) ->
    rle(T, H, 1, Acc);
rle([H | T], Prev, Count, Acc) when H =:= Prev ->
    rle(T, Prev, Count + 1, Acc);
rle([H | T], Prev, Count, Acc) ->
    rle(T, H, 1, [{Prev, Count} | Acc]).

find_max([], _Map, Max) -> 
    Max;
find_max([{1, _} | T], Map, Max) ->
    find_max(T, Map, Max);
find_max([{H, _} | T], Map, Max) ->
    Len = chain_len(H, Map, 0),
    NextMax = if Len > Max -> Len; true -> Max end,
    find_max(T, Map, NextMax).

chain_len(X, Map, Acc) ->
    case maps:find(X, Map) of
        error -> Acc - 1;
        {ok, 1} -> Acc + 1;
        {ok, V} when V >= 2 -> chain_len(X * X, Map, Acc + 2)
    end.