-spec minimum_cost(Cost1 :: integer(), Cost2 :: integer(), CostBoth :: integer(), Need1 :: integer(), Need2 :: integer()) -> integer().
minimum_cost(Cost1, Cost2, CostBoth, Need1, Need2) ->
    MinN = min(Need1, Need2),
    MaxN = max(Need1, Need2),
    V1 = Need1 * Cost1 + Need2 * Cost2,
    V2 = MinN * CostBoth + (Need1 - MinN) * Cost1 + (Need2 - MinN) * Cost2,
    V3 = MaxN * CostBoth,
    min(V1, min(V2, V3)).

