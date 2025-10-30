-spec smallest_number(N :: integer()) -> integer().
smallest_number(N) ->
    K = bit_length(N),
    (1 bsl K) - 1.

bit_length(0) -> 0;
bit_length(N) when N > 0 ->
    bit_length_loop(N, 0).

bit_length_loop(0, Acc) -> Acc;
bit_length_loop(N, Acc) ->
    bit_length_loop(N bsr 1, Acc + 1).