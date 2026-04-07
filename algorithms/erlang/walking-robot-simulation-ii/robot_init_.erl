-spec robot_init_(Width :: integer(), Height :: integer()) -> any().
robot_init_(Width, Height) ->
    put(robot_w, Width - 1),
    put(robot_h, Height - 1),
    put(robot_steps, 0).

-spec robot_step(Num :: integer()) -> any().
robot_step(Num) ->
    put(robot_steps, get(robot_steps) + Num).

-spec robot_get_pos() -> [integer()].
robot_get_pos() ->
    W = get(robot_w),
    H = get(robot_h),
    S0 = get(robot_steps),
    P = 2 * (W + H),
    S = S0 rem P,
    if
        S0 =:= 0 -> [0, 0];
        S =< W -> [S, 0];
        S =< W + H -> [W, S - W];
        S =< 2 * W + H -> [W - (S - W - H), H];
        true -> [0, H - (S - 2 * W - H)]
    end.

-spec robot_get_dir() -> unicode:unicode_binary().
robot_get_dir() ->
    W = get(robot_w),
    H = get(robot_h),
    S0 = get(robot_steps),
    P = 2 * (W + H),
    S = S0 rem P,
    if
        S0 =:= 0 -> <<"East">>;
        S =:= 0 -> <<"South">>;
        S =< W -> <<"East">>;
        S =< W + H -> <<"North">>;
        S =< 2 * W + H -> <<"West">>;
        true -> <<"South">>
    end.


%% Your functions will be called as such:
%% robot_init_(Width, Height),
%% robot_step(Num),
%% Param_2 = robot_get_pos(),
%% Param_3 = robot_get_dir(),

%% robot_init_ will be called before every test case, in which you can do some necessary initializations.