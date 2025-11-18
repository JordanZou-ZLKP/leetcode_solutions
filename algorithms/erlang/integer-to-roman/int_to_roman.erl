-spec int_to_roman(Num :: integer()) -> unicode:unicode_binary().
int_to_roman(Num) when is_integer(Num), Num >= 1, Num =< 3999 ->
    ValueSymbols = [
        {1000, <<"M">>},
        {900,  <<"CM">>},
        {500,  <<"D">>},
        {400,  <<"CD">>},
        {100,  <<"C">>},
        {90,   <<"XC">>},
        {50,   <<"L">>},
        {40,   <<"XL">>},
        {10,   <<"X">>},
        {9,    <<"IX">>},
        {5,    <<"V">>},
        {4,    <<"IV">>},
        {1,    <<"I">>}
    ],
    iolist_to_binary(lists:reverse(int_to_roman_acc(Num, ValueSymbols, []))).

int_to_roman_acc(0, _, Acc) ->
    Acc;
int_to_roman_acc(Num, [{Value, Symbol} | Rest], Acc) when Num >= Value ->
    int_to_roman_acc(Num - Value, [{Value, Symbol} | Rest], [Symbol | Acc]);
int_to_roman_acc(Num, [_ | Rest], Acc) ->
    int_to_roman_acc(Num, Rest, Acc).