-spec xor_after_queries(Nums :: [integer()], Queries :: [[integer()]]) -> integer().
xor_after_queries(Nums, Queries) ->
    process_nums(Nums, Queries, 0, 0).

process_nums([], _, _, Acc) -> 
    Acc;
process_nums([Num | Rest], Queries, Idx, Acc) ->
    Mult = get_multiplier(Queries, Idx, 1),
    NewNum = (Num * Mult) rem 1000000007,
    process_nums(Rest, Queries, Idx + 1, Acc bxor NewNum).

get_multiplier([], _, Mult) -> 
    Mult;
get_multiplier([[L, R, K, V] | Rest], Idx, Mult) ->
    case Idx >= L andalso Idx =< R andalso (Idx - L) rem K =:= 0 of
        true -> 
            NextMult = (Mult * V) rem 1000000007,
            get_multiplier(Rest, Idx, NextMult);
        false -> 
            get_multiplier(Rest, Idx, Mult)
    end.