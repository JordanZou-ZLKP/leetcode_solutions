-spec predict_the_winner(Nums :: [integer()]) -> boolean().
predict_the_winner(Nums) ->
    Tuple = list_to_tuple(Nums),
    N = tuple_size(Tuple),
    {Diff, _} = dfs(1, N, Tuple, #{}),
    Diff >= 0.

dfs(I, I, Tuple, Memo) ->
    {element(I, Tuple), Memo};
dfs(I, J, Tuple, Memo) ->
    case maps:find({I, J}, Memo) of
        {ok, Val} ->
            {Val, Memo};
        error ->
            {Diff1, Memo1} = dfs(I + 1, J, Tuple, Memo),
            {Diff2, Memo2} = dfs(I, J - 1, Tuple, Memo1),
            Val1 = element(I, Tuple) - Diff1,
            Val2 = element(J, Tuple) - Diff2,
            Max = max(Val1, Val2),
            {Max, maps:put({I, J}, Max, Memo2)}
    end.