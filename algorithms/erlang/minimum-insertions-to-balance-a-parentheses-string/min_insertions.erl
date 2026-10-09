-spec min_insertions(S :: unicode:unicode_binary()) -> integer().
min_insertions(S) ->
    solve(S, 0, 0).

solve(<<>>, Added, NeedRight) ->
    Added + NeedRight;
solve(<<$(, Rest/binary>>, Added, NeedRight) when NeedRight rem 2 =:= 1 ->
    solve(Rest, Added + 1, NeedRight + 1);
solve(<<$(, Rest/binary>>, Added, NeedRight) ->
    solve(Rest, Added, NeedRight + 2);
solve(<<$), Rest/binary>>, Added, 0) ->
    solve(Rest, Added + 1, 1);
solve(<<$), Rest/binary>>, Added, NeedRight) ->
    solve(Rest, Added, NeedRight - 1).
