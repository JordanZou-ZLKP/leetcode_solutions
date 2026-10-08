-spec check_valid_string(S :: unicode:unicode_binary()) -> boolean().
check_valid_string(S) ->
    check_valid_string(S, 0, 0).

check_valid_string(_, _, MaxOpen) when MaxOpen < 0 ->
    false;
check_valid_string(<<>>, MinOpen, _MaxOpen) ->
    MinOpen =:= 0;
check_valid_string(<<$(, Rest/binary>>, MinOpen, MaxOpen) ->
    check_valid_string(Rest, MinOpen + 1, MaxOpen + 1);
check_valid_string(<<$), Rest/binary>>, MinOpen, MaxOpen) ->
    check_valid_string(Rest, max(0, MinOpen - 1), MaxOpen - 1);
check_valid_string(<<$*, Rest/binary>>, MinOpen, MaxOpen) ->
    check_valid_string(Rest, max(0, MinOpen - 1), MaxOpen + 1).
