-spec binary_gap(N :: integer()) -> integer().
binary_gap(N) ->
    find_first_one(N).

find_first_one(0) ->
    0;
find_first_one(N) when N band 1 =:= 1 ->
    binary_gap_loop(N bsr 1, 1, 0);
find_first_one(N) ->
    find_first_one(N bsr 1).

binary_gap_loop(0, _, MaxGap) ->
    MaxGap;
binary_gap_loop(N, CurrentGap, MaxGap) when N band 1 =:= 1 ->
    binary_gap_loop(N bsr 1, 1, erlang:max(MaxGap, CurrentGap));
binary_gap_loop(N, CurrentGap, MaxGap) ->
    binary_gap_loop(N bsr 1, CurrentGap + 1, MaxGap).