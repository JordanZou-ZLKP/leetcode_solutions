-spec k_length_apart(Nums :: [integer()], K :: integer()) -> boolean().
k_length_apart(Nums, K) ->
    wait_for_first_one(Nums, K).

%% Phase 1: Skip leading zeros.
%% We don't need to check distance until we have seen at least one '1'.
wait_for_first_one([], _K) ->
    true; %% No 1s found in the whole list, valid.
wait_for_first_one([0 | Rest], K) ->
    wait_for_first_one(Rest, K);
wait_for_first_one([1 | Rest], K) ->
    %% Found the first 1, switch to counting mode with count 0.
    check_distance(Rest, K, 0).

%% Phase 2: Count zeros and validate distance between 1s.
%% Distance: The number of zeros (places) accumulated since the last '1'.
check_distance([], _K, _Distance) ->
    true; %% Reached end of list successfully.
check_distance([0 | Rest], K, Distance) ->
    %% Found a 0, increment distance and continue.
    check_distance(Rest, K, Distance + 1);
check_distance([1 | Rest], K, Distance) ->
    %% Found a 1, check if the distance from the previous 1 is sufficient.
    if
        Distance >= K ->
            %% Valid gap, reset distance to 0 and continue looking for the next 1.
            check_distance(Rest, K, 0);
        true ->
            %% Invalid gap, fail immediately.
            false
    end.