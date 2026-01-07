-spec max_sub_array(Nums :: [integer()]) -> integer().

max_sub_array([H|T]) ->
    %% 初始状态：
    %% CurrentSum (当前累加和) = H
    %% MaxSum (全局最大和) = H
    kadane(T, H, H).

%% 递归基准情况：列表为空，返回全局最大和
kadane([], _CurrentSum, MaxSum) ->
    MaxSum;

%% 递归步骤
kadane([H|T], CurrentSum, MaxSum) ->
    %% 核心逻辑：
    %% 如果 (CurrentSum + H) < H，说明之前的 CurrentSum 是负累赘，
    %% 不如直接从 H 开始另起炉灶。
    %% 所以 NewCurrent = max(H, CurrentSum + H)
    NewCurrent = max(H, CurrentSum + H),
    
    %% 更新全局最大值
    NewMax = max(MaxSum, NewCurrent),
    
    %% 继续递归
    kadane(T, NewCurrent, NewMax).

