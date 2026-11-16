-spec num_of_subarrays(Arr :: [integer()]) -> integer().
num_of_subarrays(Arr) ->
    calc(Arr, 0, 1, 0, 0).

calc([], _Sum, _Even, _Odd, Total) ->
    Total;
calc([H | T], Sum, Even, Odd, Total) ->
    NewSum = Sum + H,
    case NewSum band 1 of
        0 ->
            calc(T, NewSum, Even + 1, Odd, (Total + Odd) rem 1000000007);
        1 ->
            calc(T, NewSum, Even, Odd + 1, (Total + Even) rem 1000000007)
    end.

