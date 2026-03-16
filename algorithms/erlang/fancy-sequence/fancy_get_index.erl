-spec fancy_init_() -> any().
fancy_init_() ->
    put(fancy_a, 1),
    put(fancy_b, 0),
    put(fancy_size, 0),
    put(fancy_seq, #{}).

-spec fancy_append(Val :: integer()) -> any().
fancy_append(Val) ->
    A = get(fancy_a),
    B = get(fancy_b),
    Size = get(fancy_size),
    Seq = get(fancy_seq),
    M = 1000000007,
    V0 = ((((Val - B) rem M) + M) rem M * mod_pow(A, M - 2, M)) rem M,
    put(fancy_seq, maps:put(Size, V0, Seq)),
    put(fancy_size, Size + 1).

-spec fancy_add_all(Inc :: integer()) -> any().
fancy_add_all(Inc) ->
    B = get(fancy_b),
    M = 1000000007,
    put(fancy_b, (B + Inc) rem M).

-spec fancy_mult_all(M :: integer()) -> any().
fancy_mult_all(M) ->
    A = get(fancy_a),
    B = get(fancy_b),
    Mod = 1000000007,
    put(fancy_a, (A * M) rem Mod),
    put(fancy_b, (B * M) rem Mod).

-spec fancy_get_index(Idx :: integer()) -> integer().
fancy_get_index(Idx) ->
    Size = get(fancy_size),
    if 
        Idx >= Size -> -1;
        true ->
            Seq = get(fancy_seq),
            V0 = maps:get(Idx, Seq),
            A = get(fancy_a),
            B = get(fancy_b),
            (V0 * A + B) rem 1000000007
    end.

mod_pow(_, 0, _) -> 1;
mod_pow(B, E, Mod) when E rem 2 =:= 0 ->
    Half = mod_pow(B, E div 2, Mod),
    (Half * Half) rem Mod;
mod_pow(B, E, Mod) ->
    (B * mod_pow(B, E - 1, Mod)) rem Mod.