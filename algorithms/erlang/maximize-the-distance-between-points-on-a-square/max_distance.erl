-spec max_distance(Side :: integer(), Points :: [[integer()]], K :: integer()) -> integer().
max_distance(Side, Points, K) ->
    L1 = lists:sort([map_point(Pt, Side) || Pt <- Points]),
    L2 = [X + 4 * Side || X <- L1],
    Arr = list_to_tuple(L1 ++ L2),
    N = length(L1),
    Limit = tuple_size(Arr),
    bs(0, Side, Arr, N, K, Side, 0, Limit).

map_point([X, Y], Side) ->
    if
        Y == 0 -> X;
        X == Side -> Side + Y;
        Y == Side -> 3 * Side - X;
        X == 0 -> 4 * Side - Y
    end.

bs(Low, High, Arr, N, K, Side, Ans, Limit) ->
    if
        Low > High -> Ans;
        true ->
            Mid = Low + (High - Low) div 2,
            NextList = build_next_list(1, 1, Arr, Limit, Mid, []),
            NextTuple = list_to_tuple(NextList),
            case check_loop(1, Mid, Arr, NextTuple, N, K, Limit, Side) of
                true -> bs(Mid + 1, High, Arr, N, K, Side, Mid, Limit);
                false -> bs(Low, Mid - 1, Arr, N, K, Side, Ans, Limit)
            end
    end.

build_next_list(I, _J, _Arr, Limit, _D, Acc) when I > Limit ->
    lists:reverse(Acc);
build_next_list(I, J, Arr, Limit, D, Acc) ->
    StartJ = if J > I -> J; true -> I + 1 end,
    NewJ = advance_j(I, StartJ, Arr, Limit, D),
    build_next_list(I + 1, NewJ, Arr, Limit, D, [NewJ | Acc]).

advance_j(I, J, Arr, Limit, D) ->
    if
        J > Limit -> Limit + 1;
        true ->
            case element(J, Arr) - element(I, Arr) >= D of
                true -> J;
                false -> advance_j(I, J + 1, Arr, Limit, D)
            end
    end.

check_loop(I, D, Arr, NextTuple, N, K, Limit, Side) when I =< N ->
    P_max = element(I, Arr) + 4 * Side - D,
    case can_place(I, Arr, NextTuple, K, P_max, 1, Limit) of
        true -> true;
        false -> check_loop(I + 1, D, Arr, NextTuple, N, K, Limit, Side)
    end;
check_loop(_, _, _, _, _, _, _, _) -> false.

can_place(Idx, Arr, NextTuple, K, P_max, Count, Limit) ->
    Val = element(Idx, Arr),
    if
        Val > P_max -> false;
        Count == K -> true;
        true ->
            NextIdx = element(Idx, NextTuple),
            if
                NextIdx > Limit -> false;
                true -> can_place(NextIdx, Arr, NextTuple, K, P_max, Count + 1, Limit)
            end
    end.