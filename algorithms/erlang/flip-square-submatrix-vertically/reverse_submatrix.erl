-spec reverse_submatrix(Grid :: [[integer()]], X :: integer(), Y :: integer(), K :: integer()) -> [[integer()]].
reverse_submatrix(Grid, X, Y, K) ->
    {Top, Rest} = lists:split(X, Grid),
    {Middle, Bottom} = lists:split(K, Rest),
    Parts = [begin
                 {L, R1} = lists:split(Y, Row),
                 {S, R} = lists:split(K, R1),
                 {L, S, R}
             end || Row <- Middle],
    RevSubs = lists:reverse([S || {_, S, _} <- Parts]),
    NewMiddle = [L ++ S ++ R || {{L, _, R}, S} <- lists:zip(Parts, RevSubs)],
    Top ++ NewMiddle ++ Bottom.