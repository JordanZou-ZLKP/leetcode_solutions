-spec area_of_max_diagonal(Dimensions :: [[integer()]]) -> integer().
area_of_max_diagonal(Dimensions) ->
    % 初始状态：最大对角线平方为0，最大面积为0
    find_max(Dimensions, 0, 0).

%% 递归辅助函数
%% Base case: 列表为空时，返回累计的最大面积
find_max([], _MaxDiagSq, MaxArea) ->
    MaxArea;

%% Recursive step: 处理列表头部
find_max([[L, W] | Rest], MaxDiagSq, MaxArea) ->
    CurrentDiagSq = L * L + W * W,
    CurrentArea = L * W,
    
    if
        % Case 1: 发现更长的对角线，完全更新
        CurrentDiagSq > MaxDiagSq ->
            find_max(Rest, CurrentDiagSq, CurrentArea);
            
        % Case 2: 对角线长度相同，取面积较大者
        CurrentDiagSq =:= MaxDiagSq ->
            find_max(Rest, MaxDiagSq, max(MaxArea, CurrentArea));
            
        % Case 3: 当前对角线较短，保持原状
        true ->
            find_max(Rest, MaxDiagSq, MaxArea)
    end.