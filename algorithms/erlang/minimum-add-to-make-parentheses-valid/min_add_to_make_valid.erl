-spec min_add_to_make_valid(S :: unicode:unicode_binary()) -> integer().
min_add_to_make_valid(S) ->
    min_add_to_make_valid(S, 0, 0).

min_add_to_make_valid(<<>>, Open, Missing) ->
    Open + Missing;
min_add_to_make_valid(<<$(, Rest/binary>>, Open, Missing) ->
    min_add_to_make_valid(Rest, Open + 1, Missing);
min_add_to_make_valid(<<$), Rest/binary>>, 0, Missing) ->
    min_add_to_make_valid(Rest, 0, Missing + 1);
min_add_to_make_valid(<<$), Rest/binary>>, Open, Missing) ->
    min_add_to_make_valid(Rest, Open - 1, Missing).

