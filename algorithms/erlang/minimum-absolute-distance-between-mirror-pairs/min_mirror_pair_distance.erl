-spec min_mirror_pair_distance(Nums :: [integer()]) -> integer().
min_mirror_pair_distance(Nums) ->
    find_min(Nums, 0, #{}, -1).

find_min([], _Idx, _Map, Min) ->
    Min;
find_min([Num | Rest], Idx, Map, Min) ->
    NewMin = case Map of
        #{Num := PrevIdx} ->
            Dist = Idx - PrevIdx,
            if 
                Min =:= -1 orelse Dist < Min -> Dist;
                true -> Min
            end;
        _ ->
            Min
    end,
    Rev = reverse(Num, 0),
    find_min(Rest, Idx + 1, Map#{Rev => Idx}, NewMin).

reverse(0, Acc) ->
    Acc;
reverse(N, Acc) ->
    reverse(N div 10, Acc * 10 + N rem 10).