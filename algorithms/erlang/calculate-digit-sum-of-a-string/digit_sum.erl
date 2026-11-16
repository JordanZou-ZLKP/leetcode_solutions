-spec digit_sum(S :: unicode:unicode_binary(), K :: integer()) -> unicode:unicode_binary().
digit_sum(S, K) when byte_size(S) =< K ->
    S;
digit_sum(S, K) ->
    digit_sum(process_round(S, K, <<>>), K).

process_round(<<>>, _K, Acc) ->
    Acc;
process_round(S, K, Acc) when byte_size(S) =< K ->
    SumBin = integer_to_binary(sum_digits(S, 0)),
    <<Acc/binary, SumBin/binary>>;
process_round(S, K, Acc) ->
    <<Chunk:K/binary, Rest/binary>> = S,
    SumBin = integer_to_binary(sum_digits(Chunk, 0)),
    process_round(Rest, K, <<Acc/binary, SumBin/binary>>).

sum_digits(<<>>, Acc) ->
    Acc;
sum_digits(<<Char, Rest/binary>>, Acc) ->
    sum_digits(Rest, Acc + Char - 48).

