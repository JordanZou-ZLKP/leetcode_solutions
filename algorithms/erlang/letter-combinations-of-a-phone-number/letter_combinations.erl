-spec letter_combinations(Digits :: unicode:unicode_binary()) -> [unicode:unicode_binary()].
letter_combinations(Digits) ->
    case Digits of
        [] -> [];
        _  -> 
            One = combinations(binary_to_list(Digits), []),
            to_binary(One)
    end.

to_binary(One) ->
    R = [list_to_binary(X) || X <- One].

combinations([], Acc) ->
    [lists:reverse(Acc)];  
combinations([H|T], Acc) ->
    Letters = digit_to_letters(H),
    lists:flatmap(fun(Letter) ->
                      combinations(T, [Letter | Acc])
                  end, Letters).

digit_to_letters($2) -> "abc";
digit_to_letters($3) -> "def";
digit_to_letters($4) -> "ghi";
digit_to_letters($5) -> "jkl";
digit_to_letters($6) -> "mno";
digit_to_letters($7) -> "pqrs";
digit_to_letters($8) -> "tuv";
digit_to_letters($9) -> "wxyz";
digit_to_letters(_) -> [].