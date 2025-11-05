-spec find_x_sum(Nums :: [integer()], K :: integer(), X :: integer()) -> [integer()].
-type freq() :: non_neg_integer().
-type val() :: integer().
-type count_map() :: #{val() => freq()}.
-type tree() :: gb_trees:tree({integer(), integer()}, any()).

find_x_sum(Nums, K, X) ->
    N = length(Nums),
    if
        N < K -> [];
        true ->
            Arr = array:from_list(Nums),
            CountMap = #{},
            Top = gb_trees:empty(),
            Rest = gb_trees:empty(),
            TopSum = 0,

            {CM1, T1, R1, TS1} = init_window(Arr, 0, K - 1, CountMap, Top, Rest, TopSum, X),

            Result = slide(Arr, K, N - 1, K, X, CM1, T1, R1, TS1, [TS1]),
            lists:reverse(Result)
    end.

init_window(_Arr, L, R, CM, T, Rst, TS, X) when L > R ->
    {CM, T, Rst, TS};
init_window(Arr, L, R, CM, T, Rst, TS, X) ->
    V = array:get(L, Arr),
    {CM1, T1, Rst1, TS1} = insert_val(V, CM, T, Rst, TS, X),
    init_window(Arr, L + 1, R, CM1, T1, Rst1, TS1, X).

slide(_Arr, I, MaxI, _K, _X, CM, T, Rst, TS, Acc) when I > MaxI ->
    Acc;
slide(Arr, I, MaxI, K, X, CM, T, Rst, TS, Acc) ->
    ToRemove = array:get(I - K, Arr),
    ToAdd    = array:get(I, Arr),

    {CM1, T1, Rst1, TS1} = erase_val(ToRemove, CM, T, Rst, TS, X),
    {CM2, T2, Rst2, TS2} = insert_val(ToAdd, CM1, T1, Rst1, TS1, X),

    slide(Arr, I + 1, MaxI, K, X, CM2, T2, Rst2, TS2, [TS2 | Acc]).

-spec real_to_key({freq(), val()}) -> {integer(), integer()}.
real_to_key({F, V}) -> {-F, -V}.

insert_val(V, CountMap, Top, Rest, TopSum, X) ->
    F0 = maps:get(V, CountMap, 0),
    {Top1, Rest1, TopSum1} = pull({F0, V}, Top, Rest, TopSum),
    F1 = F0 + 1,
    CountMap1 = maps:put(V, F1, CountMap),
    {Top2, Rest2, TopSum2} = push_to_top({F1, V}, Top1, Rest1, TopSum1),

    Flag = gb_trees:size(Top2) > X,
    case Flag of
        true ->
            {LastKey, _, Top3} = gb_trees:take_largest(Top2),   % 最不优先的
            {F, VReal} = key_to_real(LastKey),
            NewTopSum = TopSum2 - F * VReal,
            Rest3 = gb_trees:insert(LastKey, true, Rest2),
            {CountMap1, Top3, Rest3, NewTopSum};
        _ ->
            {CountMap1, Top2, Rest2, TopSum2}
    end.

erase_val(V, CountMap, Top, Rest, TopSum, X) ->
    case maps:find(V, CountMap) of
        error ->
            {CountMap, Top, Rest, TopSum};
        {ok, F0} ->
            {Top1, Rest1, TopSum1} = pull({F0, V}, Top, Rest, TopSum),
            if
                F0 =:= 1 ->
                    CountMap1 = maps:remove(V, CountMap);
                true ->
                    CountMap1 = maps:put(V, F0 - 1, CountMap)
            end,

            {Top2, Rest2, TopSum2} =
                if
                    F0 > 1 ->
                        NewRealKey = {F0 - 1, V},
                        TreeKey = real_to_key(NewRealKey),
                        Rest2a = gb_trees:insert(TreeKey, true, Rest1),
                        {Top1, Rest2a, TopSum1};
                    true ->
                        {Top1, Rest1, TopSum1}
                end,

            Flag = (gb_trees:size(Top2) < X) andalso not (gb_trees:is_empty(Rest2)),
            case Flag of
                true ->
                    {BestKey, _, Rest3} = gb_trees:take_smallest(Rest2),
                    {F, VReal} = key_to_real(BestKey),
                    NewTopSum = TopSum2 + F * VReal,
                    Top3 = gb_trees:insert(BestKey, true, Top2),
                    {CountMap1, Top3, Rest3, NewTopSum};
                _ ->
                    {CountMap1, Top2, Rest2, TopSum2}
            end
    end.

pull({0, _V}, Top, Rest, TopSum) ->
    {Top, Rest, TopSum};
pull(RealKey = {F, V}, Top, Rest, TopSum) ->
    TreeKey = real_to_key(RealKey),
    case gb_trees:lookup(TreeKey, Top) of
        {value, _} ->
            Top1 = gb_trees:delete(TreeKey, Top),
            NewTopSum = TopSum - F * V,
            {Top1, Rest, NewTopSum};
        none ->
            case gb_trees:lookup(TreeKey, Rest) of
                {value, _} ->
                    Rest1 = gb_trees:delete(TreeKey, Rest),
                    {Top, Rest1, TopSum};
                none ->
                    {Top, Rest, TopSum}
            end
    end.

push_to_top(RealKey = {F, V}, Top, Rest, TopSum) ->
    TreeKey = real_to_key(RealKey),
    Top1 = gb_trees:insert(TreeKey, true, Top),
    NewTopSum = TopSum + F * V,
    {Top1, Rest, NewTopSum}.

-spec key_to_real({integer(), integer()}) -> {freq(), val()}.
key_to_real({NegF, NegV}) -> {-NegF, -NegV}.
