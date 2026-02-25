-spec sort_by_bits(Arr :: [integer()]) -> [integer()].
sort_by_bits(Arr) ->
    Decorated = [{count_bits(X), X} || X <- Arr],
    Sorted = lists:sort(Decorated),
    [Num || {_, Num} <- Sorted].

count_bits(0) -> 
    0;
count_bits(N) -> 
    1 + count_bits(N band (N - 1)).