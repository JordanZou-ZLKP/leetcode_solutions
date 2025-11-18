-spec roman_to_int(S :: unicode:unicode_binary()) -> integer().
roman_to_int(RomanBin) when is_binary(RomanBin) ->
    Values = #{
        $I => 1,
        $V => 5,
        $X => 10,
        $L => 50,
        $C => 100,
        $D => 500,
        $M => 1000
    },
    Chars = binary_to_list(RomanBin),
    convert(Chars, Values, 0).

convert([], _Values, Acc) ->
    Acc;

convert([Char], Values, Acc) ->
    Value = maps:get(Char, Values),
    Acc + Value;

convert([Curr, Next | Rest], Values, Acc) ->
    CurrVal = maps:get(Curr, Values),
    NextVal = maps:get(Next, Values),
    case CurrVal < NextVal of
        true ->
            convert([Next | Rest], Values, Acc - CurrVal);
        false ->
            convert([Next | Rest], Values, Acc + CurrVal)
    end.