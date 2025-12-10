-spec count_permutations(Complexity :: [integer()]) -> integer().
-define(MOD, 1000000007).

count_permutations(Complexity) ->
    Mod = 1000000007,
    [C0 | Rest] = Complexity,
    case check_rest(Rest, C0) of
        invalid -> 0;
        valid -> factorial(length(Rest), Mod)
    end.

check_rest([], _) -> valid;
check_rest([X | Xs], C0) ->
    if X > C0 -> check_rest(Xs, C0);
       true -> invalid
    end.

factorial(0, _) -> 1;
factorial(N, Mod) ->
    factorial(N, Mod, 1).

factorial(0, _, Acc) -> Acc;
factorial(N, Mod, Acc) ->
    factorial(N-1, Mod, (Acc * N) rem Mod).