-spec is_trionic(Nums :: [integer()]) -> boolean().

is_trionic(L) when length(L) < 4 -> 
    false;

% 情况 2: 列表开头必须是严格递增 (nums[0] < nums[1])
% A 是当前值，B 是下一个值
is_trionic([A, B | Rest]) when A < B ->
    % 进入第一阶段：继续爬升寻找峰值 p
    find_peak(B, Rest);

% 其他情况（开头递减或相等）直接失败
is_trionic(_) -> 
    false.

%% ---------------------------------------------------------
%% 阶段 1: 寻找峰值 p (Strictly Increasing)
%% ---------------------------------------------------------
find_peak(Current, [Next | Rest]) ->
    if
        Current < Next -> 
            % 还在上升，继续寻找峰值
            find_peak(Next, Rest);
        Current > Next -> 
            % 发现下降，说明 Current 是峰值 p，进入阶段 2
            find_valley(Next, Rest);
        true -> 
            % 相等的情况 (Current == Next)，不符合严格递增/递减，失败
            false
    end;
find_peak(_, []) -> 
    % 遍历结束却没发现下降（纯递增数组），失败
    false.

%% ---------------------------------------------------------
%% 阶段 2: 寻找谷底 q (Strictly Decreasing)
%% ---------------------------------------------------------
find_valley(Current, [Next | Rest]) ->
    if
        Current > Next -> 
            % 还在下降，继续寻找谷底
            find_valley(Next, Rest);
        Current < Next -> 
            % 发现上升，说明 Current 是谷底 q，进入阶段 3
            check_final_ascent(Next, Rest);
        true -> 
            % 相等，失败
            false
    end;
find_valley(_, []) -> 
    % 遍历结束却没发现再次上升（递增后一直递减），失败
    false.

%% ---------------------------------------------------------
%% 阶段 3: 检查最后的上升段 (Strictly Increasing)
%% ---------------------------------------------------------
check_final_ascent(Current, [Next | Rest]) ->
    if
        Current < Next -> 
            % 保持上升，继续检查
            check_final_ascent(Next, Rest);
        true -> 
            % 遇到下降或相等，结构被破坏，失败
            false
    end;
check_final_ascent(_, []) -> 
    % 成功到达列表末尾，且一直保持上升，符合所有条件
    true.