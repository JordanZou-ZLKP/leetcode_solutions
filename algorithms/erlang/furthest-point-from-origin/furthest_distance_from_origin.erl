-spec furthest_distance_from_origin(Moves :: unicode:unicode_binary()) -> integer().
furthest_distance_from_origin(Moves) ->
    calc(Moves, 0, 0).

calc(<<>>, Pos, Wildcards) ->
    abs(Pos) + Wildcards;
calc(<<$L, Rest/binary>>, Pos, Wildcards) ->
    calc(Rest, Pos - 1, Wildcards);
calc(<<$R, Rest/binary>>, Pos, Wildcards) ->
    calc(Rest, Pos + 1, Wildcards);
calc(<<$_, Rest/binary>>, Pos, Wildcards) ->
    calc(Rest, Pos, Wildcards + 1).