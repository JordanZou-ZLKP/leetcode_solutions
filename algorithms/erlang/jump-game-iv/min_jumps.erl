-spec min_jumps(Arr :: [integer()]) -> integer().

min_jumps(Arr) when length(Arr) =< 1 ->
    0;
min_jumps(Arr) ->
    N = length(Arr),
    Tuple = list_to_tuple(Arr),
    Map = build_map(Arr, 1, #{}),
    bfs([1], #{1 => true}, Map, Tuple, N, 0).

build_map([], _, Map) -> 
    Map;
build_map([H|T], Idx, Map) ->
    build_map(T, Idx + 1, maps:update_with(H, fun(L) -> [Idx|L] end, [Idx], Map)).

bfs(Level, Visited, Map, Tuple, N, Steps) ->
    case lists:member(N, Level) of
        true -> 
            Steps;
        false ->
            {NextLevel, NewVisited, NewMap} = lists:foldl(
                fun(Idx, {NextAcc, VisAcc, MapAcc}) ->
                    Val = element(Idx, Tuple),
                    Adj = case maps:find(Val, MapAcc) of
                        {ok, L} -> L;
                        error -> []
                    end,
                    Neighbors = [Idx - 1, Idx + 1 | Adj],
                    {NewNext, NewVis} = lists:foldl(
                        fun(Neighbor, {NAcc, VAcc}) ->
                            if
                                Neighbor >= 1, Neighbor =< N ->
                                    case maps:is_key(Neighbor, VAcc) of
                                        true -> {NAcc, VAcc};
                                        false -> {[Neighbor|NAcc], VAcc#{Neighbor => true}}
                                    end;
                                true ->
                                    {NAcc, VAcc}
                            end
                        end, {NextAcc, VisAcc}, Neighbors),
                    {NewNext, NewVis, maps:remove(Val, MapAcc)}
                end, {[], Visited, Map}, Level),
            bfs(NextLevel, NewVisited, NewMap, Tuple, N, Steps + 1)
    end.