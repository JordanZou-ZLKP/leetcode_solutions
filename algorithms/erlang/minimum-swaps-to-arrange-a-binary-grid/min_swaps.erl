-spec min_swaps(Grid :: [[integer()]]) -> integer().
min_swaps(Grid) ->
    N = length(Grid),
    Zeros = [count_zeros(lists:reverse(Row), 0) || Row <- Grid],
    solve(Zeros, N - 1).

count_zeros([0|T], Acc) ->
    count_zeros(T, Acc + 1);
count_zeros(_, Acc) ->
    Acc.

solve([], _) ->
    0;
solve(Zeros, Req) ->
    case find_row(Zeros, Req, 0) of
        -1 ->
            -1;
        {Swaps, Rest} ->
            case solve(Rest, Req - 1) of
                -1 -> -1;
                Res -> Swaps + Res
            end
    end.

find_row([], _, _) ->
    -1;
find_row([H|T], Req, Idx) when H >= Req ->
    {Idx, T};
find_row([H|T], Req, Idx) ->
    case find_row(T, Req, Idx + 1) of
        -1 ->
            -1;
        {ResIdx, Rest} ->
            {ResIdx, [H|Rest]}
    end.