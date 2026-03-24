-spec largest_submatrix(Matrix :: [[integer()]]) -> integer().
largest_submatrix(Matrix) ->
    [First | Rest] = Matrix,
    CalcArea = fun F([], _, Max) -> Max;
                   F([H | T], W, Max) -> F(T, W + 1, max(Max, H * W))
               end,
    {MaxArea, _} = lists:foldl(
        fun(Row, {AccMax, PrevHeights}) ->
            CurrHeights = lists:zipwith(
                fun(1, H) -> H + 1;
                   (_, _) -> 0
                end, Row, PrevHeights
            ),
            Sorted = lists:reverse(lists:sort(CurrHeights)),
            {max(AccMax, CalcArea(Sorted, 1, 0)), CurrHeights}
        end,
        {CalcArea(lists:reverse(lists:sort(First)), 1, 0), First},
        Rest
    ),
    MaxArea.