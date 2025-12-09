-spec count_collisions(Directions :: unicode:unicode_binary()) -> integer().
count_collisions(One) ->
    Directions = binary_to_list(One),
    TrimmedLeft = trim_leading_l(Directions),
    Reversed = lists:reverse(TrimmedLeft),
    TrimmedBoth = trim_leading_r(Reversed),
    count_active(TrimmedBoth, 0).

trim_leading_l([$L | Rest]) -> 
    trim_leading_l(Rest);
trim_leading_l(List) -> 
    List.

trim_leading_r([$R | Rest]) -> 
    trim_leading_r(Rest);
trim_leading_r(List) -> 
    List.

count_active([], Acc) -> 
    Acc;
count_active([$S | Rest], Acc) -> 
    count_active(Rest, Acc);
count_active([_ | Rest], Acc) -> 
    count_active(Rest, Acc + 1).