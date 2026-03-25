-spec can_partition_grid(Grid :: [[integer()]]) -> boolean().
can_partition_grid(Grid) ->
    RowSums = [lists:sum(Row) || Row <- Grid],
    Total = lists:sum(RowSums),
    case Total rem 2 of
        1 -> false;
        0 ->
            Target = Total div 2,
            case check_prefix(RowSums, 0, Target) of
                true -> true;
                false ->
                    [FirstRow | _] = Grid,
                    InitAcc = [0 || _ <- FirstRow],
                    ColSums = lists:foldl(
                        fun(Row, Acc) -> lists:zipwith(fun erlang:'+'/2, Row, Acc) end,
                        InitAcc,
                        Grid
                    ),
                    check_prefix(ColSums, 0, Target)
            end
    end.

check_prefix([_], _, _) -> 
    false;
check_prefix([X | Rest], Acc, Target) ->
    Sum = Acc + X,
    case Sum =:= Target of
        true -> true;
        false -> check_prefix(Rest, Sum, Target)
    end;
check_prefix([], _, _) -> 
    false.