-spec soup_servings(N :: integer()) -> float().
soup_servings(N) ->
    % 优化：当 N 大于等于 4800 时，概率收敛于 1.0
    % 这将时间复杂度从 O(N^2) 降低到了 O(1)
    if
        N >= 4800 -> 1.0;
        true ->
            % 归一化：将 N 转换为单位数量 (1 unit = 25ml)
            % 使用 (N + 24) div 25 实现向上取整
            M = (N + 24) div 25,
            
            % 创建一个私有的 ETS 表用于记忆化搜索
            % set: 键值对存储
            % private: 只有当前进程可以读写，提高性能
            Tid = ets:new(memo, [set, private]),
            
            Result = solve(M, M, Tid),
            
            % 清理 ETS 表
            ets:delete(Tid),
            Result
    end.

%% 递归求解函数
%% A: A 汤剩余单位
%% B: B 汤剩余单位
%% Tid: ETS 表 ID

%% Base Case 1: A 和 B 同时耗尽（或在此之前 A 已耗尽但本轮导致 B 也耗尽）
solve(A, B, _Tid) when A =< 0, B =< 0 -> 
    0.5;

%% Base Case 2: A 先耗尽
solve(A, _B, _Tid) when A =< 0 -> 
    1.0;

%% Base Case 3: B 先耗尽 (A 还有剩余)
solve(_A, B, _Tid) when B =< 0 -> 
    0.0;

%% 递归步骤
solve(A, B, Tid) ->
    % 检查缓存中是否已有结果
    case ets:lookup(Tid, {A, B}) of
        [{_, Val}] -> 
            Val;
        [] ->
            % 状态转移方程：
            % P(A,B) = 0.25 * (P(A-4,B) + P(A-3,B-1) + P(A-2,B-2) + P(A-1,B-3))
            Res = 0.25 * (
                solve(A - 4, B, Tid) +
                solve(A - 3, B - 1, Tid) +
                solve(A - 2, B - 2, Tid) +
                solve(A - 1, B - 3, Tid)
            ),
            % 将计算结果存入 ETS
            ets:insert(Tid, {{A, B}, Res}),
            Res
    end.