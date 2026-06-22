-spec max_ice_cream(Costs :: [integer()], Coins :: integer()) -> integer().
max_ice_cream(Costs, Coins) ->
    MaxCost = lists:max(Costs),
    FreqMap = lists:foldl(
        fun(C, Acc) -> maps:update_with(C, fun(V) -> V + 1 end, 1, Acc) end,
        #{},
        Costs
    ),
    buy(1, MaxCost, FreqMap, Coins, 0).

buy(Cost, MaxCost, _, _, Count) when Cost > MaxCost ->
    Count;
buy(Cost, MaxCost, FreqMap, Coins, Count) ->
    case maps:find(Cost, FreqMap) of
        error ->
            buy(Cost + 1, MaxCost, FreqMap, Coins, Count);
        {ok, Freq} ->
            Buyable = min(Freq, Coins div Cost),
            RemCoins = Coins - Buyable * Cost,
            NewCount = Count + Buyable,
            if
                RemCoins < Cost + 1 ->
                    NewCount;
                true ->
                    buy(Cost + 1, MaxCost, FreqMap, RemCoins, NewCount)
            end
    end.