-spec get_descent_periods(Prices :: [integer()]) -> integer().

get_descent_periods([]) ->
    0;
get_descent_periods([Price | Rest]) ->
    count_periods(Rest, Price, 1, 1).

count_periods([], _PrevPrice, _CurrentLength, Total) ->
    Total;
count_periods([Price | Rest], PrevPrice, CurrentLength, Total) ->
    case PrevPrice - Price of
        1 ->
            % 当前价格比前一天低1，延续平滑下降序列
            NewLength = CurrentLength + 1,
            count_periods(Rest, Price, NewLength, Total + NewLength);
        _ ->
            % 价格差不是1，开始新的序列
            count_periods(Rest, Price, 1, Total + 1)
    end.