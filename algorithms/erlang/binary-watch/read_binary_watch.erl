-spec read_binary_watch(TurnedOn :: integer()) -> [unicode:unicode_binary()].
read_binary_watch(TurnedOn) ->
    [<< (integer_to_binary(H))/binary, ":", 
        (if M < 10 -> <<"0">>; true -> <<>> end)/binary, 
        (integer_to_binary(M))/binary >> 
     || H <- lists:seq(0, 11), 
        M <- lists:seq(0, 59), 
        count_bits(H) + count_bits(M) =:= TurnedOn].

count_bits(0) -> 
    0;
count_bits(N) -> 
    1 + count_bits(N band (N - 1)).