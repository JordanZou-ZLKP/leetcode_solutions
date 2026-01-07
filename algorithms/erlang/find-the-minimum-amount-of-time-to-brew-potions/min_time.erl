-spec min_time(Skill :: [integer()], Mana :: [integer()]) -> integer().
min_time(Skill, Mana) ->
    % 1. 计算 Skill 的前缀和 (Prefix Sums)
    % PrefixSums 列表结构为 [P0, P1, ..., Pn-1]
    PrefixSums = prefix_sums(Skill, 0, []),
    
    % TotalSkill 即 Pn-1，用于最后一步计算
    TotalSkill = lists:last(PrefixSums),
    
    % 2. 预处理巫师数据以便快速迭代
    % 我们将需要成对的 (Pi, Pi-1)。
    % 生成结构: [{P0, 0}, {P1, P0}, {P2, P1}, ...]
    WizData = prepare_wiz_data(PrefixSums, 0, []),
    
    % 3. 处理药水列表
    case Mana of
        [] -> 0;
        [FirstMana | RestMana] ->
            % 第一瓶药水从时刻 0 开始
            % 递归计算最后一瓶药水的 StartTime (相对于 Wizard 0)
            LastPotionStartTime = solve_potions(RestMana, FirstMana, 0, WizData),
            
            % 4. 最终结果 = 最后一瓶药水的开始时间 + 最后一瓶药水的总处理时长
            LastPotionMana = lists:last(Mana),
            LastPotionStartTime + (TotalSkill * LastPotionMana)
    end.

%% ---------------------------------------------------------
%% 辅助函数
%% ---------------------------------------------------------

%% 计算前缀和
prefix_sums([], _CurrentSum, Acc) ->
    lists:reverse(Acc);
prefix_sums([H | T], CurrentSum, Acc) ->
    NewSum = CurrentSum + H,
    prefix_sums(T, NewSum, [NewSum | Acc]).

%% 准备 (Pi, Pi-1) 对
prepare_wiz_data([], _PrevP, Acc) ->
    lists:reverse(Acc);
prepare_wiz_data([P | T], PrevP, Acc) ->
    prepare_wiz_data(T, P, [{P, PrevP} | Acc]).

%% 核心递归逻辑：遍历 Mana 数组
solve_potions([], _PrevMana, CurrentStartTime, _WizData) ->
    CurrentStartTime;
solve_potions([CurrMana | Rest], PrevMana, CurrentStartTime, WizData) ->
    % 计算两瓶药水之间必须的“间隔”(Offset)
    % Offset = max(Pi * PrevMana - Pi_prev * CurrMana) for all i
    Offset = find_max_offset(WizData, PrevMana, CurrMana, -1000000000000), % 初始化为一个极小值
    
    NewStartTime = CurrentStartTime + Offset,
    solve_potions(Rest, CurrMana, NewStartTime, WizData).

%% 遍历巫师，寻找最大的瓶颈时间差
find_max_offset([], _PrevM, _CurrM, MaxVal) ->
    MaxVal;
find_max_offset([{P_i, P_prev} | T], PrevM, CurrM, MaxVal) ->
    % 公式: (P_i * M_j-1) - (P_i-1 * M_j)
    Val = (P_i * PrevM) - (P_prev * CurrM),
    NewMax = max(Val, MaxVal),
    find_max_offset(T, PrevM, CurrM, NewMax).