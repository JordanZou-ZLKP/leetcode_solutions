-spec max_active_sections_after_trade(S :: unicode:unicode_binary()) -> integer().
max_active_sections_after_trade(S) ->
    RLE = rle(S),
    {Z, O, OTotal} = build_zo(RLE),
    M = length(Z),
    if
        M < 2 -> OTotal;
        true ->
            ZTuple = list_to_tuple(Z),
            OTuple = list_to_tuple(O),
            Pref = build_pref(Z),
            Suff = build_suff(Z),
            MaxGain = find_max_gain(1, M, ZTuple, OTuple, Pref, Suff, 0),
            OTotal + MaxGain
    end.

rle(<<>>) -> [];
rle(<<C:8, Rest/binary>>) -> rle(Rest, C, 1, []).

rle(<<C:8, Rest/binary>>, C, Count, Acc) ->
    rle(Rest, C, Count + 1, Acc);
rle(<<C1:8, Rest/binary>>, C, Count, Acc) ->
    rle(Rest, C1, 1, [{C, Count} | Acc]);
rle(<<>>, C, Count, Acc) ->
    lists:reverse([{C, Count} | Acc]).

build_zo(RLE) ->
    OTotal = lists:sum([Count || {$1, Count} <- RLE]),
    RLE1 = drop_leading_1(RLE),
    RLE2 = drop_trailing_1(lists:reverse(RLE1)),
    RLE3 = lists:reverse(RLE2),
    Z = [Count || {$0, Count} <- RLE3],
    O = [Count || {$1, Count} <- RLE3],
    {Z, O, OTotal}.

drop_leading_1([{$1, _} | T]) -> T;
drop_leading_1(L) -> L.

drop_trailing_1([{$1, _} | T]) -> T;
drop_trailing_1(L) -> L.

build_pref(Z) ->
    build_pref(Z, 0, []).

build_pref([], _Max, Acc) ->
    list_to_tuple(lists:reverse(Acc));
build_pref([H | T], Max, Acc) ->
    NewMax = max(H, Max),
    build_pref(T, NewMax, [NewMax | Acc]).

build_suff(Z) ->
    build_suff(lists:reverse(Z), 0, []).

build_suff([], _Max, Acc) ->
    list_to_tuple(Acc);
build_suff([H | T], Max, Acc) ->
    NewMax = max(H, Max),
    build_suff(T, NewMax, [NewMax | Acc]).

get_val(Tuple, Idx) when Idx >= 1, Idx =< tuple_size(Tuple) ->
    element(Idx, Tuple);
get_val(_Tuple, _Idx) ->
    0.

find_max_gain(I, M, _ZTuple, _OTuple, _Pref, _Suff, MaxGain) when I == M ->
    MaxGain;
find_max_gain(I, M, ZTuple, OTuple, Pref, Suff, MaxGain) ->
    Zi = element(I, ZTuple),
    Zi1 = element(I + 1, ZTuple),
    Oi = element(I, OTuple),
    V1 = Zi + Zi1,
    MaxOther = max(get_val(Pref, I - 1), get_val(Suff, I + 2)),
    V2 = MaxOther - Oi,
    find_max_gain(I + 1, M, ZTuple, OTuple, Pref, Suff, max(MaxGain, max(V1, V2))).