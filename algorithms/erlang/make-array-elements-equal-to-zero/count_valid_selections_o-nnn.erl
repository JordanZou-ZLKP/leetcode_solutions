-spec count_valid_selections(Nums :: [integer()]) -> integer().
count_valid_selections(Nums) ->
    Length = length(Nums),
    Arr = array:from_list(Nums),
    ZeroIndices = [I || I <- lists:seq(0, Length - 1), array:get(I, Arr) == 0],
    lists:sum([simulate(Arr, Start, Dir) || Start <- ZeroIndices, Dir <- [-1, 1]]).

simulate(Arr, Start, Dir) ->
    case simulate_loop(Arr, Start, Dir) of
        {ok, FinalArr} ->
            IsAllZero = array:foldl(fun(_, V, Acc) -> Acc andalso (V == 0) end, true, FinalArr),
            case IsAllZero of
                true -> 1;
                false -> 0
            end;
        _ ->
            0
    end.

simulate_loop(Arr, Pos, Dir) ->
    Length = array:size(Arr),
    case Pos of
        I when I < 0; I >= Length ->
            {ok, Arr};
        _ ->
            Value = array:get(Pos, Arr),
            case Value of
                0 ->
                    NewPos = Pos + Dir,
                    simulate_loop(Arr, NewPos, Dir);
                _ when Value > 0 ->
                    NewArr = array:set(Pos, Value - 1, Arr),
                    NewDir = -Dir,
                    NewPos = Pos + NewDir,
                    simulate_loop(NewArr, NewPos, NewDir)
            end
    end.