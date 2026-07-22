-spec max_active_sections_after_trade(S :: unicode:unicode_binary(), Queries :: [[integer()]]) -> [integer()].
max_active_sections_after_trade(S, Queries) ->
    {BlocksList, Total1s} = parse_string(S, 0, undefined, [], 0),
    M = length(BlocksList),
    if
        M =< 1 ->
            [Total1s || _ <- Queries];
        true ->
            Z_blocks = list_to_tuple(BlocksList),
            SZ_tuple = list_to_tuple([R - L + 1 || {L, R} <- BlocksList]),
            Sum2_tuple = list_to_tuple([element(I, SZ_tuple) + element(I+1, SZ_tuple) || I <- lists:seq(1, M-1)]),
            Tree = build_tree(1, M - 1, Sum2_tuple),
            lists:map(fun([L_q, R_q]) ->
                A = bs_first(Z_blocks, 1, M, L_q, M + 1),
                B = bs_last(Z_blocks, 1, M, R_q, 0),
                if
                    A >= B -> Total1s;
                    A + 1 == B ->
                        {L_A, R_A} = element(A, Z_blocks),
                        {L_B, R_B} = element(B, Z_blocks),
                        Z1 = min(R_A, R_q) - max(L_A, L_q) + 1,
                        Zk = min(R_B, R_q) - max(L_B, L_q) + 1,
                        Total1s + Z1 + Zk;
                    true ->
                        {L_A, R_A} = element(A, Z_blocks),
                        {L_B, R_B} = element(B, Z_blocks),
                        Z1 = min(R_A, R_q) - max(L_A, L_q) + 1,
                        Zk = min(R_B, R_q) - max(L_B, L_q) + 1,
                        MaxAdjMiddle = if
                            A + 1 =< B - 2 -> query_tree(Tree, 1, M - 1, A + 1, B - 2);
                            true -> 0
                        end,
                        MaxAdj = max(max(Z1 + element(A+1, SZ_tuple), element(B-1, SZ_tuple) + Zk), MaxAdjMiddle),
                        Total1s + MaxAdj
                end
            end, Queries)
    end.

parse_string(<<>>, _Idx, undefined, Blocks, Total1s) -> 
    {lists:reverse(Blocks), Total1s};
parse_string(<<>>, _Idx, CurrentStart, Blocks, Total1s) -> 
    {lists:reverse([{CurrentStart, _Idx - 1} | Blocks]), Total1s};
parse_string(<<$0, Rest/binary>>, Idx, undefined, Blocks, Total1s) -> 
    parse_string(Rest, Idx + 1, Idx, Blocks, Total1s);
parse_string(<<$0, Rest/binary>>, Idx, CurrentStart, Blocks, Total1s) -> 
    parse_string(Rest, Idx + 1, CurrentStart, Blocks, Total1s);
parse_string(<<$1, Rest/binary>>, Idx, undefined, Blocks, Total1s) -> 
    parse_string(Rest, Idx + 1, undefined, Blocks, Total1s + 1);
parse_string(<<$1, Rest/binary>>, Idx, CurrentStart, Blocks, Total1s) -> 
    parse_string(Rest, Idx + 1, undefined, [{CurrentStart, Idx - 1} | Blocks], Total1s + 1).

build_tree(L, R, Sum2) when L == R -> 
    element(L, Sum2);
build_tree(L, R, Sum2) ->
    Mid = (L + R) div 2,
    Left = build_tree(L, Mid, Sum2),
    Right = build_tree(Mid + 1, R, Sum2),
    VLeft = if is_integer(Left) -> Left; true -> element(1, Left) end,
    VRight = if is_integer(Right) -> Right; true -> element(1, Right) end,
    {max(VLeft, VRight), Left, Right}.

query_tree(_Tree, L, R, QL, QR) when QL > R orelse QR < L -> 
    0;
query_tree(Tree, L, R, QL, QR) when QL =< L, R =< QR ->
    if is_integer(Tree) -> Tree; true -> element(1, Tree) end;
query_tree(Tree, L, R, QL, QR) ->
    Mid = (L + R) div 2,
    max(query_tree(element(2, Tree), L, Mid, QL, QR),
        query_tree(element(3, Tree), Mid + 1, R, QL, QR)).

bs_first(_Z_blocks, Low, High, _Val, Ans) when Low > High -> 
    Ans;
bs_first(Z_blocks, Low, High, Val, Ans) ->
    Mid = (Low + High) div 2,
    {_L, R} = element(Mid, Z_blocks),
    if 
        R >= Val -> bs_first(Z_blocks, Low, Mid - 1, Val, Mid);
        true -> bs_first(Z_blocks, Mid + 1, High, Val, Ans)
    end.

bs_last(_Z_blocks, Low, High, _Val, Ans) when Low > High -> 
    Ans;
bs_last(Z_blocks, Low, High, Val, Ans) ->
    Mid = (Low + High) div 2,
    {L, _R} = element(Mid, Z_blocks),
    if 
        L =< Val -> bs_last(Z_blocks, Mid + 1, High, Val, Mid);
        true -> bs_last(Z_blocks, Low, Mid - 1, Val, Ans)
    end.