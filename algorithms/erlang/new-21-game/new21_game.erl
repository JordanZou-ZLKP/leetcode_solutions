-spec new21_game(N :: integer(), K :: integer(), MaxPts :: integer()) -> float().

new21_game(_N, 0, _MaxPts) ->
    %% K=0 时，Alice 开局即停，分数 0 <= N，概率 1.0
    1.0;
new21_game(N, K, MaxPts) ->
    if
        %% 如果 K-1 (最大非停止分) + MaxPts (最大抽牌) <= N
        %% 则无论如何都不会爆，概率 1.0
        N >= K + MaxPts -> 1.0;
        true ->
            %% 初始化滑动窗口
            MaxReach = K + MaxPts - 1,
            %% 计算在 [K, K+MaxPts-1] 范围内有多少个数字 <= N
            ValidOutcomes = min(N, MaxReach) - K + 1,
            InitialSum = float(max(0, ValidOutcomes)),
            
            %% 初始化数组，大小为 K，默认值为 0.0
            DpArray = array:new(K, {default, 0.0}),
            
            %% 开始逆向 DP
            %% 关键修正：MaxPts 保持 integer 类型，不要转 float
            solve(K - 1, InitialSum, MaxPts, N, K, DpArray)
    end.

%% ---------------------------------------------------------
%% 递归求解函数
%% ---------------------------------------------------------

%% 终止条件：算到了 dp[0]
solve(0, WindowSum, MaxPts, _N, _K, _DpArray) ->
    %% Erlang 的 '/' 运算符结果总是 float，无需显式转换
    WindowSum / MaxPts;

solve(I, WindowSum, MaxPts, N, K, DpArray) ->
    %% 1. 计算当前 dp[I]
    CurrentProb = WindowSum / MaxPts,
    
    %% 2. 存入数组 (O(1) ~ O(log K))
    NewDpArray = array:set(I, CurrentProb, DpArray),
    
    %% 3. 维护滑动窗口
    %% 我们需要减去窗口最右侧移出的那个值：dp[I + MaxPts]
    RemoveIndex = I + MaxPts, 
    %% 注意：这里 I 和 MaxPts 都是整数，所以 RemoveIndex 是整数
    
    RemoveProb = get_prob(RemoveIndex, N, K, NewDpArray),
    
    %% 新窗口和 = 旧窗口和 + 新进入的值(dp[I]) - 移出的值
    NewSum = WindowSum + CurrentProb - RemoveProb,
    
    %% 递归计算下一个
    solve(I - 1, NewSum, MaxPts, N, K, NewDpArray).

%% ---------------------------------------------------------
%% 辅助函数：获取概率
%% ---------------------------------------------------------
get_prob(Index, N, K, DpArray) ->
    if
        Index < K -> 
            %% 从数组获取，Index 必须是整数
            array:get(Index, DpArray);
        Index =< N -> 
            %% 游戏结束且获胜
            1.0;
        true -> 
            %% 游戏结束且失败 (> N)
            0.0
    end.