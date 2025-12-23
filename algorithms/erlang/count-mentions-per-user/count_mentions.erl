-spec count_mentions(NumberOfUsers :: integer(), Events :: [[unicode:unicode_binary()]]) -> [integer()].

to_list(Ones) ->
    R = [binary_to_list(One) || One <- Ones].

count_mentions(NumberOfUsers, Ones) ->
    Events = [to_list(One) || One <- Ones],
    % 1. 解析事件，将其转换为更易处理的元组格式
    % 格式: {Time, Priority, Type, Data}
    % Priority: 0 for OFFLINE, 1 for MESSAGE (确保同一时间先处理下线)
    ParsedEvents = lists:map(fun parse_event/1, Events),

    % 2. 排序事件
    % 排序规则: 时间升序 -> 优先级升序 (Offline < Message)
    SortedEvents = lists:sort(
        fun({T1, P1, _, _}, {T2, P2, _, _}) ->
            if
                T1 < T2 -> true;
                T1 > T2 -> false;
                true -> P1 =< P2
            end
        end,
        ParsedEvents
    ),

    % 3. 初始化状态
    % Mentions: 记录每个用户的被提及次数，初始为0
    MentionsArray = array:new(NumberOfUsers, {default, 0}),
    % OnlineUntil: 记录用户恢复上线的时间。如果 CurrentTime >= Value，则用户在线。
    % 初始为0，表示用户从时间0开始就是在线的。
    OnlineUntilArray = array:new(NumberOfUsers, {default, 0}),

    % 4. 处理事件流
    FinalMentions = process_events(SortedEvents, MentionsArray, OnlineUntilArray, NumberOfUsers),

    % 5. 转换为列表返回
    array:to_list(FinalMentions).

%% 辅助函数：解析原始事件列表
parse_event(["MESSAGE", TimeStr, MentionsStr]) ->
    {list_to_integer(TimeStr), 1, message, MentionsStr};
parse_event(["OFFLINE", TimeStr, IdStr]) ->
    {list_to_integer(TimeStr), 0, offline, list_to_integer(IdStr)}.

%% 辅助函数：核心递归处理循环 (Fold)
process_events([], Mentions, _, _) ->
    Mentions;
process_events([{Time, _, Type, Data} | Rest], Mentions, OnlineUntil, N) ->
    case Type of
        offline ->
            UserId = Data,
            % 用户下线，更新其恢复上线的时间为 Time + 60
            NewOnlineUntil = array:set(UserId, Time + 60, OnlineUntil),
            process_events(Rest, Mentions, NewOnlineUntil, N);

        message ->
            MentionsStr = Data,
            NewMentions = case MentionsStr of
                "ALL" ->
                    % 所有用户计数 +1
                    % array:map 复杂度 O(N)
                    array:map(fun(_, Count) -> Count + 1 end, Mentions);
                
                "HERE" ->
                    % 所有在线用户计数 +1
                    % 遍历所有用户，检查 Time >= OnlineUntil[i]
                    update_here(Mentions, OnlineUntil, Time, N);
                
                _ ->
                    % 指定 ID 列表 (例如 "id0 id1 id0")
                    Tokens = string:tokens(MentionsStr, " "),
                    update_ids(Mentions, Tokens)
            end,
            process_events(Rest, NewMentions, OnlineUntil, N)
    end.

%% 处理 "HERE"：更新所有在线用户
update_here(Mentions, OnlineUntil, Time, N) ->
    % 生成 0 到 N-1 的索引列表，并在折叠过程中更新数组
    lists:foldl(fun(Id, AccMentions) ->
        BackOnlineTime = array:get(Id, OnlineUntil),
        if
            Time >= BackOnlineTime -> 
                Count = array:get(Id, AccMentions),
                array:set(Id, Count + 1, AccMentions);
            true -> 
                AccMentions
        end
    end, Mentions, lists:seq(0, N - 1)).

%% 处理具体 ID 字符串：更新指定用户
update_ids(Mentions, Tokens) ->
    lists:foldl(fun(Token, AccMentions) ->
        % Token 格式为 "id<Number>"，去掉前两个字符 "id"
        IdStr = lists:nthtail(2, Token),
        Id = list_to_integer(IdStr),
        Count = array:get(Id, AccMentions),
        array:set(Id, Count + 1, AccMentions)
    end, Mentions, Tokens).