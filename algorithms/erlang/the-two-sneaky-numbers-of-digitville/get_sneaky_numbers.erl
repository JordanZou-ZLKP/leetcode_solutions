-spec get_sneaky_numbers(Nums :: [integer()]) -> [integer()].
get_sneaky_numbers(Nums) ->
    N = length(Nums) - 2,  
    XOR = lists:foldl(fun(X, Acc) -> Acc bxor X end, 0, Nums),
    TotalXOR = lists:foldl(fun(I, Acc) -> Acc bxor I end, XOR, lists:seq(0, N-1)),
    DiffBit = TotalXOR band (-TotalXOR),
    {A, B} = lists:foldl(
        fun(X, {A1, B1}) ->
            if
                (X band DiffBit) =:= 0 ->
                    {A1 bxor X, B1};
                true ->
                    {A1, B1 bxor X}
            end
        end,
        {0, 0},
        Nums
    ),

    {FinalA, FinalB} = lists:foldl(
        fun(I, {A1, B1}) ->
            if
                (I band DiffBit) =:= 0 ->
                    {A1 bxor I, B1};
                true ->
                    {A1, B1 bxor I}
            end
        end,
        {A, B},
        lists:seq(0, N-1)
    ),

    [FinalA, FinalB].