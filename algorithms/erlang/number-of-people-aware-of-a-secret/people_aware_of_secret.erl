-spec people_aware_of_secret(N :: integer(), Delay :: integer(), Forget :: integer()) -> integer().

-define(MOD, 1000000007).

%% @doc
%% N: 目标天数
%% Delay: 发现秘密后等待多少天开始分享
%% Forget: 发现秘密后多少天会忘记
%% Time Complexity: O(N) - 只需要遍历一次天数
%% Space Complexity: O(N) - 使用 Map 存储每天的新增人数
people_aware_of_secret(N, Delay, Forget) ->
    % dp map 存储: Day -> 当天新增的知情人数
    % 第1天有1个人发现秘密
    Dp = #{1 => 1},
    
    % 从第2天开始模拟直到第N天
    % InitialShareCount 为0，因为第1天的人还没过Delay期
    FinalDp = loop(2, N, Delay, Forget, Dp, 0),
    
    % 统计第N天结束时还记得秘密的人
    % 即：从 (N - Forget + 1) 到 N 期间所有新增的人
    count_active_people(N, N - Forget + 1, FinalDp, 0).

%% 主循环：计算每一天的新增人数
loop(CurrentDay, N, _Delay, _Forget, Dp, _ShareCount) when CurrentDay > N ->
    Dp;
loop(CurrentDay, N, Delay, Forget, Dp, ShareCount) ->
    % 1. 处理开始分享的人：CurrentDay - Delay 那天发现秘密的人，今天开始分享
    NewSharers = maps:get(CurrentDay - Delay, Dp, 0),
    
    % 2. 处理停止分享的人：CurrentDay - Forget 那天发现秘密的人，今天忘记了（不能分享）
    LeavingSharers = maps:get(CurrentDay - Forget, Dp, 0),
    
    % 3. 更新当前能够分享秘密的人数总和
    % 注意处理减法后的负数情况 (Erlang rem 保留符号)
    Delta = (NewSharers - LeavingSharers),
    NewShareCount = (ShareCount + Delta) rem ?MOD,
    SafeShareCount = if NewShareCount < 0 -> NewShareCount + ?MOD; true -> NewShareCount end,
    
    % 4. 今天的 ShareCount 就是今天新增的人数 (每人分享给1个新人)
    NewDp = Dp#{CurrentDay => SafeShareCount},
    
    loop(CurrentDay + 1, N, Delay, Forget, NewDp, SafeShareCount).

%% 统计最终结果
count_active_people(EndDay, StartDay, _Dp, Acc) when StartDay > EndDay ->
    Acc;
count_active_people(EndDay, StartDay, Dp, Acc) ->
    Count = maps:get(StartDay, Dp, 0),
    NewAcc = (Acc + Count) rem ?MOD,
    count_active_people(EndDay, StartDay + 1, Dp, NewAcc).