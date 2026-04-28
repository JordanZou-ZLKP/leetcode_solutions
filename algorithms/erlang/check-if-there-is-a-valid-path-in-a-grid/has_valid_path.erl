-spec has_valid_path(Grid :: [[integer()]]) -> boolean().
has_valid_path(Grid) ->
    M = length(Grid),
    N = length(hd(Grid)),
    Map = build_map(Grid, 0, #{}),
    dfs([{0, 0}], Map, #{{0, 0} => true}, M - 1, N - 1).

build_map([], _, Map) -> 
    Map;
build_map([Row | Rest], R, Map) ->
    build_map(Rest, R + 1, build_row(Row, R, 0, Map)).

build_row([], _, _, Map) -> 
    Map;
build_row([Val | Rest], R, C, Map) ->
    build_row(Rest, R, C + 1, Map#{{R, C} => Val}).

dfs([], _, _, _, _) ->
    false;
dfs([{R, C} | _], _, _, R, C) ->
    true;
dfs([{R, C} | Rest], GridMap, Visited, DestR, DestC) ->
    Type = map_get({R, C}, GridMap),
    Moves = get_moves(Type, R, C),
    Nexts = [{NR, NC} || {NR, NC, Dir} <- Moves,
                         not is_map_key({NR, NC}, Visited),
                         valid_move(Dir, NR, NC, GridMap)],
    NewVisited = lists:foldl(fun(Pos, Acc) -> Acc#{Pos => true} end, Visited, Nexts),
    dfs(Nexts ++ Rest, GridMap, NewVisited, DestR, DestC).

get_moves(1, R, C) -> [{R, C - 1, l}, {R, C + 1, r}];
get_moves(2, R, C) -> [{R - 1, C, u}, {R + 1, C, d}];
get_moves(3, R, C) -> [{R, C - 1, l}, {R + 1, C, d}];
get_moves(4, R, C) -> [{R, C + 1, r}, {R + 1, C, d}];
get_moves(5, R, C) -> [{R, C - 1, l}, {R - 1, C, u}];
get_moves(6, R, C) -> [{R, C + 1, r}, {R - 1, C, u}].

valid_move(Dir, R, C, GridMap) ->
    case maps:find({R, C}, GridMap) of
        error -> false;
        {ok, T} ->
            case Dir of
                r -> T =:= 1 orelse T =:= 3 orelse T =:= 5;
                l -> T =:= 1 orelse T =:= 4 orelse T =:= 6;
                d -> T =:= 2 orelse T =:= 5 orelse T =:= 6;
                u -> T =:= 2 orelse T =:= 3 orelse T =:= 4
            end
    end.