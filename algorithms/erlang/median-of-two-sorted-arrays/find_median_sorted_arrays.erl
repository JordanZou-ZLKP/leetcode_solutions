-spec find_median_sorted_arrays(Nums1 :: [integer()], Nums2 :: [integer()]) -> float().
find_median_sorted_arrays(Nums1, Nums2) ->
    find_median(Nums1, Nums2).

find_median([], []) ->
    error(empty_arrays);
find_median([], Num2) ->
    median_single(Num2);
find_median(Num1, []) ->
    median_single(Num1);
find_median(Num1, Num2) when length(Num1) > length(Num2) ->
    find_median_helper(Num2, Num1);
find_median(Num1, Num2) ->
    find_median_helper(Num1, Num2).

find_median_helper(Shorter, Longer) ->
    M = length(Shorter),
    N = length(Longer),
    Total = M + N,
    Half = (Total + 1) div 2,

    {Med1, Med2} = binary_search(Shorter, Longer, 0, M, Half),
    
    case Total rem 2 of
        1 -> Med1;
        0 -> (Med1 + Med2) / 2.0
    end.

binary_search(Shorter, Longer, Lo, Hi, Half) ->
    case Lo =< Hi of
        false -> error(not_found);
        true ->
            Mid1 = (Lo + Hi) div 2,
            Mid2 = Half - Mid1,

            Left1 = get_element(Shorter, Mid1 - 1, -1000000),
            Right1 = get_element(Shorter, Mid1, 1000000),
            Left2 = get_element(Longer, Mid2 - 1, -1000000),
            Right2 = get_element(Longer, Mid2, 1000000),

            if
                Left1 =< Right2 andalso Left2 =< Right1 ->
                    MaxLeft = max(Left1, Left2),
                    MinRight = min(Right1, Right2),
                    {MaxLeft, MinRight};
                Left1 > Right2 ->
                    binary_search(Shorter, Longer, Lo, Mid1 - 1, Half);
                true ->
                    binary_search(Shorter, Longer, Mid1 + 1, Hi, Half)
            end
    end.

get_element(List, Index, Default) ->
    case Index < 0 orelse Index >= length(List) of
        true -> Default;
        false -> lists:nth(Index + 1, List)
    end.

median_single(List) ->
    Len = length(List),
    case Len rem 2 of
        1 ->
            lists:nth((Len + 1) div 2, List);
        0 ->
            Mid1 = lists:nth(Len div 2, List),
            Mid2 = lists:nth(Len div 2 + 1, List),
            (Mid1 + Mid2) / 2.0
    end.
    