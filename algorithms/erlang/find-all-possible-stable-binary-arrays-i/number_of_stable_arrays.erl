-spec number_of_stable_arrays(Zero :: integer(), One :: integer(), Limit :: integer()) -> integer().
number_of_stable_arrays(Zero, One, Limit) ->
    Mod = 1000000007,
    DP = build_dp(0, 0, Zero, One, Limit, Mod, maps:new()),
    {V0, V1} = maps:get({Zero, One}, DP),
    (V0 + V1) rem Mod.

build_dp(I, _J, Zero, _One, _Limit, _Mod, DP) when I > Zero ->
    DP;
build_dp(I, J, Zero, One, Limit, Mod, DP) when J > One ->
    build_dp(I + 1, 0, Zero, One, Limit, Mod, DP);
build_dp(0, 0, Zero, One, Limit, Mod, DP) ->
    build_dp(0, 1, Zero, One, Limit, Mod, maps:put({0, 0}, {0, 0}, DP));
build_dp(I, 0, Zero, One, Limit, Mod, DP) ->
    Val = if I =< Limit -> {1, 0}; true -> {0, 0} end,
    build_dp(I, 1, Zero, One, Limit, Mod, maps:put({I, 0}, Val, DP));
build_dp(0, J, Zero, One, Limit, Mod, DP) ->
    Val = if J =< Limit -> {0, 1}; true -> {0, 0} end,
    build_dp(0, J + 1, Zero, One, Limit, Mod, maps:put({0, J}, Val, DP));
build_dp(I, J, Zero, One, Limit, Mod, DP) ->
    {Prev0_I, Prev1_I} = maps:get({I - 1, J}, DP),
    V0_temp = (Prev0_I + Prev1_I) rem Mod,
    V0 = if
        I > Limit ->
            {_, Sub1} = maps:get({I - Limit - 1, J}, DP),
            (V0_temp - Sub1 + Mod) rem Mod;
        true -> 
            V0_temp
    end,
    
    {Prev0_J, Prev1_J} = maps:get({I, J - 1}, DP),
    V1_temp = (Prev0_J + Prev1_J) rem Mod,
    V1 = if
        J > Limit ->
            {Sub0, _} = maps:get({I, J - Limit - 1}, DP),
            (V1_temp - Sub0 + Mod) rem Mod;
        true -> 
            V1_temp
    end,
    
    build_dp(I, J + 1, Zero, One, Limit, Mod, maps:put({I, J}, {V0, V1}, DP)).