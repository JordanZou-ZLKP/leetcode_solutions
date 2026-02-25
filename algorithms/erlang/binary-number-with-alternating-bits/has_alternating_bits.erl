-spec has_alternating_bits(N :: integer()) -> boolean().
has_alternating_bits(N) ->
    A = N bxor (N bsr 1),
    (A band (A + 1)) =:= 0.