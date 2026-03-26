-spec maximum_gap(Nums :: [integer()]) -> integer().

maximum_gap([]) -> 0;
maximum_gap([_]) -> 0;
maximum_gap([H | T] = Nums) ->
    {Min, Max, N} = lists:foldl(
        fun(X, {CMin, CMax, CCount}) ->
            {min(X, CMin), max(X, CMax), CCount + 1}
        end,
        {H, H, 1},
        T
    ),
    if
        Min == Max -> 0;
        true ->
            BucketSize = max(1, (Max - Min) div (N - 1)),
            Buckets = lists:foldl(
                fun(Num, Acc) ->
                    Idx = (Num - Min) div BucketSize,
                    case maps:find(Idx, Acc) of
                        {ok, {BMin, BMax}} ->
                            maps:put(Idx, {min(Num, BMin), max(Num, BMax)}, Acc);
                        error ->
                            maps:put(Idx, {Num, Num}, Acc)
                    end
                end,
                #{},
                Nums
            ),
            MaxIdx = (Max - Min) div BucketSize,
            {MaxGap, _} = lists:foldl(
                fun(I, {CGap, PrevMax}) ->
                    case maps:find(I, Buckets) of
                        {ok, {BMin, BMax}} ->
                            {max(CGap, BMin - PrevMax), BMax};
                        error ->
                            {CGap, PrevMax}
                    end
                end,
                {0, Min},
                lists:seq(0, MaxIdx)
            ),
            MaxGap
    end.