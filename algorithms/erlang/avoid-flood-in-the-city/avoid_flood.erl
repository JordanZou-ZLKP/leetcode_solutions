-spec avoid_flood(Rains :: [integer()]) -> [integer()].
avoid_flood(Rains) ->
    Len = length(Rains),
    %% 初始化结果数组，默认填充1（如果晴天没被用到，默认抽干1号湖，符合题意）
    %% 同时也便于直接将非0天数设为-1
    AnsArray = array:new(Len, [{default, 1}]),
    
    %% 使用 gb_sets 存储晴天的索引，支持 O(log N) 查找
    ZeroIndices = gb_sets:new(),
    
    %% 使用 Map 记录湖泊满水的上一次索引
    FullLakes = #{},
    
    try
        {FinalAns, _, _} = lists:foldl(fun process_day/2, 
                                       {AnsArray, ZeroIndices, FullLakes}, 
                                       lists:zip(lists:seq(0, Len - 1), Rains)),
        array:to_list(FinalAns)
    catch
        throw:impossible -> []
    end.

%% 处理每一天的逻辑
process_day({Idx, Lake}, {Ans, Zeros, FullMap}) ->
    if
        %% Case 1: 晴天 (Lake == 0)
        Lake == 0 ->
            NewZeros = gb_sets:add(Idx, Zeros),
            %% 结果数组这天暂时保持默认值(1)，如果后面需要用这天抽水再更新
            {Ans, NewZeros, FullMap};

        %% Case 2: 雨天 (Lake > 0)
        Lake > 0 ->
            %% 雨天结果必须是 -1
            Ans1 = array:set(Idx, -1, Ans),
            
            case maps:find(Lake, FullMap) of
                error ->
                    %% 湖泊之前没满，记录这次下雨的索引
                    {Ans1, Zeros, FullMap#{Lake => Idx}};
                
                {ok, LastRainIdx} ->
                    %% 湖泊满了，即将发生洪水！
                    %% 我们需要在 LastRainIdx 之后找到一个最早的晴天
                    
                    %% iterator_from 返回 >= Key 的迭代器
                    Iter = gb_sets:iterator_from(LastRainIdx + 1, Zeros),
                    
                    case gb_sets:next(Iter) of
                        none ->
                            %% 没有可用的晴天，洪水无法避免
                            throw(impossible);
                        {ZeroIdx, _} ->
                            %% 找到了可用的晴天 ZeroIdx
                            %% 1. 在那一天抽干当前的 Lake
                            Ans2 = array:set(ZeroIdx, Lake, Ans1),
                            %% 2. 消耗掉这个晴天索引
                            NewZeros = gb_sets:delete(ZeroIdx, Zeros),
                            %% 3. 更新该湖泊最后一次下雨的时间为当前 Idx
                            {Ans2, NewZeros, FullMap#{Lake => Idx}}
                    end
            end
    end.