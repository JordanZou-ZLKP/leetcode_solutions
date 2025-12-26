-spec can_be_typed_words(Text :: unicode:unicode_binary(), BrokenLetters :: unicode:unicode_binary()) -> integer().
can_be_typed_words(One, Two) ->
    Text = binary_to_list(One),
    BrokenLetters = binary_to_list(Two),
    % 1. 预处理：将 BrokenLetters 转换为位掩码 (Integer Mask)
    % 时间复杂度: O(M), M 是 BrokenLetters 的长度 (M <= 26)
    Mask = create_mask(BrokenLetters, 0),
    
    % 2. 遍历文本计算
    % 时间复杂度: O(N), N 是 Text 的长度
    % 初始状态: Count=0, CurrentWordValid=true
    count_words(Text, Mask, 0, true).

%% ---------------------------------------------------------
%% 内部函数：创建位掩码
%% ---------------------------------------------------------

create_mask([], Acc) -> 
    Acc;
create_mask([Char | Rest], Acc) ->
    % 将字符 'a'-'z' 映射到 0-25 位
    Bit = 1 bsl (Char - $a),
    create_mask(Rest, Acc bor Bit).

%% ---------------------------------------------------------
%% 内部函数：尾递归遍历文本
%% ---------------------------------------------------------

% Case 1: 遍历结束 (Base Case)
% 如果最后一个单词是有效的 (IsValid == true)，计数加 1，否则保持原样
count_words([], _Mask, Count, true) -> 
    Count + 1;
count_words([], _Mask, Count, false) -> 
    Count;

% Case 2: 遇到空格 (Space) -> 单词结束边界
% 结算当前单词：如果 IsValid 为 true，Count + 1
% 重置 IsValid 为 true，准备处理下一个单词
count_words([$\s | Rest], Mask, Count, IsValid) ->
    NewCount = if IsValid -> Count + 1; true -> Count end,
    count_words(Rest, Mask, NewCount, true);

% Case 3: 遇到普通字符，且当前单词状态仍为有效 (IsValid == true)
% 需要检查该字符是否在损坏列表中
count_words([Char | Rest], Mask, Count, true) ->
    % 检查当前字符对应的位是否被置位
    IsBroken = (Mask band (1 bsl (Char - $a))) =/= 0,
    if 
        IsBroken -> 
            % 字符损坏，标记当前单词为无效 (false)，继续遍历直到遇到空格
            count_words(Rest, Mask, Count, false);
        true -> 
            % 字符正常，当前单词状态保持有效 (true)，继续遍历
            count_words(Rest, Mask, Count, true)
    end;

% Case 4: 遇到普通字符，且当前单词状态已为无效 (IsValid == false)
% 优化：既然当前单词已经判定无法输入，无需再检查后续字符，直接跳过直到空格或结束
count_words([_Char | Rest], Mask, Count, false) ->
    count_words(Rest, Mask, Count, false).