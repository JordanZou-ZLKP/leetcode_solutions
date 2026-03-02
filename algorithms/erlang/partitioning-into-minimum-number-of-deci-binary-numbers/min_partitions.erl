-spec min_partitions(N :: unicode:unicode_binary()) -> integer().
min_partitions(N) ->
    find_max(N, 0).

find_max(<<>>, Max) ->
    Max;
find_max(<<$9, _/binary>>, _) ->
    9;
find_max(<<C, Rest/binary>>, Max) when C - $0 > Max ->
    find_max(Rest, C - $0);
find_max(<<_, Rest/binary>>, Max) ->
    find_max(Rest, Max).