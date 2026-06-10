-spec pivot_array(Nums :: [integer()], Pivot :: integer()) -> [integer()].
pivot_array(Nums, Pivot) ->
    pivot_array(Nums, Pivot, [], [], []).

pivot_array([H | T], Pivot, Less, Equal, Greater) when H < Pivot ->
    pivot_array(T, Pivot, [H | Less], Equal, Greater);
pivot_array([H | T], Pivot, Less, Equal, Greater) when H > Pivot ->
    pivot_array(T, Pivot, Less, Equal, [H | Greater]);
pivot_array([H | T], Pivot, Less, Equal, Greater) ->
    pivot_array(T, Pivot, Less, [H | Equal], Greater);
pivot_array([], _Pivot, Less, Equal, Greater) ->
    lists:reverse(Less, Equal ++ lists:reverse(Greater)).