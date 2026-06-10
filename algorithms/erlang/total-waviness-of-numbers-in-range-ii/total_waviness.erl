-spec total_waviness(Num1 :: integer(), Num2 :: integer()) -> integer().
total_waviness(Num1, Num2) ->
    solve(Num2) - solve(Num1 - 1).

solve(Num) when Num < 100 -> 
    0;
solve(Num) ->
    DigitsT = list_to_tuple([X - $0 || X <- integer_to_list(Num)]),
    {_, Sum, _} = dp(tuple_size(DigitsT), -1, -1, true, false, DigitsT, #{}),
    Sum.

dp(0, _, _, _, _, _, Memo) ->
    {1, 0, Memo};
dp(Rem, P, L, IsLimit, IsNum, DigitsT, Memo) ->
    Key = {Rem, P, L},
    case IsLimit =:= false andalso IsNum =:= true of
        true ->
            case maps:find(Key, Memo) of
                {ok, {CachedC, CachedS}} -> 
                    {CachedC, CachedS, Memo};
                error -> 
                    compute_dp(Rem, P, L, IsLimit, IsNum, DigitsT, Memo, Key)
            end;
        false ->
            compute_dp(Rem, P, L, IsLimit, IsNum, DigitsT, Memo, Key)
    end.

compute_dp(Rem, P, L, IsLimit, IsNum, DigitsT, Memo, Key) ->
    MaxD = case IsLimit of
        true -> element(tuple_size(DigitsT) - Rem + 1, DigitsT);
        false -> 9
    end,
    {TotalC, TotalS, NewMemo} = loop(0, MaxD, Rem, P, L, IsLimit, IsNum, DigitsT, Memo, 0, 0),
    FinalMemo = case IsLimit =:= false andalso IsNum =:= true of
        true -> maps:put(Key, {TotalC, TotalS}, NewMemo);
        false -> NewMemo
    end,
    {TotalC, TotalS, FinalMemo}.

loop(D, MaxD, _, _, _, _, _, _, Memo, AccC, AccS) when D > MaxD ->
    {AccC, AccS, Memo};
loop(D, MaxD, Rem, P, L, IsLimit, IsNum, DigitsT, Memo, AccC, AccS) ->
    NewLimit = IsLimit andalso (D =:= MaxD),
    NewNum = IsNum orelse (D > 0),
    {NextP, NextL, Wave} = if
        not IsNum andalso D =:= 0 -> 
            {-1, -1, 0};
        not IsNum andalso D > 0 -> 
            {-1, D, 0};
        true ->
            IsPeak = (P =/= -1) andalso (L > P) andalso (L > D),
            IsValley = (P =/= -1) andalso (L < P) andalso (L < D),
            W = if IsPeak orelse IsValley -> 1; true -> 0 end,
            {L, D, W}
    end,
    {C, S, Memo1} = dp(Rem - 1, NextP, NextL, NewLimit, NewNum, DigitsT, Memo),
    loop(D + 1, MaxD, Rem, P, L, IsLimit, IsNum, DigitsT, Memo1, AccC + C, AccS + S + Wave * C).