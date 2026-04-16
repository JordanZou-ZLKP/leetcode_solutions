-spec minimum_distance(Word :: unicode:unicode_binary()) -> integer().
minimum_distance(<<First, Rest/binary>>) ->
    P = First - $A,
    DP = #{none => 0},
    {_, FinalDP} = lists:foldl(
        fun(Char, {Prev, AccDP}) ->
            C = Char - $A,
            NewDP = maps:fold(
                fun(Other, Cost, MapAcc) ->
                    Cost1 = Cost + dist(Prev, C),
                    MapAcc1 = update_min(Other, Cost1, MapAcc),
                    Cost2 = Cost + dist(Other, C),
                    update_min(Prev, Cost2, MapAcc1)
                end,
                #{},
                AccDP
            ),
            {C, NewDP}
        end,
        {P, DP},
        binary_to_list(Rest)
    ),
    lists:min(maps:values(FinalDP)).

dist(none, _) -> 
    0;
dist(A, B) ->
    abs(A div 6 - B div 6) + abs(A rem 6 - B rem 6).

update_min(Key, Value, Map) ->
    case maps:get(Key, Map, infinity) of
        Existing when Existing =< Value -> Map;
        _ -> Map#{Key => Value}
    end.