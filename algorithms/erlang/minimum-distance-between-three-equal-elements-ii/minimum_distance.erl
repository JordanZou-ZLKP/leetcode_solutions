-spec minimum_distance(Nums :: [integer()]) -> integer().
minimum_distance(Nums) ->
    find_min(Nums, 0, #{}, -1).

find_min([], _Idx, _Map, -1) ->
    -1;
find_min([], _Idx, _Map, MinDist) ->
    MinDist * 2;
find_min([H|T], Idx, Map, MinDist) ->
    case maps:find(H, Map) of
        {ok, {P1, P2}} ->
            NewMin = update_min(MinDist, Idx - P2),
            find_min(T, Idx + 1, Map#{H => {Idx, P1}}, NewMin);
        {ok, {P1}} ->
            find_min(T, Idx + 1, Map#{H => {Idx, P1}}, MinDist);
        error ->
            find_min(T, Idx + 1, Map#{H => {Idx}}, MinDist)
    end.

update_min(-1, V) -> V;
update_min(M, V) when M < V -> M;
update_min(_, V) -> V.