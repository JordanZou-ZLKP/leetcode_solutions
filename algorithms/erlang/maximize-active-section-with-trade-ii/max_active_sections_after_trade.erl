-spec max_active_sections_after_trade(S :: unicode:unicode_binary(), Queries :: [[integer()]]) -> [integer()].
max_active_sections_after_trade(S, Queries) ->
    {BlocksList, Total1s} = parse_string(S, 0, undefined, [], 0),
    M = length(BlocksList),
    if
        M == 0 ->
            [Total1s || _ <- Queries];
        true ->
            Z_blocks = list_to_tuple(BlocksList),
            SZ_list = [R - L + 1 || {L, R} <- BlocksList],
            SZ = list_to_tuple(SZ_list),
            X_list = [begin {_, R1} = element(I, Z_blocks), {L2, _} = element(I+1, Z_blocks), L2 - R1 - 1 end || I <- lists:seq(1, M-1)],
            X = list_to_tuple(X_list),
            Sum2_list = [element(I, SZ) + element(I+1, SZ) || I <- lists:seq(1, M-1)],
            Sum2 = list_to_tuple(Sum2_list),
            Tree = build_tree(M, SZ, Sum2, X),
            lists:map(fun([L_q, R_q]) ->
                A = bs_first(Z_blocks, M, L_q),
                B = bs_last(Z_blocks, M, R_q),
                if
                    A > M orelse B < 1 orelse A > B -> Total1s;
                    A == B -> Total1s;
                    true ->
                        {L_A, R_A} = element(A, Z_blocks),
                        {L_B, R_B} = element(B, Z_blocks),
                        Z1 = min(R_A, R_q) - max(L_A, L_q) + 1,
                        Zk = min(R_B, R_q) - max(L_B, L_q) + 1,
                        if
                            A + 1 == B ->
                                MaxAdj = Z1 + Zk,
                                Zmax = max(Z1, Zk),
                                Xmin = element(A, X),
                                Total1s + max(MaxAdj, Zmax - Xmin);
                            true ->
                                MaxAdjMiddle = if A + 1 =< B - 2 -> query_sum2(1, 1, M, A + 1, B - 2, Tree); true -> 0 end,
                                MaxAdj = lists:max([Z1 + element(A+1, SZ), element(B-1, SZ) + Zk, MaxAdjMiddle]),
                                ZmaxMiddle = query_sz(1, 1, M, A + 1, B - 1, Tree),
                                Zmax = lists:max([Z1, Zk, ZmaxMiddle]),
                                Xmin = query_x(1, 1, M, A, B - 1, Tree),
                                Total1s + max(MaxAdj, Zmax - Xmin)
                        end
                end
            end, Queries)
    end.

parse_string(<<>>, _Idx, CurrentStart, Blocks, Total1s) ->
    NewBlocks = if CurrentStart =/= undefined -> [{CurrentStart, _Idx - 1} | Blocks]; true -> Blocks end,
    {lists:reverse(NewBlocks), Total1s};
parse_string(<<$0, Rest/binary>>, Idx, undefined, Blocks, Total1s) ->
    parse_string(Rest, Idx + 1, Idx, Blocks, Total1s);
parse_string(<<$0, Rest/binary>>, Idx, CurrentStart, Blocks, Total1s) ->
    parse_string(Rest, Idx + 1, CurrentStart, Blocks, Total1s);
parse_string(<<$1, Rest/binary>>, Idx, undefined, Blocks, Total1s) ->
    parse_string(Rest, Idx + 1, undefined, Blocks, Total1s + 1);
parse_string(<<$1, Rest/binary>>, Idx, CurrentStart, Blocks, Total1s) ->
    parse_string(Rest, Idx + 1, undefined, [{CurrentStart, Idx - 1} | Blocks], Total1s + 1).

build_tree(M, SZ, Sum2, X) ->
    Tree = erlang:make_tuple(4 * M, {0, 0, 999999999}),
    build_node(1, 1, M, Tree, SZ, Sum2, X, M).

build_node(Node, L, R, Tree, SZ, Sum2, X, M) when L == R ->
    Val = {
        element(L, SZ),
        if L < M -> element(L, Sum2); true -> 0 end,
        if L < M -> element(L, X); true -> 999999999 end
    },
    setelement(Node, Tree, Val);
build_node(Node, L, R, Tree, SZ, Sum2, X, M) ->
    Mid = (L + R) div 2,
    Tree1 = build_node(Node * 2, L, Mid, Tree, SZ, Sum2, X, M),
    Tree2 = build_node(Node * 2 + 1, Mid + 1, R, Tree1, SZ, Sum2, X, M),
    {MaxSZ1, MaxSum2_1, MinX1} = element(Node * 2, Tree2),
    {MaxSZ2, MaxSum2_2, MinX2} = element(Node * 2 + 1, Tree2),
    Val = {
        max(MaxSZ1, MaxSZ2),
        max(MaxSum2_1, MaxSum2_2),
        min(MinX1, MinX2)
    },
    setelement(Node, Tree2, Val).

query_sz(Node, L, R, QL, QR, Tree) ->
    if
        QL > R orelse QR < L -> 0;
        QL =< L andalso R =< QR ->
            {MaxSZ, _, _} = element(Node, Tree),
            MaxSZ;
        true ->
            Mid = (L + R) div 2,
            max(query_sz(Node * 2, L, Mid, QL, QR, Tree),
                query_sz(Node * 2 + 1, Mid + 1, R, QL, QR, Tree))
    end.

query_sum2(Node, L, R, QL, QR, Tree) ->
    if
        QL > R orelse QR < L -> 0;
        QL =< L andalso R =< QR ->
            {_, MaxSum2, _} = element(Node, Tree),
            MaxSum2;
        true ->
            Mid = (L + R) div 2,
            max(query_sum2(Node * 2, L, Mid, QL, QR, Tree),
                query_sum2(Node * 2 + 1, Mid + 1, R, QL, QR, Tree))
    end.

query_x(Node, L, R, QL, QR, Tree) ->
    if
        QL > R orelse QR < L -> 999999999;
        QL =< L andalso R =< QR ->
            {_, _, MinX} = element(Node, Tree),
            MinX;
        true ->
            Mid = (L + R) div 2,
            min(query_x(Node * 2, L, Mid, QL, QR, Tree),
                query_x(Node * 2 + 1, Mid + 1, R, QL, QR, Tree))
    end.

bs_first(Z_blocks, M, Val) -> bs_first(Z_blocks, 1, M, Val, M + 1).
bs_first(_Z_blocks, Low, High, _Val, Ans) when Low > High -> Ans;
bs_first(Z_blocks, Low, High, Val, Ans) ->
    Mid = (Low + High) div 2,
    {_L, R} = element(Mid, Z_blocks),
    if
        R >= Val -> bs_first(Z_blocks, Low, Mid - 1, Val, Mid);
        true -> bs_first(Z_blocks, Mid + 1, High, Val, Ans)
    end.

bs_last(Z_blocks, M, Val) -> bs_last(Z_blocks, 1, M, Val, 0).
bs_last(_Z_blocks, Low, High, _Val, Ans) when Low > High -> Ans;
bs_last(Z_blocks, Low, High, Val, Ans) ->
    Mid = (Low + High) div 2,
    {L, _R} = element(Mid, Z_blocks),
    if
        L =< Val -> bs_last(Z_blocks, Mid + 1, High, Val, Mid);
        true -> bs_last(Z_blocks, Low, Mid - 1, Val, Ans)
    end.