-spec smallest_subsequence(S :: unicode:unicode_binary()) -> unicode:unicode_binary().
smallest_subsequence(S) ->
    Str = binary_to_list(S),
    Counts = lists:foldl(fun(C, Acc) ->
        maps:update_with(C, fun(V) -> V + 1 end, 1, Acc)
    end, #{}, Str),
    Stack = solve(Str, Counts, #{}, []),
    list_to_binary(lists:reverse(Stack)).

solve([], _Counts, _Visited, Stack) ->
    Stack;
solve([C | Rest], Counts, Visited, Stack) ->
    Counts1 = maps:update_with(C, fun(V) -> V - 1 end, Counts),
    case maps:is_key(C, Visited) of
        true ->
            solve(Rest, Counts1, Visited, Stack);
        false ->
            {NewStack, NewVisited} = pop_greater(C, Stack, Counts1, Visited),
            solve(Rest, Counts1, NewVisited#{C => true}, [C | NewStack])
    end.

pop_greater(_C, [], _Counts, Visited) ->
    {[], Visited};
pop_greater(C, [Top | Rest] = Stack, Counts, Visited) ->
    if
        Top > C ->
            case maps:get(Top, Counts) of
                Count when Count > 0 ->
                    pop_greater(C, Rest, Counts, maps:remove(Top, Visited));
                _ ->
                    {Stack, Visited}
            end;
        true ->
            {Stack, Visited}
    end.