-spec remove_outer_parentheses(S :: unicode:unicode_binary()) -> unicode:unicode_binary().
remove_outer_parentheses(S) ->
    erlang:list_to_binary(lists:reverse(remove_outer(S, 0, []))).

remove_outer(<<>>, _Depth, Acc) ->
    Acc;
remove_outer(<<$(, Rest/binary>>, Depth, Acc) when Depth > 0 ->
    remove_outer(Rest, Depth + 1, [$( | Acc]);
remove_outer(<<$(, Rest/binary>>, 0, Acc) ->
    remove_outer(Rest, 1, Acc);
remove_outer(<<$), Rest/binary>>, Depth, Acc) when Depth > 1 ->
    remove_outer(Rest, Depth - 1, [$) | Acc]);
remove_outer(<<$), Rest/binary>>, 1, Acc) ->
    remove_outer(Rest, 0, Acc).

