-spec is_one_bit_character(Bits :: [integer()]) -> boolean().
is_one_bit_character(Bits) ->
    N = length(Bits),
    traverse(Bits, 0, N).

traverse(_Bits, I, N) when I >= N - 1 ->
    I =:= N - 1;
traverse(Bits, I, N) ->
    Current = lists:nth(I + 1, Bits),
    Step = Current + 1,  
    traverse(Bits, I + Step, N).