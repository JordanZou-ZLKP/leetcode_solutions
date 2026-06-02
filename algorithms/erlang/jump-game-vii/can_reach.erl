-spec can_reach(S :: unicode:unicode_binary(), MinJump :: integer(), MaxJump :: integer()) -> boolean().
can_reach(S, MinJump, MaxJump) ->
    Len = byte_size(S),
    case binary:at(S, Len - 1) of
        $0 -> bfs(queue:in(0, queue:new()), S, Len, MinJump, MaxJump, 0);
        _ -> false
    end.

bfs(Q, S, Len, MinJump, MaxJump, MaxReached) ->
    case queue:out(Q) of
        {empty, _} -> 
            false;
        {{value, Idx}, Q1} ->
            Start = max(Idx + MinJump, MaxReached + 1),
            End = min(Idx + MaxJump, Len - 1),
            if
                Start =< End ->
                    case check_and_add(Start, End, S, Q1, Len - 1) of
                        true -> true;
                        Q2 -> bfs(Q2, S, Len, MinJump, MaxJump, max(MaxReached, End))
                    end;
                true ->
                    bfs(Q1, S, Len, MinJump, MaxJump, MaxReached)
            end
    end.

check_and_add(J, End, _, Q, _) when J > End -> 
    Q;
check_and_add(J, End, S, Q, Target) ->
    case binary:at(S, J) of
        $0 when J == Target -> 
            true;
        $0 -> 
            check_and_add(J + 1, End, S, queue:in(J, Q), Target);
        _ -> 
            check_and_add(J + 1, End, S, Q, Target)
    end.