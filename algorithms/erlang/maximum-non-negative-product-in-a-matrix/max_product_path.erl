-spec max_product_path(Grid :: [[integer()]]) -> integer().

max_product_path([Row1 | RestRows]) ->
    [H | T] = Row1,
    {FirstRowDP, _} = lists:mapfoldl(
        fun(Val, Prev) ->
            Curr = Val * Prev,
            {{Curr, Curr}, Curr}
        end, H, T),
    InitDP = [{H, H} | FirstRowDP],
    FinalDP = lists:foldl(
        fun(RowVals, PrevRowDP) ->
            [Val0 | RestVals] = RowVals,
            [{AboveMax0, AboveMin0} | PrevRestDP] = PrevRowDP,
            NewMax0 = max(Val0 * AboveMax0, Val0 * AboveMin0),
            NewMin0 = min(Val0 * AboveMax0, Val0 * AboveMin0),
            FirstDP = {NewMax0, NewMin0},
            {NewRowRest, _} = lists:mapfoldl(
                fun({Val, {AboveMax, AboveMin}}, {LeftMax, LeftMin}) ->
                    C1 = Val * AboveMax,
                    C2 = Val * AboveMin,
                    C3 = Val * LeftMax,
                    C4 = Val * LeftMin,
                    Max = max(max(C1, C2), max(C3, C4)),
                    Min = min(min(C1, C2), min(C3, C4)),
                    {{Max, Min}, {Max, Min}}
                end, FirstDP, lists:zip(RestVals, PrevRestDP)),
            [FirstDP | NewRowRest]
        end, InitDP, RestRows),
    {Max, _} = lists:last(FinalDP),
    if Max < 0 -> -1;
       true -> Max rem 1000000007
    end.