-spec number_of_sets(N :: integer(), K :: integer()) -> integer().
number_of_sets(N, K) ->
    Mod = 1000000007,
    N1 = N + K - 1,
    R1 = 2 * K,
    if
        R1 > N1; R1 < 0 -> 0;
        true -> combination(N1, R1, Mod)
    end.

combination(N, R, Mod) when R > N - R ->
    combination(N, N - R, Mod);
combination(N, R, Mod) ->
    combination_iter(0, R, N, 1, 1, Mod).

combination_iter(I, R, N, NumAcc, DenAcc, Mod) when I < R ->
    Num = (NumAcc * (N - I)) rem Mod,
    Den = (DenAcc * (I + 1)) rem Mod,
    combination_iter(I + 1, R, N, Num, Den, Mod);
combination_iter(R, R, _, NumAcc, DenAcc, Mod) ->
    InvDen = power(DenAcc, Mod - 2, Mod),
    (NumAcc * InvDen) rem Mod.

power(_, 0, _) -> 1;
power(Base, Exp, Mod) when Exp rem 2 == 1 ->
    (Base * power(Base, Exp - 1, Mod)) rem Mod;
power(Base, Exp, Mod) ->
    Half = power(Base, Exp div 2, Mod),
    (Half * Half) rem Mod.

