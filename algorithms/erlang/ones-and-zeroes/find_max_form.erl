-spec find_max_form(Strs :: [unicode:unicode_binary()], M :: integer(), N :: integer()) -> integer().

to_list(Ones) ->
    R = [binary_to_list(X) || X <- Ones].

find_max_form(Ones, M, N) ->
    % 1. 预处理：计算每个字符串的消耗 {Zeros, Ones}
    Strs = to_list(Ones),
    Costs = [count_zeros_ones(S) || S <- Strs],
    
    % 2. 初始化 DP 状态：没有任何消耗时，子集大小为 0
    % 使用 Map 存储状态 #{ {UsedZeros, UsedOnes} => SubsetCount }
    InitDP = #{ {0, 0} => 0 },
    
    % 3. 动态规划：遍历每个物品，更新 DP 表
    FinalDP = lists:foldl(fun({CostZ, CostO}, AccDP) ->
        update_dp(CostZ, CostO, AccDP, M, N)
    end, InitDP, Costs),
    
    % 4. 找出 FinalDP 中最大的 Value
    find_max_value(FinalDP).

%% @private
%% 计算字符串中 0 和 1 的数量
count_zeros_ones(Str) ->
    lists:foldl(fun(Char, {Z, O}) ->
        case Char of
            $0 -> {Z + 1, O};
            $1 -> {Z, O + 1};
            _  -> {Z, O} % 理论上不会出现，题目约束只有 0/1
        end
    end, {0, 0}, Str).

%% @private
%% 核心 DP 更新逻辑
%% 针对当前物品的消耗 {CostZ, CostO}，遍历现有的 DP 状态，
%% 尝试添加该物品，如果满足 M, N 限制且能产生更大的子集，则更新 Map。
update_dp(CostZ, CostO, DP, M, N) ->
    % 注意：这里我们遍历 DP (作为数据源)，同时将结果 merge 到 Acc (初始值为 DP)
    % 这样做相当于利用了上一轮的状态来计算下一轮，符合 0/1 背包的要求
    maps:fold(fun({CurZ, CurO}, Count, AccMap) ->
        NextZ = CurZ + CostZ,
        NextO = CurO + CostO,
        
        % 检查是否超出容量限制
        if
            NextZ =< M andalso NextO =< N ->
                NewCount = Count + 1,
                % 如果新状态 {NextZ, NextO} 之前不存在，或者新数量更大，则更新
                OldCount = maps:get({NextZ, NextO}, AccMap, -1),
                if
                    NewCount > OldCount -> AccMap#{ {NextZ, NextO} => NewCount };
                    true -> AccMap
                end;
            true ->
                AccMap
        end
    end, DP, DP).

%% @private
%% 从 Map 中提取最大的 Value
find_max_value(Map) ->
    maps:fold(fun(_, Val, Max) ->
        erlang:max(Val, Max)
    end, 0, Map).