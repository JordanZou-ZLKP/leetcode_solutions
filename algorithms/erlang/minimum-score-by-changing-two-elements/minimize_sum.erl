-spec minimize_sum(Nums :: [integer()]) -> integer().
minimize_sum([A, B, C | Rest]) ->
    [S1, S2, S3] = lists:sort([A, B, C]),
    scan(Rest, S1, S2, S3, S3, S2, S1).

scan([], S1, S2, S3, L1, L2, L3) ->
    min(L1 - S3, min(L2 - S2, L3 - S1));
scan([X | Rest], S1, S2, S3, L1, L2, L3) ->
    {NS1, NS2, NS3} = update_min(X, S1, S2, S3),
    {NL1, NL2, NL3} = update_max(X, L1, L2, L3),
    scan(Rest, NS1, NS2, NS3, NL1, NL2, NL3).

update_min(X, S1, S2, _S3) when X =< S1 ->
    {X, S1, S2};
update_min(X, S1, S2, _S3) when X =< S2 ->
    {S1, X, S2};
update_min(X, S1, S2, S3) when X < S3 ->
    {S1, S2, X};
update_min(_X, S1, S2, S3) ->
    {S1, S2, S3}.

update_max(X, L1, L2, _L3) when X >= L1 ->
    {X, L1, L2};
update_max(X, L1, L2, _L3) when X >= L2 ->
    {L1, X, L2};
update_max(X, L1, L2, L3) when X > L3 ->
    {L1, L2, X};
update_max(_X, L1, L2, L3) ->
    {L1, L2, L3}.

