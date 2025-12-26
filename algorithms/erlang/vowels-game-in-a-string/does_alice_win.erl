-spec does_alice_win(S :: unicode:unicode_binary()) -> boolean().
does_alice_win(One) ->
    S = binary_to_list(One),
    contains_vowel(S).

%% 递归检查列表中是否包含元音
%% 一旦找到元音，立即返回 true (Early Exit)
contains_vowel([]) -> 
    false;
contains_vowel([Char | Rest]) ->
    case is_vowel(Char) of
        true -> true;
        false -> contains_vowel(Rest)
    end.

%% 辅助函数：判断字符是否为元音
%% 利用模式匹配实现快速判断
is_vowel($a) -> true;
is_vowel($e) -> true;
is_vowel($i) -> true;
is_vowel($o) -> true;
is_vowel($u) -> true;
is_vowel(_) -> false.