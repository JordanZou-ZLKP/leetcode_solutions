-spec stone_game_iii(StoneValue :: [integer()]) -> unicode:unicode_binary().
stone_game_iii(StoneValue) ->
    Reversed = lists:reverse(StoneValue),
    Diff = solve(Reversed, 0, 0, 0, none, none),
    if
        Diff > 0 -> <<"Alice">>;
        Diff < 0 -> <<"Bob">>;
        true -> <<"Tie">>
    end.

solve([], DP1, _, _, _, _) ->
    DP1;
solve([V | Rest], DP1, DP2, DP3, V1, V2) ->
    Opt1 = V - DP1,
    Opt2 = case V1 of
        none -> -999999999;
        _ -> V + V1 - DP2
    end,
    Opt3 = case V2 of
        none -> -999999999;
        _ -> V + V1 + V2 - DP3
    end,
    Max = max(Opt1, max(Opt2, Opt3)),
    solve(Rest, Max, DP1, DP2, V, V1).