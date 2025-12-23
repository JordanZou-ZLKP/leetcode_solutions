-spec count_trapezoids(Points :: [[integer()]]) -> integer().

count_trapezoids(Points) ->
    N = length(Points),
    if
        N < 4 -> 0;
        true ->
            %% 1. 生成所有点对并统计特征
            {SlopeMap, LineMap, MidMap} = process_points(Points),
            
            %% 2. 计算基于平行边的初步总数（包含重复的平行四边形）
            %% 公式：Sum(C(Slope_Count, 2)) - Sum(C(Line_Count, 2))
            TotalParallelPairs = calc_slope_combinations(SlopeMap) - calc_line_combinations(LineMap),
            
            %% 3. 计算平行四边形的数量
            %% 平行四边形的对角线互相平分，即共享中点
            Parallelograms = calc_parallelograms(MidMap),
            
            %% 4. 结果 = (所有单平行对 + 2 * 双平行对) - (双平行对)
            %% 我们希望只统计点集一次，所以减去平行四边形数量
            TotalParallelPairs - Parallelograms
    end.

%% 处理点集，生成三个统计 Map
process_points(Points) ->
    %% 转换为带索引的元组以便处理
    IndexedPoints = lists:zip(lists:seq(1, length(Points)), Points),
    
    %% 遍历所有唯一的点对
    lists:foldl(fun({Idx1, [X1, Y1]}, Acc1) ->
        lists:foldl(fun({Idx2, [X2, Y2]}, {AccSlope, AccLine, AccMid}) ->
            if 
                Idx2 > Idx1 ->
                    %% 计算几何特征
                    Slope = get_slope(X1, Y1, X2, Y2),
                    Line = get_line_equation(X1, Y1, X2, Y2),
                    Mid = {X1 + X2, Y1 + Y2}, %% 使用两倍中点避免浮点数
                    
                    %% 更新 SlopeMap
                    NewAccSlope = update_count(Slope, AccSlope),
                    
                    %% 更新 LineMap
                    NewAccLine = update_count(Line, AccLine),
                    
                    %% 更新 MidMap: Key=Midpoint, Val=Map(Slope => Count)
                    SubMap = maps:get(Mid, AccMid, #{}),
                    NewSubMap = update_count(Slope, SubMap),
                    NewAccMid = maps:put(Mid, NewSubMap, AccMid),
                    
                    {NewAccSlope, NewAccLine, NewAccMid};
                true ->
                    {AccSlope, AccLine, AccMid}
            end
        end, Acc1, IndexedPoints)
    end, {#{}, #{}, #{}}, IndexedPoints).

%% 辅助函数：Map 计数器 +1
update_count(Key, Map) ->
    Count = maps:get(Key, Map, 0),
    maps:put(Key, Count + 1, Map).

%% 计算斜率产生的组合数 C(n, 2)
calc_slope_combinations(Map) ->
    maps:fold(fun(_, Count, Sum) -> Sum + (Count * (Count - 1) div 2) end, 0, Map).

%% 计算共线产生的无效组合数 C(n, 2)
calc_line_combinations(Map) ->
    maps:fold(fun(_, Count, Sum) -> Sum + (Count * (Count - 1) div 2) end, 0, Map).

%% 计算平行四边形数量
calc_parallelograms(MidMap) ->
    maps:fold(fun(_MidPoint, SlopeCounts, TotalP) ->
        %% 对于同一个中点，我们需要选择两条斜率不同的对角线
        %% 设该中点下总线段数为 TotalSegs
        %% 所有组合数为 C(TotalSegs, 2)
        %% 其中斜率相同的对（共线对角线）不能构成平行四边形，需减去
        
        TotalSegs = maps:fold(fun(_, C, Acc) -> Acc + C end, 0, SlopeCounts),
        
        if 
            TotalSegs < 2 -> TotalP;
            true ->
                TotalCombs = TotalSegs * (TotalSegs - 1) div 2,
                InvalidCombs = maps:fold(fun(_, C, Acc) -> 
                    Acc + (C * (C - 1) div 2) 
                end, 0, SlopeCounts),
                TotalP + (TotalCombs - InvalidCombs)
        end
    end, 0, MidMap).

%% --- 几何辅助函数 ---

%% 计算标准化斜率 {dy, dx}
get_slope(X1, Y1, X2, Y2) ->
    Dy = Y1 - Y2,
    Dx = X1 - X2,
    normalize(Dy, Dx).

%% 计算标准化直线方程 {A, B, C} 对应 Ax + By + C = 0
get_line_equation(X1, Y1, X2, Y2) ->
    A = Y1 - Y2,
    B = X2 - X1,
    C = -A * X1 - B * Y1,
    
    %% 标准化：除以 GCD 并处理符号
    G = gcd(abs(A), gcd(abs(B), abs(C))),
    A1 = A div G,
    B1 = B div G,
    C1 = C div G,
    
    %% 确保首项非零元素为正，以此作为唯一标识
    if
        A1 > 0 -> {A1, B1, C1};
        A1 < 0 -> {-A1, -B1, -C1};
        A1 == 0, B1 > 0 -> {0, B1, C1};
        A1 == 0, B1 < 0 -> {0, -B1, -C1};
        true -> {0, 0, 0} %% 不可能发生（两点不同）
    end.

%% 标准化分数/向量 (dy/dx)
normalize(0, _) -> {0, 1}; %% 水平
normalize(_, 0) -> {1, 0}; %% 垂直
normalize(Dy, Dx) ->
    G = gcd(abs(Dy), abs(Dx)),
    Dy1 = Dy div G,
    Dx1 = Dx div G,
    if
        Dx1 < 0 -> {-Dy1, -Dx1}; %% 保持分母(x)为正
        true -> {Dy1, Dx1}
    end.

%% 最大公约数
gcd(A, 0) -> A;
gcd(A, B) -> gcd(B, A rem B).