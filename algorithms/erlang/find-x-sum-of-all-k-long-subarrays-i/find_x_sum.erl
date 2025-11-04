-spec find_x_sum(Nums :: [integer()], K :: integer(), X :: integer()) -> [integer()].
find_x_sum(Nums, K, X) ->
    N = length(Nums),
    NumWindows = N - K + 1,
    lists:map(
        fun(I) ->
            Sub = lists:sublist(Nums, I, K),
            Freq = freq_map(Sub),
            TopXValues = top_x_values(Freq, X),
            x_sum(Sub, TopXValues)
        end,
        lists:seq(1, NumWindows)
    ).

freq_map(List) ->
    freq_map(List, #{}).

freq_map([], Acc) ->
    Acc;
freq_map([H|T], Acc) ->
    NewAcc = maps:update_with(H, fun(V) -> V + 1 end, 1, Acc),
    freq_map(T, NewAcc).

top_x_values(FreqMap, X) ->
    Pairs = maps:to_list(FreqMap),  % [{Value, Count}]
    Sorted = lists:sort(
        fun({V1, C1}, {V2, C2}) ->
            case C1 =:= C2 of
                true  -> V1 > V2;
                false -> C1 > C2
            end
        end,
        Pairs
    ),
    TopX = lists:sublist(Sorted, X),
    [Value || {Value, _Count} <- TopX].

x_sum(Sub, TopXValues) ->
    TopSet = sets:from_list(TopXValues),
    lists:foldl(
        fun(Val, Sum) ->
            case sets:is_element(Val, TopSet) of
                true  -> Sum + Val;
                false -> Sum
            end
        end,
        0,
        Sub
    ).