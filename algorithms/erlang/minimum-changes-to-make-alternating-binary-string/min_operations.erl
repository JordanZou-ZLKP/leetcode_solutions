-spec min_operations(S :: unicode:unicode_binary()) -> integer().
min_operations(S) ->
    min_ops(S, $0, 0, 0).

min_ops(<<>>, _, Count, Len) ->
    erlang:min(Count, Len - Count);
min_ops(<<C:8, Rest/binary>>, Expected, Count, Len) ->
    NextCount = if 
        C =:= Expected -> Count; 
        true -> Count + 1 
    end,
    NextExpected = if 
        Expected =:= $0 -> $1; 
        true -> $0 
    end,
    min_ops(Rest, NextExpected, NextCount, Len + 1).