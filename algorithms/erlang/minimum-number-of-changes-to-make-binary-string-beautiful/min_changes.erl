-spec min_changes(S :: unicode:unicode_binary()) -> integer().
min_changes(S) ->
    do_min_changes(S, 0).

do_min_changes(<<>>, Acc) ->
    Acc;
do_min_changes(<<C1:8, C2:8, Rest/binary>>, Acc) ->
    if
        C1 =/= C2 ->
            do_min_changes(Rest, Acc + 1);
        true ->
            do_min_changes(Rest, Acc)
    end.

