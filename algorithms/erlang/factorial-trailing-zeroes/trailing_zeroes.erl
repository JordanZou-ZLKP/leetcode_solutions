-spec trailing_zeroes(N :: integer()) -> integer().
trailing_zeroes(N) ->
    count_zeroes(N, 0).

count_zeroes(0, Acc) ->
    Acc;
count_zeroes(N, Acc) ->
    Next = N div 5,
    count_zeroes(Next, Acc + Next).