-spec count_unguarded(M :: integer(), N :: integer(), Guards :: [[integer()]], Walls :: [[integer()]]) -> integer().
count_unguarded(M, N, Guards, Walls) ->
    % 创建 ETS 表，用于存储网格状态
    % set: 键值唯一
    % private: 仅当前进程读写，性能最高
    Grid = ets:new(grid_table, [set, private]),

    % 1. 将墙和警卫标记为 'block' (阻挡物)
    % 时间复杂度: O(W + G)
    lists:foreach(fun([R, C]) -> 
        ets:insert(Grid, {{R, C}, block}) 
    end, Walls),
    
    lists:foreach(fun([R, C]) -> 
        ets:insert(Grid, {{R, C}, block}) 
    end, Guards),

    % 2. 遍历每个警卫，向四个方向扫描
    % 时间复杂度: O(m * n)，因为每个格子最多被访问 4 次 (每个方向 1 次)
    lists:foreach(fun([R, C]) ->
        scan_direction(Grid, R - 1, C, -1, 0, M, N), % North
        scan_direction(Grid, R + 1, C, 1, 0, M, N),  % South
        scan_direction(Grid, R, C - 1, 0, -1, M, N), % West
        scan_direction(Grid, R, C + 1, 0, 1, M, N)   % East
    end, Guards),

    % 3. 计算结果
    % ETS 的 size 是所有 (警卫 + 墙 + 被监视区域) 的总和
    GuardedCount = ets:info(Grid, size),
    
    % 清理 ETS 表
    ets:delete(Grid),
    
    % 结果 = 总格子数 - (障碍物 + 被监视的格子)
    (M * N) - GuardedCount.

%% 递归扫描函数
scan_direction(_Grid, R, C, _Dr, _Dc, M, N) 
  when R < 0; C < 0; R >= M; C >= N ->
    % 越界，停止扫描
    ok;
scan_direction(Grid, R, C, Dr, Dc, M, N) ->
    case ets:lookup(Grid, {R, C}) of
        [{_, block}] -> 
            % 遇到墙或警卫，视线被阻挡，停止
            ok;
        [{_, guarded}] ->
            % 已经是被监视状态，视线穿透，继续向前
            scan_direction(Grid, R + Dr, C + Dc, Dr, Dc, M, N);
        [] ->
            % 空地，标记为被监视，并继续向前
            ets:insert(Grid, {{R, C}, guarded}),
            scan_direction(Grid, R + Dr, C + Dc, Dr, Dc, M, N)
    end.