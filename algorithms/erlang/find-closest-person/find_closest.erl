-spec find_closest(X :: integer(), Y :: integer(), Z :: integer()) -> integer().
find_closest(X, Y, Z) ->
    Dist1 = abs(X - Z), % 计算 Person 1 到 Z 的距离
    Dist2 = abs(Y - Z), % 计算 Person 2 到 Z 的距离
    
    if
        Dist1 < Dist2 -> 1; % Person 1 距离更近
        Dist2 < Dist1 -> 2; % Person 2 距离更近
        true          -> 0  % 距离相等
    end.