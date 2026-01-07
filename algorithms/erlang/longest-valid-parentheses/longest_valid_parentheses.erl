-spec longest_valid_parentheses(S :: unicode:unicode_binary()) -> integer().
longest_valid_parentheses(One) ->
    S = binary_to_list(One),
    %% 初始化：
    %% S: 字符串
    %% Index: 当前遍历到的字符索引，从 1 开始
    %% Stack: 栈，初始放入 0 作为基准，处理边界情况
    %% Max: 当前发现的最大长度
    solve(S, 1, [0], 0).

%% 辅助函数 (尾递归)

%% Base Case: 字符串遍历结束，返回 Max
solve([], _Index, _Stack, Max) ->
    Max;

%% Case 1: 遇到左括号 '('
%% 操作：将当前索引压入栈
solve([$( | Rest], Index, Stack, Max) ->
    solve(Rest, Index + 1, [Index | Stack], Max);

%% Case 2: 遇到右括号 ')'
%% 操作：弹出栈顶元素
solve([$) | Rest], Index, [_Top | StackRest], Max) ->
    case StackRest of
        [] ->
            %% 弹出后栈为空 -> 说明当前的 ')' 没有匹配到左括号
            %% 将当前 Index 压入栈作为新的基准点
            solve(Rest, Index + 1, [Index], Max);
        [NewTop | _] ->
            %% 弹出后栈不为空 -> 匹配成功
            %% 有效长度 = 当前索引 - 新的栈顶元素
            CurrentLen = Index - NewTop,
            NewMax = erlang:max(Max, CurrentLen),
            solve(Rest, Index + 1, StackRest, NewMax)
    end.

