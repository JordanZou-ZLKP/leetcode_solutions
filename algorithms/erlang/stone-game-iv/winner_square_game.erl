-spec winner_square_game(N :: integer()) -> boolean().
winner_square_game(N) ->
    dp(1, N, #{0 => false}).

dp(I, N, Map) when I > N ->
    maps:get(N, Map);
dp(I, N, Map) ->
    Win = check_squares(I, 1, Map),
    dp(I + 1, N, Map#{I => Win}).

check_squares(I, K, Map) ->
    Sq = K * K,
    if
        Sq > I -> 
            false;
        true ->
            case maps:get(I - Sq, Map) of
                false -> 
                    true;
                true -> 
                    check_squares(I, K + 1, Map)
            end
    end.