-spec rotate_string(S :: unicode:unicode_binary(), Goal :: unicode:unicode_binary()) -> boolean().

rotate_string(S, Goal) when byte_size(S) =:= byte_size(Goal) ->
    binary:match(<<S/binary, S/binary>>, Goal) =/= nomatch;
rotate_string(_, _) ->
    false.