-spec minimum_teachings(N :: integer(), Languages :: [[integer()]], Friendships :: [[integer()]]) -> integer().

%% N: 语言总数 (Integer)
%% Languages: 每个用户掌握的语言列表 (List of Lists, e.g., [[1], [2], [1,2]])
%% Friendships: 好友关系列表 (List of Lists, e.g., [[1,2], [1,3]])
%% Returns: 需要教的最少人数 (Integer)

minimum_teachings(N, Languages, Friendships) ->
    % 1. 预处理：将语言列表转换为 Map，Key为用户ID(1-based)，Value为语言的Set
    % 时间复杂度: O(M * K)，M为用户数，K为用户平均掌握语言数
    UserIds = lists:seq(1, length(Languages)),
    UserLangMap = maps:from_list(
        lists:zip(UserIds, [sets:from_list(L) || L <- Languages])
    ),

    % 2. 找出所有无法沟通的好友对中涉及的用户
    % 时间复杂度: O(F * K)，F为好友对数量
    ConflictUsersSet = lists:foldl(fun([U, V], AccSet) ->
        LangsU = maps:get(U, UserLangMap),
        LangsV = maps:get(V, UserLangMap),
        
        % 检查是否有交集 (intersection)
        % 如果 disjoint 为 true，说明没有共同语言，需要加入冲突集合
        case sets:is_disjoint(LangsU, LangsV) of
            true -> 
                AccSet1 = sets:add_element(U, AccSet),
                sets:add_element(V, AccSet1);
            false -> 
                AccSet
        end
    end, sets:new(), Friendships),

    % 3. 计算结果
    ConflictCount = sets:size(ConflictUsersSet),
    
    case ConflictCount of
        0 -> 0; % 所有好友都能沟通
        _ ->
            % 统计冲突用户中，每种语言的持有频率
            % 时间复杂度: O(M_conflict * K)
            LangFreqMap = sets:fold(fun(User, AccMap) ->
                UserLangs = maps:get(User, UserLangMap),
                sets:fold(fun(Lang, InnerAcc) ->
                    maps:update_with(Lang, fun(C) -> C + 1 end, 1, InnerAcc)
                end, AccMap, UserLangs)
            end, #{}, ConflictUsersSet),
            
            % 找出最大的频率 (即最多人懂的语言)
            % 时间复杂度: O(N)
            MaxFreq = maps:fold(fun(_, Count, Max) -> 
                max(Count, Max) 
            end, 0, LangFreqMap),
            
            % 结果 = 总冲突人数 - 已经懂该最优语言的人数
            ConflictCount - MaxFreq
    end.