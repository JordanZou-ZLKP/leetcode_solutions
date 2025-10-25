-spec convert(S :: unicode:unicode_binary(), NumRows :: integer()) -> unicode:unicode_binary().
convert(S, 1) ->
    S;
convert(OneS, NumRows) ->
    S = binary_to_list(OneS),
    Rows = lists:duplicate(NumRows, []),
    {FinalRows, _, _} = lists:foldl(
        fun(Char, {AccRows, RowIdx, Dir}) ->
            NewRows = setelement(RowIdx + 1, AccRows, [Char | element(RowIdx + 1, AccRows)]),
            case RowIdx of
                0 -> {NewRows, RowIdx + 1, 1};
                N when N == NumRows - 1 -> {NewRows, RowIdx - 1, -1};
                _ when Dir == 1 -> {NewRows, RowIdx + 1, 1};
                _ -> {NewRows, RowIdx - 1, -1}
            end
        end,
        {list_to_tuple(Rows), 0, 1},
        S
    ),
    ReversedRows = [lists:reverse(element(I, FinalRows)) || I <- lists:seq(1, NumRows)],
    Rone = lists:flatten(ReversedRows),
    R = list_to_binary(Rone).