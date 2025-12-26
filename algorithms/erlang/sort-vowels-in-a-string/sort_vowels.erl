-spec sort_vowels(S :: unicode:unicode_binary()) -> unicode:unicode_binary().

sort_vowels(One) ->
    S = binary_to_list(One),
    % 1. 提取所有元音 (O(N))
    Vowels = [C || C <- S, is_vowel(C)],
    
    % 2. 对元音进行排序 (O(N log N))
    SortedVowels = lists:sort(Vowels),
    
    % 3. 重构字符串 (O(N))
    % 使用尾递归 accumulator 方式构建结果，最后翻转
    Two = reconstruct(S, SortedVowels, []),
    R = list_to_binary(Two).

%% @private
%% 重构字符串的辅助函数
%% S: 原始字符串剩余部分
%% Vowels: 排序后的元音列表剩余部分
%% Acc: 结果累加器
reconstruct([], _Vowels, Acc) ->
    lists:reverse(Acc);
reconstruct([Char | RestS], Vowels, Acc) ->
    case is_vowel(Char) of
        true ->
            % 如果当前原字符是元音，从排序好的元音列表中取头部 (Head)
            [V | RestV] = Vowels,
            reconstruct(RestS, RestV, [V | Acc]);
        false ->
            % 如果是辅音，保留原字符
            reconstruct(RestS, Vowels, [Char | Acc])
    end.

%% @private
%% 判断字符是否为元音
%% 使用 Pattern Matching，效率非常高
is_vowel($a) -> true;
is_vowel($e) -> true;
is_vowel($i) -> true;
is_vowel($o) -> true;
is_vowel($u) -> true;
is_vowel($A) -> true;
is_vowel($E) -> true;
is_vowel($I) -> true;
is_vowel($O) -> true;
is_vowel($U) -> true;
is_vowel(_)  -> false.