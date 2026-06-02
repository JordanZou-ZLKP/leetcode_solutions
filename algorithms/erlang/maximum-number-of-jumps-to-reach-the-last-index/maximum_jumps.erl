-spec maximum_jumps(Nums :: [integer()], Target :: integer()) -> integer().

maximum_jumps([H | T], Target) ->
    maximum_jumps(T, Target, [{H, 0}]).

maximum_jumps([], _, [{_, Ans} | _]) ->
    Ans;
maximum_jumps([Num | Rest], Target, Prev) ->
    maximum_jumps(Rest, Target, [{Num, find_max(Prev, Num, Target, -1)} | Prev]).

find_max([{NumI, DpI} | Rest], NumJ, Target, Acc) when DpI =/= -1, abs(NumJ - NumI) =< Target, DpI + 1 > Acc ->
    find_max(Rest, NumJ, Target, DpI + 1);
find_max([_ | Rest], NumJ, Target, Acc) ->
    find_max(Rest, NumJ, Target, Acc);
find_max([], _, _, Acc) ->
    Acc.