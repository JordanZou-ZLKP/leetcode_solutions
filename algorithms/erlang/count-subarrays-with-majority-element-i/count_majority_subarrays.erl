-spec count_majority_subarrays(Nums :: [integer()], Target :: integer()) -> integer().
count_majority_subarrays(Nums, Target) ->
    loop(Nums, Target, 0, 0, 0, #{0 => 1}).

loop([], _, Total, _, _, _) ->
    Total;
loop([H | T], Target, Total, P, Smaller, Counts) ->
    Diff = case H of
        Target -> 1;
        _ -> -1
    end,
    NewP = P + Diff,
    NewSmaller = case Diff of
        1 -> Smaller + maps:get(P, Counts, 0);
        -1 -> Smaller - maps:get(NewP, Counts, 0)
    end,
    NewTotal = Total + NewSmaller,
    NewCounts = maps:update_with(NewP, fun(X) -> X + 1 end, 1, Counts),
    loop(T, Target, NewTotal, NewP, NewSmaller, NewCounts).