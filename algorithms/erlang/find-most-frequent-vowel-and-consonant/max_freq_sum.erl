-spec max_freq_sum(S :: unicode:unicode_binary()) -> integer().
max_freq_sum(One) ->
    S = binary_to_list(One),
    % 1. 统计所有字符的频率
    % 时间复杂度: O(N), N 为字符串长度
    FreqMap = lists:foldl(fun(Char, AccMap) ->
        maps:update_with(Char, fun(V) -> V + 1 end, 1, AccMap)
    end, #{}, S),

    % 2. 遍历 Map，分别找出元音和辅音的最大值
    % 时间复杂度: O(1) (因为最多只有 26 个小写字母，Map 大小固定)
    {MaxVowel, MaxConsonant} = maps:fold(fun(Char, Count, {AccV, AccC}) ->
        case is_vowel(Char) of
            true  -> {max(AccV, Count), AccC}; % 如果是元音，更新元音最大值
            false -> {AccV, max(AccC, Count)}  % 否则更新辅音最大值
        end
    end, {0, 0}, FreqMap),

    % 3. 返回总和
    MaxVowel + MaxConsonant.

%% @private 辅助函数：判断字符是否为元音
is_vowel($a) -> true;
is_vowel($e) -> true;
is_vowel($i) -> true;
is_vowel($o) -> true;
is_vowel($u) -> true;
is_vowel(_) -> false.