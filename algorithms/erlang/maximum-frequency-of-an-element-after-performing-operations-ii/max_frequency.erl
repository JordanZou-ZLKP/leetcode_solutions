-spec max_frequency(Nums :: [integer()], K :: integer(), NumOperations :: integer()) -> integer().

max_frequency(Nums, K, NumOperations) ->
    % 1. 统计每个数字出现的原始频率 (Exact Count)
    % 时间复杂度: O(N)
    FreqMap = lists:foldl(fun(X, Acc) -> 
        maps:update_with(X, fun(V) -> V + 1 end, 1, Acc) 
    end, #{}, Nums),
    
    % 2. 生成扫描线事件
    % 事件格式: {坐标, 优先级, 增量值/类型}
    % 优先级设计 (数值越小越先处理): 
    %   1 (End): 区间结束，先减少覆盖
    %   2 (Start): 区间开始，增加覆盖
    %   3 (Check): 检查点，计算结果
    
    % 区间开始事件: nums[i] - k
    EventsStart = [ {X - K, 2, 1} || X <- Nums ],
    
    % 区间结束事件: nums[i] + k + 1 (闭区间结束后的下一个位置)
    EventsEnd = [ {X + K + 1, 1, -1} || X <- Nums ],
    
    % 检查点事件: 只需要在原始数组中存在的数字处检查
    UniqueNums = maps:keys(FreqMap),
    EventsCheck = [ {X, 3, 0} || X <- UniqueNums ],
    
    % 合并并排序所有事件
    % 时间复杂度: O(N log N)
    AllEvents = lists:sort(EventsStart ++ EventsEnd ++ EventsCheck),
    
    % 3. 执行扫描
    % 时间复杂度: O(N)
    sweep(AllEvents, 0, 0, FreqMap, NumOperations).

%% sweep(Events, CurrentOverlap, MaxFreqSoFar, FreqMap, MaxOps)
sweep([], _, MaxAns, _, _) -> 
    MaxAns;
sweep([{Coord, Type, Val} | Rest], CurrentOverlap, MaxAns, FreqMap, Ops) ->
    % 更新当前的覆盖层数
    % 如果是 Start (Type=2), Val=1, Overlap 增加
    % 如果是 End (Type=1), Val=-1, Overlap 减少
    % 如果是 Check (Type=3), Val=0, Overlap 不变
    NewOverlap = CurrentOverlap + Val,
    
    NewMax = case Type of
        3 -> 
            % 处理检查点 (Target X 在原数组中存在)
            % 此时 exact_count > 0
            ExactCount = maps:get(Coord, FreqMap, 0),
            
            % 逻辑:
            % 总共可以变成此数值的数量是 NewOverlap。
            % 但是我们最多只能改变 Ops 个数字。
            % 已经等于该数值的 (ExactCount) 不需要改变。
            % 所以最大可能是 ExactCount + Ops，但不能超过物理存在的总数 NewOverlap。
            Possible = min(NewOverlap, ExactCount + Ops),
            max(MaxAns, Possible);
        _ ->
            % 处理区间变化 (Start 或 End)
            % 这里的隐含 Target X 是不在原数组中的某个数。
            % 此时 exact_count = 0。
            % 我们只能通过修改操作获得这个数，上限是 Ops。
            % 同时受限于覆盖该点的区间总数 NewOverlap。
            Possible = min(NewOverlap, Ops),
            max(MaxAns, Possible)
    end,
    
    sweep(Rest, NewOverlap, NewMax, FreqMap, Ops).