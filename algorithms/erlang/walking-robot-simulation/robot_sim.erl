-spec robot_sim(Commands :: [integer()], Obstacles :: [[integer()]]) -> integer().
robot_sim(Commands, Obstacles) ->
    ObsMap = lists:foldl(fun([X, Y], Acc) -> maps:put({X, Y}, true, Acc) end, #{}, Obstacles),
    run(Commands, 0, 0, 0, 0, ObsMap).

run([], _X, _Y, _Dir, MaxDist, _ObsMap) ->
    MaxDist;
run([-2 | T], X, Y, Dir, MaxDist, ObsMap) ->
    run(T, X, Y, (Dir + 3) rem 4, MaxDist, ObsMap);
run([-1 | T], X, Y, Dir, MaxDist, ObsMap) ->
    run(T, X, Y, (Dir + 1) rem 4, MaxDist, ObsMap);
run([K | T], X, Y, Dir, MaxDist, ObsMap) ->
    {DX, DY} = get_dir(Dir),
    {NX, NY, NMaxDist} = move(K, X, Y, DX, DY, ObsMap, MaxDist),
    run(T, NX, NY, Dir, NMaxDist, ObsMap).

get_dir(0) -> {0, 1};
get_dir(1) -> {1, 0};
get_dir(2) -> {0, -1};
get_dir(3) -> {-1, 0}.

move(0, X, Y, _DX, _DY, _ObsMap, MaxDist) ->
    {X, Y, MaxDist};
move(K, X, Y, DX, DY, ObsMap, MaxDist) ->
    NX = X + DX,
    NY = Y + DY,
    case maps:is_key({NX, NY}, ObsMap) of
        true ->
            {X, Y, MaxDist};
        false ->
            NDist = NX * NX + NY * NY,
            move(K - 1, NX, NY, DX, DY, ObsMap, max(MaxDist, NDist))
    end.