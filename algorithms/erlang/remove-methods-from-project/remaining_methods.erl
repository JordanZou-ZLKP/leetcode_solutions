-spec remaining_methods(N :: integer(), K :: integer(), Invocations :: [[integer()]]) -> [integer()].
remaining_methods(N, K, Invocations) ->
    Graph = lists:foldl(
        fun([U, V], Acc) ->
            case maps:find(U, Acc) of
                {ok, L} -> Acc#{U => [V | L]};
                error -> Acc#{U => [V]}
            end
        end,
        #{}, Invocations),
    Suspicious = get_suspicious([K], Graph, #{}),
    CanRemove = check_invocations(Invocations, Suspicious),
    if
        CanRemove ->
            lists:filter(fun(I) -> not maps:is_key(I, Suspicious) end, lists:seq(0, N - 1));
        true ->
            lists:seq(0, N - 1)
    end.

get_suspicious([], _Graph, Suspicious) -> 
    Suspicious;
get_suspicious([Node | Rest], Graph, Suspicious) ->
    case maps:is_key(Node, Suspicious) of
        true -> 
            get_suspicious(Rest, Graph, Suspicious);
        false ->
            Suspicious1 = Suspicious#{Node => true},
            Neighbors = case maps:find(Node, Graph) of
                {ok, L} -> L;
                error -> []
            end,
            get_suspicious(Neighbors ++ Rest, Graph, Suspicious1)
    end.

check_invocations([], _Suspicious) -> 
    true;
check_invocations([[U, V] | Rest], Suspicious) ->
    case {maps:is_key(U, Suspicious), maps:is_key(V, Suspicious)} of
        {false, true} -> false;
        _ -> check_invocations(Rest, Suspicious)
    end.