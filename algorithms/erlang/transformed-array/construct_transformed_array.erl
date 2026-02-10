-spec construct_transformed_array(Nums :: [integer()]) -> [integer()].
construct_transformed_array(Nums) ->
    % 1. 获取列表长度 N
    N = length(Nums),
    
    % 2. 将列表转换为元组 (Tuple)，以便进行 O(1) 的随机访问
    %    注意: Erlang 的 Tuple 索引是从 1 开始的
    Arr = list_to_tuple(Nums),
    
    % 3. 生成 0 到 N-1 的索引序列，并对每个索引进行映射计算
    lists:map(fun(I) ->
        % 获取当前位置的步数 (注意：Arr 索引需 I + 1)
        Steps = element(I + 1, Arr),
        
        % 计算目标索引 (0-based)
        % 公式逻辑: (当前索引 + 步数) % 长度
        % 使用 ((X rem N) + N) rem N 的技巧来处理负数取模的情况
        % 例如: -1 rem 5 = -1, (-1 + 5) rem 5 = 4
        TargetIndex = ((I + Steps) rem N + N) rem N,
        
        % 获取目标索引处的值 (注意：Arr 索引需 TargetIndex + 1)
        element(TargetIndex + 1, Arr)
    end, lists:seq(0, N - 1)).