-spec maximum_element_after_decrementing_and_rearranging(Arr :: [integer()]) -> integer().
maximum_element_after_decrementing_and_rearranging(Arr) ->
    SortedArr = lists:sort(Arr),
    find_max(SortedArr, 0).

find_max([], Max) ->
    Max;
find_max([H | T], Max) ->
    NextMax = erlang:min(H, Max + 1),
    find_max(T, NextMax).