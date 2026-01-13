-spec separate_squares(Squares :: [[integer()]]) -> float().
separate_squares(Squares) ->
    % 1. 计算总面积
    TotalArea = calculate_total_area(Squares, 0),
    Target = TotalArea / 2.0,

    % 2. 生成扫描线事件：{Y坐标, 宽度变化量}
    % 每个正方形产生两个事件：底边增加宽度，顶边减少宽度
    Events = generate_events(Squares),
    
    % 3. 按Y坐标排序事件
    SortedEvents = lists:sort(Events),
    
    % 4. 扫描线算法寻找目标Y
    % 初始状态：从第一个事件的Y开始，当前宽度为0，累积面积为0
    [{FirstY, _} | _] = SortedEvents,
    scan(SortedEvents, FirstY, 0, 0, Target).

%% 辅助函数：计算所有正方形的总面积
calculate_total_area([], Acc) -> 
    Acc;
calculate_total_area([[_, _, L] | Rest], Acc) ->
    calculate_total_area(Rest, Acc + L * L).

%% 辅助函数：将正方形列表转化为事件列表
%% 格式为 {Y, DeltaWidth}
generate_events(Squares) ->
    lists:flatmap(fun([_, Y, L]) -> 
        [{Y, L}, {Y + L, -L}] 
    end, Squares).

%% 扫描主逻辑
%% Events: 剩余事件列表
%% PrevY: 上一次处理的Y坐标
%% CurrWidth: 当前扫描线覆盖的总宽度
%% AccArea: 当前累积的面积
%% Target: 目标面积
scan([], PrevY, _, _, _) -> 
    float(PrevY); % 理论上不应到达这里，除非Target为0或计算误差
scan([{Y, Delta} | Rest], PrevY, CurrWidth, AccArea, Target) ->
    if
        Y > PrevY ->
            % 计算当前高度区间 [PrevY, Y] 内增加的面积
            Height = Y - PrevY,
            AddedArea = Height * CurrWidth,
            NewAccArea = AccArea + AddedArea,
            
            if
                NewAccArea >= Target ->
                    % 目标面积在当前区间内达到
                    % 公式: Target = AccArea + (Res - PrevY) * CurrWidth
                    % => Res = PrevY + (Target - AccArea) / CurrWidth
                    Need = Target - AccArea,
                    PrevY + Need / CurrWidth;
                true ->
                    % 目标尚未达到，更新状态继续
                    % 注意：这里只更新面积，宽度的更新要累加当前Y点的所有事件
                    scan(Rest, Y, CurrWidth + Delta, NewAccArea, Target)
            end;
        true ->
            % Y == PrevY (处理同一高度的多个事件)
            % 此时高度差为0，面积不增加，仅更新宽度
            scan(Rest, Y, CurrWidth + Delta, AccArea, Target)
    end.