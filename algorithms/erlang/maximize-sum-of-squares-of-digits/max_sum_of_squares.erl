-spec max_sum_of_squares(Num :: integer(), Sum :: integer()) -> unicode:unicode_binary().
max_sum_of_squares(Num, Sum) when Sum > Num * 9; Sum < 1 ->
    <<>>;
max_sum_of_squares(Num, Sum) when Sum =:= Num * 9 ->
    binary:copy(<<$9>>, Num);
max_sum_of_squares(Num, Sum) ->
    Nines = Sum div 9,
    Rem = Sum rem 9,
    Zeros = Num - Nines - 1,
    Part1 = binary:copy(<<$9>>, Nines),
    Part2 = binary:copy(<<$0>>, Zeros),
    <<Part1/binary, ($0 + Rem), Part2/binary>>.
