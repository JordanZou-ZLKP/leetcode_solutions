-spec max_sum(Nums :: [integer()], K :: integer()) -> integer().
max_sum(Nums, K) ->
    Counts = [{B, count_bits(Nums, B, 0)} || B <- lists:seq(0, 30)],
    sum_of_squares(K, 1, Counts, 0).

count_bits([], _B, Acc) -> 
    Acc;
count_bits([H | T], B, Acc) ->
    count_bits(T, B, Acc + ((H bsr B) band 1)).

sum_of_squares(K, I, _Counts, Acc) when I > K ->
    Acc;
sum_of_squares(K, I, Counts, Acc) ->
    Val = build_val(Counts, I, 0),
    sum_of_squares(K, I + 1, Counts, (Acc + Val * Val) rem 1000000007).

build_val([], _I, Val) -> 
    Val;
build_val([{B, C} | T], I, Val) when C >= I ->
    build_val(T, I, Val + (1 bsl B));
build_val([_ | T], I, Val) ->
    build_val(T, I, Val).

