-spec judge_circle(Moves :: unicode:unicode_binary()) -> boolean().
judge_circle(Moves) ->
    judge_circle(Moves, 0, 0).

judge_circle(<<>>, X, Y) ->
    X =:= 0 andalso Y =:= 0;
judge_circle(<<$U, Rest/binary>>, X, Y) ->
    judge_circle(Rest, X, Y + 1);
judge_circle(<<$D, Rest/binary>>, X, Y) ->
    judge_circle(Rest, X, Y - 1);
judge_circle(<<$R, Rest/binary>>, X, Y) ->
    judge_circle(Rest, X + 1, Y);
judge_circle(<<$L, Rest/binary>>, X, Y) ->
    judge_circle(Rest, X - 1, Y).