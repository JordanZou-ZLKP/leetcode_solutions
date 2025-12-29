-spec max_increasing_subarrays(Nums :: [integer()]) -> integer().

max_increasing_subarrays(Nums) when length(Nums) < 2 ->
    0;
max_increasing_subarrays(Nums) ->
    % 1. 预处理：计算从每个位置开始的递增长度
    RevNums = lists:reverse(Nums),
    RightLens = build_right_lens(RevNums),
    % RightLens 例如: [3, 2, 1] 对应索引 0, 1, 2
    
    % 2. 单独处理第一个分割点（索引0 和 索引1 之间）
    % 左边以索引0结尾（长度必为1），右边以索引1开始
    [_, LenStartAt1 | _] = RightLens, 
    InitMaxK = min(1, LenStartAt1),

    % 3. 准备主循环
    % 主循环将从索引 1 的元素开始处理 (Curr)。
    % 当我们计算以索引 1 结尾的左数组时，我们需要匹配以索引 2 开始的右数组。
    % 所以我们需要 RightLens 列表丢弃掉前两个元素（对应索引0和1的数据）。
    RightLensForLoop = drop_safe(2, RightLens),
    
    % Nums 的头部用于初始化 Prev，循环从 T 开始
    [Head | Tail] = Nums,
    solve_loop(Tail, RightLensForLoop, Head, 1, InitMaxK).

%% @private
%% 构建 RightLens (同前)
build_right_lens([]) -> [];
build_right_lens([H|T]) ->
    build_right_lens(T, H, 1, [1]).

build_right_lens([], _, _, Acc) -> Acc; 
build_right_lens([Curr|T], Prev, RunLen, Acc) ->
    NewRunLen = if 
        Curr < Prev -> RunLen + 1;
        true -> 1
    end,
    build_right_lens(T, Curr, NewRunLen, [NewRunLen | Acc]).

%% @private
%% 主循环
%% RightList 的头部必须对应 "当前索引 + 1" 开始的长度
solve_loop([], _, _, _, MaxK) ->
    MaxK;
solve_loop(_, [], _, _, MaxK) ->
    % 如果右边没有更多数据了（说明无法构成右侧子数组），直接返回
    MaxK;
solve_loop([Curr|T_Nums], [RightLen|T_Right], Prev, CurIncLen, MaxK) ->
    % 计算以当前位置结尾的递增长度
    NewIncLen = if 
        Curr > Prev -> CurIncLen + 1;
        true -> 1
    end,
    
    % 核心逻辑：
    % 左数组：以 Curr 结尾，长度 NewIncLen
    % 右数组：以 Next 索引开始，长度 RightLen (这是预先对齐好的)
    CurrentK = min(NewIncLen, RightLen),
    NewMaxK = max(MaxK, CurrentK),
    
    solve_loop(T_Nums, T_Right, Curr, NewIncLen, NewMaxK).

%% Helpers
min(A, B) when A < B -> A;
min(_, B) -> B.

max(A, B) when A > B -> A;
max(_, B) -> B.

% 安全删除前N个元素，如果列表不够长返回空
drop_safe(0, L) -> L;
drop_safe(_, []) -> [];
drop_safe(N, [_|T]) -> drop_safe(N-1, T).