-spec left_right_difference(Nums :: [integer()]) -> [integer()].
left_right_difference(Nums) ->
    TotalSum = lists:sum(Nums),
    calculate_diff(Nums, 0, TotalSum, []).

calculate_diff([H | T], LeftSum, TotalSum, Acc) ->
    RightSum = TotalSum - LeftSum - H,
    Diff = abs(LeftSum - RightSum),
    calculate_diff(T, LeftSum + H, TotalSum, [Diff | Acc]);
calculate_diff([], _LeftSum, _TotalSum, Acc) ->
    lists:reverse(Acc).