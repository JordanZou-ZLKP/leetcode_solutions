-spec reverse(X :: integer()) -> integer().
-define(INT_MAX, 2147483647).  % 2^31 - 1
-define(INT_MIN, -2147483648). % -2^31

reverse(X) ->
    do_reverse(X, 0).

do_reverse(0, Ans) ->
    Ans;
do_reverse(X, Ans) ->
    Digit = X rem 10,

    if
        Ans > ?INT_MAX div 10 -> 0;
        Ans < ?INT_MIN div 10 -> 0;
        true ->
            NewAns = Ans * 10 + Digit,
            NextX = X div 10,
            do_reverse(NextX, NewAns)
    end.