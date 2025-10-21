-spec length_of_longest_substring(S :: unicode:unicode_binary()) -> integer().
length_of_longest_substring(S) ->
length_of_longest_substring(binary_to_list(S), 0, 0, #{}, 0).

%% 递归实现滑动窗口
%% Str: 剩余字符串（列表）
%% Left: 左指针
%% Right: 右指针（从0开始）
%% LastSeen: Map 记录每个字符最后出现的索引
%% MaxLen: 当前最大长度
length_of_longest_substring([], _Left, _Right, _LastSeen, MaxLen) ->
    MaxLen;

length_of_longest_substring([C | Rest], Left, Right, LastSeen, MaxLen) ->
    case maps:find(C, LastSeen) of
        {ok, LastIndex} when LastIndex >= Left ->
            % 重复字符在当前窗口内，移动左指针
            NewLeft = LastIndex + 1;
        _ ->
            % 无重复或重复在窗口外
            NewLeft = Left
    end,
    NewLastSeen = maps:put(C, Right, LastSeen),
    CurrentLen = Right - NewLeft + 1,
    NewMaxLen = max(MaxLen, CurrentLen),
    length_of_longest_substring(Rest, NewLeft, Right + 1, NewLastSeen, NewMaxLen).