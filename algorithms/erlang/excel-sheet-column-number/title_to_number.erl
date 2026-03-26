-spec title_to_number(ColumnTitle :: unicode:unicode_binary()) -> integer().

title_to_number(ColumnTitle) when is_binary(ColumnTitle) ->
    calc_bin(ColumnTitle, 0);
title_to_number(ColumnTitle) when is_list(ColumnTitle) ->
    calc_list(ColumnTitle, 0).

calc_bin(<<>>, Acc) -> 
    Acc;
calc_bin(<<C, Rest/binary>>, Acc) ->
    calc_bin(Rest, Acc * 26 + (C - $A + 1)).

calc_list([], Acc) -> 
    Acc;
calc_list([C | Rest], Acc) ->
    calc_list(Rest, Acc * 26 + (C - $A + 1)).