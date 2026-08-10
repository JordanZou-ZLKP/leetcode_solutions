-spec stone_game_ii(Piles :: [integer()]) -> integer().
stone_game_ii(Piles) ->
    {SuffixList, _} = lists:foldr(
        fun(X, {AccList, Sum}) ->
            NewSum = Sum + X,
            {[NewSum | AccList], NewSum}
        end, {[], 0}, Piles),
    SuffixTuple = erlang:list_to_tuple(SuffixList),
    N = tuple_size(SuffixTuple),
    {Ans, _} = solve(1, 1, SuffixTuple, N, maps:new()),
    Ans.

solve(I, M, SuffixTuple, N, Memo) ->
    if
        I > N -> {0, Memo};
        I + 2 * M - 1 >= N -> {element(I, SuffixTuple), Memo};
        true ->
            case maps:find({I, M}, Memo) of
                {ok, Val} -> {Val, Memo};
                error ->
                    {Max, NewMemo} = try_x(1, 2 * M, I, M, SuffixTuple, N, Memo, 0),
                    {Max, maps:put({I, M}, Max, NewMemo)}
            end
    end.

try_x(X, MaxX, _I, _M, _SuffixTuple, _N, Memo, CurMax) when X > MaxX ->
    {CurMax, Memo};
try_x(X, MaxX, I, M, SuffixTuple, N, Memo, CurMax) ->
    {NextVal, Memo1} = solve(I + X, max(M, X), SuffixTuple, N, Memo),
    Score = element(I, SuffixTuple) - NextVal,
    try_x(X + 1, MaxX, I, M, SuffixTuple, N, Memo1, max(CurMax, Score)).