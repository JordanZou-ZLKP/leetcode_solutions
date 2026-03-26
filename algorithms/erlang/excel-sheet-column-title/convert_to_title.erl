-spec convert_to_title(ColumnNumber :: integer()) -> unicode:unicode_binary().
convert_to_title(ColumnNumber) ->
    list_to_binary(do_convert(ColumnNumber, [])).

do_convert(0, Acc) ->
    Acc;
do_convert(N, Acc) ->
    do_convert((N - 1) div 26, [(N - 1) rem 26 + $A | Acc]).