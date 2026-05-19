-spec can_reach(Arr :: [integer()], Start :: integer()) -> boolean().
can_reach(Arr, Start) ->
    TupleArr = list_to_tuple(Arr),
    Size = tuple_size(TupleArr),
    dfs([Start + 1], TupleArr, Size, #{}).

dfs([], _, _, _) ->
    false;
dfs([Idx | Rest], TupleArr, Size, Visited) ->
    case maps:is_key(Idx, Visited) of
        true ->
            dfs(Rest, TupleArr, Size, Visited);
        false ->
            Val = element(Idx, TupleArr),
            if
                Val =:= 0 ->
                    true;
                true ->
                    NewVisited = maps:put(Idx, true, Visited),
                    Next1 = Idx + Val,
                    Next2 = Idx - Val,
                    Q1 = if Next1 =< Size -> [Next1 | Rest]; true -> Rest end,
                    Q2 = if Next2 >= 1 -> [Next2 | Q1]; true -> Q1 end,
                    dfs(Q2, TupleArr, Size, NewVisited)
            end
    end.