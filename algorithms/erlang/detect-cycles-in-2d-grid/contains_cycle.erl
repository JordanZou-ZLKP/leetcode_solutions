-spec contains_cycle(Grid :: [[char()]]) -> boolean().
contains_cycle(Grid) ->
    GridT = list_to_tuple([list_to_tuple(Row) || Row <- Grid]),
    M = tuple_size(GridT),
    N = tuple_size(element(1, GridT)),
    check_all(1, 1, M, N, GridT, #{}).

check_all(R, _C, M, _N, _GridT, _Vis) when R > M -> false;
check_all(R, C, M, N, GridT, Vis) when C > N -> 
    check_all(R + 1, 1, M, N, GridT, Vis);
check_all(R, C, M, N, GridT, Vis) ->
    case maps:is_key({R, C}, Vis) of
        true -> 
            check_all(R, C + 1, M, N, GridT, Vis);
        false ->
            Char = element(C, element(R, GridT)),
            case dfs(R, C, 0, 0, Char, GridT, M, N, Vis) of
                {true, _} -> true;
                {false, NVis} -> check_all(R, C + 1, M, N, GridT, NVis)
            end
    end.

dfs(R, C, PR, PC, Char, GridT, M, N, Vis) ->
    Vis1 = Vis#{{R, C} => true},
    Neighbors = [{R - 1, C}, {R + 1, C}, {R, C - 1}, {R, C + 1}],
    check_adj(Neighbors, R, C, PR, PC, Char, GridT, M, N, Vis1).

check_adj([], _R, _C, _PR, _PC, _Char, _GridT, _M, _N, Vis) -> 
    {false, Vis};
check_adj([{NR, NC} | Rest], R, C, PR, PC, Char, GridT, M, N, Vis) ->
    if
        NR >= 1, NR =< M, NC >= 1, NC =< N, {NR, NC} =/= {PR, PC} ->
            case element(NC, element(NR, GridT)) =:= Char of
                true ->
                    case maps:is_key({NR, NC}, Vis) of
                        true -> {true, Vis};
                        false ->
                            case dfs(NR, NC, R, C, Char, GridT, M, N, Vis) of
                                {true, _} -> {true, Vis};
                                {false, NVis} -> 
                                    check_adj(Rest, R, C, PR, PC, Char, GridT, M, N, NVis)
                            end
                    end;
                false -> 
                    check_adj(Rest, R, C, PR, PC, Char, GridT, M, N, Vis)
            end;
        true -> 
            check_adj(Rest, R, C, PR, PC, Char, GridT, M, N, Vis)
    end.