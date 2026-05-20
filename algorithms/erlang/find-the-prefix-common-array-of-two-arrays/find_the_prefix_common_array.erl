-spec find_the_prefix_common_array(A :: [integer()], B :: [integer()]) -> [integer()].
find_the_prefix_common_array(A, B) ->
    find_prefix(A, B, 0, 0, []).

find_prefix([], [], _, _, Acc) ->
    lists:reverse(Acc);
find_prefix([Ha | Ta], [Hb | Tb], Seen, Count, Acc) ->
    BitA = 1 bsl Ha,
    {Seen1, Count1} = case Seen band BitA of
        0 -> {Seen bor BitA, Count};
        _ -> {Seen, Count + 1}
    end,
    BitB = 1 bsl Hb,
    {Seen2, Count2} = case Seen1 band BitB of
        0 -> {Seen1 bor BitB, Count1};
        _ -> {Seen1, Count1 + 1}
    end,
    find_prefix(Ta, Tb, Seen2, Count2, [Count2 | Acc]).