-spec maximum_safeness_factor(Grid :: [[integer()]]) -> integer().
maximum_safeness_factor(Grid) ->
    N = length(Grid),
    Thieves = get_thieves(Grid, 0, []),
    DistMap = maps:from_list([{Pos, 0} || Pos <- Thieves]),
    FullDistMap = build_dist(Thieves, DistMap, N),
    MaxLimit = min(maps:get({0, 0}, FullDistMap), maps:get({N - 1, N - 1}, FullDistMap)),
    bin_search(0, MaxLimit, FullDistMap, N, 0).

get_thieves([], _, Acc) -> Acc;
get_thieves([Row | Rest], R, Acc) ->
    NewAcc = get_thieves_row(Row, R, 0, Acc),
    get_thieves(Rest, R + 1, NewAcc).

get_thieves_row([], _, _, Acc) -> Acc;
get_thieves_row([1 | Rest], R, C, Acc) ->
    get_thieves_row(Rest, R, C + 1, [{R, C} | Acc]);
get_thieves_row([0 | Rest], R, C, Acc) ->
    get_thieves_row(Rest, R, C + 1, Acc).

build_dist([], DistMap, _) -> DistMap;
build_dist(Level, DistMap, N) ->
    {NextLevel, NewDistMap} = get_next_level(Level, [], DistMap, N),
    build_dist(NextLevel, NewDistMap, N).

get_next_level([], Next, Dist, _) -> {Next, Dist};
get_next_level([{R, C} | T], Next, Dist, N) ->
    D = maps:get({R, C}, Dist) + 1,
    Neighbors = [{R + 1, C}, {R - 1, C}, {R, C + 1}, {R, C - 1}],
    Valid = [{NR, NC} || {NR, NC} <- Neighbors, NR >= 0, NR < N, NC >= 0, NC < N],
    {NewNext, NewDist} = lists:foldl(
        fun({NR, NC}, {AccNext, AccDist}) ->
            case maps:is_key({NR, NC}, AccDist) of
                true -> {AccNext, AccDist};
                false -> {[{NR, NC} | AccNext], maps:put({NR, NC}, D, AccDist)}
            end
        end,
        {Next, Dist}, Valid),
    get_next_level(T, NewNext, NewDist, N).

bin_search(Low, High, _, _, Ans) when Low > High -> Ans;
bin_search(Low, High, DistMap, N, Ans) ->
    Mid = (Low + High) div 2,
    case check_path(Mid, DistMap, N) of
        true -> bin_search(Mid + 1, High, DistMap, N, Mid);
        false -> bin_search(Low, Mid - 1, DistMap, N, Ans)
    end.

check_path(Limit, DistMap, N) ->
    dfs([{0, 0}], maps:put({0, 0}, true, #{}), Limit, DistMap, N).

dfs([], _, _, _, _) -> false;
dfs([{R, C} | _], _, _, _, N) when R =:= N - 1, C =:= N - 1 -> true;
dfs([{R, C} | T], Visited, Limit, DistMap, N) ->
    Neighbors = [{R + 1, C}, {R - 1, C}, {R, C + 1}, {R, C - 1}],
    Valid = [{NR, NC} || {NR, NC} <- Neighbors,
                         NR >= 0, NR < N, NC >= 0, NC < N,
                         not maps:is_key({NR, NC}, Visited),
                         maps:get({NR, NC}, DistMap) >= Limit],
    NewVisited = lists:foldl(fun(Pos, Acc) -> maps:put(Pos, true, Acc) end, Visited, Valid),
    dfs(Valid ++ T, NewVisited, Limit, DistMap, N).