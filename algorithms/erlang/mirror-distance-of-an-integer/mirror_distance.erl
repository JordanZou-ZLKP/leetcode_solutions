-spec mirror_distance(N :: integer()) -> integer().
mirror_distance(N) ->
    abs(N - reverse_num(N, 0)).

reverse_num(0, Acc) ->
    Acc;
reverse_num(N, Acc) ->
    reverse_num(N div 10, Acc * 10 + (N rem 10)).