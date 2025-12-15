-spec number_of_ways(Corridor :: unicode:unicode_binary()) -> integer().
-define(MOD, 1000000007).

number_of_ways(One) ->
    Corridor = binary_to_list(One),
    {Count, _LastSeat, Prod} = traverse(Corridor, 0, 0, -1, 1, ?MOD),
    case Count of
        0 -> 0;
        _ when Count rem 2 =/= 0 -> 0;
        _ -> Prod
    end.

traverse([], _Index, Count, _LastSeat, Prod, _MOD) ->
    {Count, 0, Prod}; % LastSeat unused in final check

traverse([Char | Rest], Index, Count, LastSeat, Prod, MOD) ->
    case Char of
        $S ->
            NewCount = Count + 1,
            if
                NewCount =:= 1 ->
                    % First seat: record its position
                    traverse(Rest, Index + 1, NewCount, Index, Prod, MOD);
                NewCount rem 2 =:= 0 ->
                    % Even count (2nd, 4th, etc. seat): update last seat position
                    traverse(Rest, Index + 1, NewCount, Index, Prod, MOD);
                true ->
                    % Odd count >=3 (3rd, 5th, etc. seat): calculate gap and update product
                    Gap = Index - LastSeat,
                    NewProd = (Prod * Gap) rem MOD,
                    traverse(Rest, Index + 1, NewCount, Index, NewProd, MOD)
            end;
        _ -> % 'P' or any non-'S' character
            traverse(Rest, Index + 1, Count, LastSeat, Prod, MOD)
    end.