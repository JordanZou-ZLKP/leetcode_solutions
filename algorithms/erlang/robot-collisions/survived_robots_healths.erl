-spec survived_robots_healths(Positions :: [integer()], Healths :: [integer()], Directions :: unicode:unicode_binary()) -> [integer()].
survived_robots_healths(Positions, Healths, Directions) ->
    Robots = build_robots(Positions, Healths, Directions, 1, []),
    SortedRobots = lists:sort(Robots),
    Survivors = process(SortedRobots, []),
    SortedSurvivors = lists:keysort(4, Survivors),
    [H || {_, H, _, _} <- SortedSurvivors].

build_robots([P | Ps], [H | Hs], <<D:8, Ds/binary>>, Idx, Acc) ->
    build_robots(Ps, Hs, Ds, Idx + 1, [{P, H, D, Idx} | Acc]);
build_robots([], [], <<>>, _, Acc) ->
    Acc.

process([], Stack) ->
    Stack;
process([{P, H, D, Idx} = Robot | Rest], Stack) ->
    case Stack of
        [] ->
            process(Rest, [Robot]);
        [{TopP, TopH, TopD, TopIdx} | StackRest] ->
            if
                D =:= $R ->
                    process(Rest, [Robot | Stack]);
                D =:= $L andalso TopD =:= $L ->
                    process(Rest, [Robot | Stack]);
                D =:= $L andalso TopD =:= $R ->
                    if
                        TopH =:= H ->
                            process(Rest, StackRest);
                        TopH > H ->
                            process(Rest, [{TopP, TopH - 1, TopD, TopIdx} | StackRest]);
                        TopH < H ->
                            process([{P, H - 1, D, Idx} | Rest], StackRest)
                    end
            end
    end.