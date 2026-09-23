-spec min_operations(Nums :: [integer()], X :: integer()) -> integer().
min_operations(Nums, X) ->
    TotalSum = lists:sum(Nums),
    Target = TotalSum - X,
    Len = length(Nums),
    if
        Target < 0 -> -1;
        Target =:= 0 -> Len;
        true ->
            MaxLen = sliding_window(Nums, Nums, Target, 0, 0, 0, -1),
            if
                MaxLen =:= -1 -> -1;
                true -> Len - MaxLen
            end
    end.

sliding_window(LeftList, RightList, Target, Target, LeftIdx, RightIdx, MaxLen) ->
    NewMax = max(MaxLen, RightIdx - LeftIdx),
    case RightList of
        [] -> NewMax;
        [R | RestRight] ->
            sliding_window(LeftList, RestRight, Target, Target + R, LeftIdx, RightIdx + 1, NewMax)
    end;
sliding_window(_LeftList, [], Target, CurrentSum, _LeftIdx, _RightIdx, MaxLen) when CurrentSum < Target ->
    MaxLen;
sliding_window(LeftList, [R | RestRight], Target, CurrentSum, LeftIdx, RightIdx, MaxLen) when CurrentSum < Target ->
    sliding_window(LeftList, RestRight, Target, CurrentSum + R, LeftIdx, RightIdx + 1, MaxLen);
sliding_window([L | RestLeft], RightList, Target, CurrentSum, LeftIdx, RightIdx, MaxLen) when CurrentSum > Target ->
    sliding_window(RestLeft, RightList, Target, CurrentSum - L, LeftIdx + 1, RightIdx, MaxLen).

