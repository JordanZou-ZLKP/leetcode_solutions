-spec count_valid_selections(Nums :: [integer()]) -> integer().
count_valid_selections(Nums) ->
    N = length(Nums),
    NumsT = list_to_tuple(Nums),

    LeftList = lists:foldl(fun(I, Acc) ->
        SumSoFar = case Acc of [] -> 0; _ -> lists:last(Acc) end,
        PrevVal = element(I, NumsT),
        Acc ++ [SumSoFar + PrevVal]
    end, [], lists:seq(1, N)),
    LeftT = list_to_tuple(LeftList),

    RightList = lists:foldr(fun(I, Acc) ->
        SumSoFar = case Acc of [] -> 0; _ -> hd(Acc) end,
        NextVal = case I < N of true -> element(I + 1, NumsT); false -> 0 end,
        [SumSoFar + NextVal | Acc]
    end, [], lists:seq(1, N)),
    RightT = list_to_tuple(RightList),

    lists:sum([begin
        case element(I, NumsT) of
            0 ->
                L = element(I, LeftT),
                R = element(I, RightT),
                case abs(L - R) of
                    0 -> 2;
                    1 -> 1;
                    _ -> 0
                end;
            _ -> 0
        end
    end || I <- lists:seq(1, N)]).