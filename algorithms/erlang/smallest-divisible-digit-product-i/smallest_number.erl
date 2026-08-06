-spec smallest_number(N :: integer(), T :: integer()) -> integer().
smallest_number(N, T) ->
    check_number(N, T).

check_number(N, T) ->
    case digit_product(N, 1) rem T of
        0 -> N;
        _ -> check_number(N + 1, T)
    end.

digit_product(0, Acc) -> 
    Acc;
digit_product(N, Acc) -> 
    digit_product(N div 10, Acc * (N rem 10)).