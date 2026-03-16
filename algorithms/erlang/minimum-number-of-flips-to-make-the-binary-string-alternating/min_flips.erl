-spec min_flips(S :: unicode:unicode_binary()) -> integer().
min_flips(S) ->
    N = byte_size(S),
    S2 = <<S/binary, S/binary>>,
    {Diff1, Diff2} = init_window(S2, 0, N, 0, 0),
    Ans = min(Diff1, Diff2),
    slide(S2, N, N * 2, N, Diff1, Diff2, Ans).

init_window(_S2, N, N, D1, D2) ->
    {D1, D2};
init_window(S2, I, N, D1, D2) ->
    C = binary:at(S2, I),
    {E1, E2} = expected(I),
    ND1 = if C =/= E1 -> D1 + 1; true -> D1 end,
    ND2 = if C =/= E2 -> D2 + 1; true -> D2 end,
    init_window(S2, I + 1, N, ND1, ND2).

slide(_S2, Limit, Limit, _N, _D1, _D2, Min) ->
    Min;
slide(S2, I, Limit, N, D1, D2, Min) ->
    C_out = binary:at(S2, I - N),
    {E1_out, E2_out} = expected(I - N),
    ND1_out = if C_out =/= E1_out -> D1 - 1; true -> D1 end,
    ND2_out = if C_out =/= E2_out -> D2 - 1; true -> D2 end,

    C_in = binary:at(S2, I),
    {E1_in, E2_in} = expected(I),
    ND1_in = if C_in =/= E1_in -> ND1_out + 1; true -> ND1_out end,
    ND2_in = if C_in =/= E2_in -> ND2_out + 1; true -> ND2_out end,

    NMin = min(Min, min(ND1_in, ND2_in)),
    slide(S2, I + 1, Limit, N, ND1_in, ND2_in, NMin).

expected(I) when I rem 2 =:= 0 -> {$1, $0};
expected(_) -> {$0, $1}.