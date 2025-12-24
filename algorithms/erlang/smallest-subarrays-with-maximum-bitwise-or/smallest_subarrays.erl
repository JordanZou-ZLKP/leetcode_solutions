-spec smallest_subarrays(Nums :: [integer()]) -> [integer()].
smallest_subarrays(Nums) ->
    N = length(Nums),
    % 将列表转换为元组，以便进行 O(1) 的随机访问
    NumsTuple = list_to_tuple(Nums),
    % 初始化位位置记录 (0-29位)，初始值为 -1
    % Tuple size 30, value -1.
    InitPos = erlang:make_tuple(30, -1),
    % 从后往前遍历 (N-1 -> 0)
    solve(N - 1, NumsTuple, InitPos, 0, []).

%% @private
%% 核心递归函数
%% I: 当前索引
%% Nums: 原始数组元组
%% Pos: 记录每个位(0-29)最近一次出现的索引位置的元组
%% SuffixOR: 从 I 到 N-1 的累积最大 OR 值
%% Acc: 结果累积器
solve(I, _Nums, _Pos, _SuffixOR, Acc) when I < 0 ->
    Acc; % 完成遍历，Acc 已经是正序的（因为我们是从后往前 cons）

solve(I, Nums, Pos, SuffixOR, Acc) ->
    % 获取当前数值 (Erlang tuple 是 1-based，所以用 I+1)
    Val = element(I + 1, Nums),
    
    % 计算当前位置能达到的最大理论 OR 值 (即后缀 OR)
    TargetOR = SuffixOR bor Val,
    
    % 更新位的位置信息：如果 Val 的第 b 位是 1，则更新 Pos 中对应位为当前索引 I
    NewPos = update_positions(Val, I, Pos, 0),
    
    % 提取所有有效的索引并排序
    % 这些索引是 OR 值可能发生变化的候选点
    CandidateIndices = get_sorted_indices(NewPos),
    
    % 在候选索引中寻找最短满足条件的长度
    Len = find_min_length(CandidateIndices, Nums, Val, TargetOR, I),
    
    % 继续处理下一个位置 (I-1)
    solve(I - 1, Nums, NewPos, TargetOR, [Len | Acc]).

%% @private
%% 更新 30 个位的最近出现位置
%% 这是一个手动展开的递归，处理 0 到 29 位
update_positions(_Val, _Idx, Pos, 30) ->
    Pos;
update_positions(Val, Idx, Pos, Bit) ->
    % 检查 Val 的第 Bit 位是否为 1
    IsSet = (Val band (1 bsl Bit)) > 0,
    if
        IsSet ->
            % 如果位被设置，更新元组中对应位置 (Bit+1) 为当前索引 Idx
            NewPos = setelement(Bit + 1, Pos, Idx),
            update_positions(Val, Idx, NewPos, Bit + 1);
        true ->
            % 如果位没被设置，保留原样（即保留该位在右侧最近出现的索引）
            update_positions(Val, Idx, Pos, Bit + 1)
    end.

%% @private
%% 从 Pos 元组中提取非 -1 的索引，去重并排序
get_sorted_indices(PosTuple) ->
    List = tuple_to_list(PosTuple),
    % 过滤掉 -1，并且去重
    ValidIndices = lists:usort([Idx || Idx <- List, Idx /= -1]),
    ValidIndices.

    
% 修正 find_min_length 的入口逻辑：
% 我们传入的 CurrentOR 是 nums[StartIdx]。
% 如果一开始就满足，直接返回 1。
% 否则进入列表循环。
% 上面的 find_min_length 实现有一个小逻辑漏洞：它在列表头部处理时有点混淆。
% 让我们重写一个更清晰的版本。

find_min_length(Indices, Nums, InitialVal, TargetOR, StartIdx) ->
    if 
        InitialVal == TargetOR -> 1;
        true -> find_min_length_loop(Indices, Nums, InitialVal, TargetOR, StartIdx)
    end.

find_min_length_loop([Idx | Rest], Nums, CurrentOR, TargetOR, StartIdx) ->
    % Idx 是 StartIdx 右侧的索引 (因为我们是在向右扩充)
    % 如果 Idx <= StartIdx，说明它是当前位置，已经在 InitialVal 计算过了，跳过
    if 
        Idx =< StartIdx -> 
            find_min_length_loop(Rest, Nums, CurrentOR, TargetOR, StartIdx);
        true ->
            Val = element(Idx + 1, Nums),
            NewOR = CurrentOR bor Val,
            if 
                NewOR == TargetOR -> 
                    Idx - StartIdx + 1;
                true -> 
                    find_min_length_loop(Rest, Nums, NewOR, TargetOR, StartIdx)
            end
    end;
find_min_length_loop([], _, _, _, _) -> 
    1. % Fallback