-spec total_money(N :: integer()) -> integer().
total_money(N) ->
    Weeks = N div 7,
    Days = N rem 7,

    % Sum for complete weeks: sum_{k=1}^{Weeks} (7*k + 21) = 7 * sum(k) + 21 * Weeks
    CompleteWeeksSum = 7 * (Weeks * (Weeks + 1) div 2) + 21 * Weeks,

    % Sum for remaining days in the next week (starting from Weeks + 1)
    % Days: (Weeks+1) + (Weeks+2) + ... + (Weeks + Days)
    % = Days * Weeks + (1 + 2 + ... + Days) = Days * Weeks + Days*(Days+1)/2
    RemainingSum = Days * Weeks + (Days * (Days + 1) div 2),

    CompleteWeeksSum + RemainingSum.