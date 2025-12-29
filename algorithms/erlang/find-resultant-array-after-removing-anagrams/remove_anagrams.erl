-spec remove_anagrams(Words :: [unicode:unicode_binary()]) -> [unicode:unicode_binary()].

to_list(Ones) ->
    R = [binary_to_list(X) || X <- Ones].

to_binary(Ones) ->
    R = [list_to_binary(X) || X <- Ones].

remove_anagrams(Ones) ->
    Words = to_list(Ones),
    % 步骤 1: 将单词映射为 {排序后的key, 原始单词}
    % 例如: ["cba", "abc"] -> [{"abc", "cba"}, {"abc", "abc"}]
    KeyedWords = [{lists:sort(W), W} || W <- Words],
    
    % 步骤 2: 执行过滤逻辑
    ResultKeyed = filter(KeyedWords),
    
    % 步骤 3: 提取原始单词
    Rone = [Original || {_, Original} <- ResultKeyed],
    R = to_binary(Rone).

%% 递归过滤函数
filter([]) -> [];
filter([X]) -> [X];
filter([{Key1, _} = Current, {Key2, _} | Rest]) when Key1 == Key2 ->
    % 情况 A: Key1 == Key2 (即 words[i-1] 和 words[i] 是变位词)
    % 操作: 删除 words[i] (即列表中的第二个元素)，保留 Current，
    % 继续拿 Current 和 Rest 中的下一个元素比较。
    filter([Current | Rest]);
filter([Current | Rest]) ->
    % 情况 B: 不是变位词
    % 操作: Current 是有效保留的，将其放入结果列表，
    % 然后对剩余部分继续递归。
    [Current | filter(Rest)].