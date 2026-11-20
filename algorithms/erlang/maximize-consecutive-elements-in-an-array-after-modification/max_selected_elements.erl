-spec max_selected_elements(Nums :: [integer()]) -> integer().
max_selected_elements(Nums) ->
    Sorted = lists:sort(Nums),
    solve(Sorted, #{}, 0).

solve([], _Dp, MaxLen) ->
    MaxLen;
solve([X | Rest], Dp, MaxLen) ->
    LenInc = maps:get(X, Dp, 0) + 1,
    LenKeep = maps:get(X - 1, Dp, 0) + 1,
    NewDp = Dp#{X => LenKeep, X + 1 => LenInc},
    NewMax = max(MaxLen, max(LenKeep, LenInc)),
    solve(Rest, NewDp, NewMax).

