-spec count_prime_set_bits(Left :: integer(), Right :: integer()) -> integer().
count_prime_set_bits(Left, Right) ->
    count_prime_set_bits(Left, Right, 0).

count_prime_set_bits(I, Right, Acc) when I > Right ->
    Acc;
count_prime_set_bits(I, Right, Acc) ->
    Bits = count_bits(I),
    IsPrime = (665772 bsr Bits) band 1,
    count_prime_set_bits(I + 1, Right, Acc + IsPrime).

count_bits(0) -> 
    0;
count_bits(N) -> 
    1 + count_bits(N band (N - 1)).