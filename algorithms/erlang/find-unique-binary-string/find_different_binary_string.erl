-spec find_different_binary_string(Nums :: [unicode:unicode_binary()]) -> unicode:unicode_binary().
find_different_binary_string(Nums) ->
    build_string(Nums, 0, <<>>).

build_string([], _Index, Acc) ->
    Acc;
build_string([Bin | Rest], Index, Acc) ->
    Flipped = case binary:at(Bin, Index) of
        $0 -> <<$1>>;
        $1 -> <<$0>>
    end,
    build_string(Rest, Index + 1, <<Acc/binary, Flipped/binary>>).