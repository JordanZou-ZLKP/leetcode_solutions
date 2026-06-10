-spec total_waviness(Num1 :: integer(), Num2 :: integer()) -> integer().
total_waviness(Num1, Num2) ->
    count_range(Num1, Num2, 0).

count_range(N, Max, Acc) when N > Max ->
    Acc;
count_range(N, Max, Acc) ->
    count_range(N + 1, Max, Acc + calculate_waviness(N)).

calculate_waviness(N) when N < 100 ->
    0;
calculate_waviness(N) ->
    D1 = N rem 10,
    N1 = N div 10,
    D2 = N1 rem 10,
    N2 = N1 div 10,
    evaluate_digits(N2, D2, D1, 0).

evaluate_digits(0, _, _, Acc) ->
    Acc;
evaluate_digits(N, D2, D1, Acc) ->
    D3 = N rem 10,
    NextAcc = if
        (D2 > D3) andalso (D2 > D1) -> Acc + 1;
        (D2 < D3) andalso (D2 < D1) -> Acc + 1;
        true -> Acc
    end,
    evaluate_digits(N div 10, D3, D2, NextAcc).