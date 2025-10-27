-spec number_of_beams(Bank :: [unicode:unicode_binary()]) -> integer().
number_of_beams(BankOne) ->
    Bank = unbinarize(BankOne),
    DeviceCounts = [count_devices(Row) || Row <- Bank],
    NonEmptyRows = [Count || Count <- DeviceCounts, Count > 0],
    beams_from_rows(NonEmptyRows, 0).

unbinarize(Bank) -> lists:map(fun(X) -> binary_to_list(X) end, Bank).

-spec count_devices(string()) -> non_neg_integer().
count_devices(Row) ->
    lists:sum([if C == $1 -> 1; true -> 0 end || C <- Row]).

-spec beams_from_rows([non_neg_integer()], integer()) -> integer().
beams_from_rows([], Acc) ->
    Acc;
beams_from_rows([_], Acc) ->
    Acc;
beams_from_rows([A, B | Rest], Acc) ->
    beams_from_rows([B | Rest], Acc + A * B).