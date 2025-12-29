-spec maximum_energy(Energy :: [integer()], K :: integer()) -> integer().
maximum_energy(Energy, K) ->
    N = length(Energy),
    
    % Step 1: Initialize an accumulator array of size K with default value 0.
    % We use the 'array' module which is efficient for random access/updates.
    % Each index j in this array stores the running suffix sum for indices where index % K == j.
    AccArray = array:new([{size, K}, {default, 0}, {fixed, true}]),
    
    % Step 2: Reverse the list to process from the last element to the first.
    % Processing backwards allows us to compute the full path sum for any start point immediately.
    RevEnergy = lists:reverse(Energy),
    
    % Step 3: Iterate and solve.
    % We initialize CurrentMax with a very small number.
    % The constraints say values are >= -1000. Minimum possible sum could be roughly -10^8.
    % -1.0e15 is safe enough, or we can use the first calculated value as the seed.
    solve(RevEnergy, N - 1, K, AccArray, -1000000000000).

%% solve(List, CurrentIndex, K, AccumulatorArray, MaxFoundSoFar)
solve([], _Idx, _K, _AccArray, Max) ->
    Max;
solve([Val | Rest], Idx, K, AccArray, Max) ->
    % Calculate which "track" this index belongs to
    Mod = Idx rem K,
    
    % Get the sum of the path AFTER this index (which we computed in previous steps)
    PrevPathSum = array:get(Mod, AccArray),
    
    % The total energy starting from this index is current value + sum of the rest of the path
    CurrentPathSum = Val + PrevPathSum,
    
    % Update the accumulator for this specific modulo track
    NewAccArray = array:set(Mod, CurrentPathSum, AccArray),
    
    % Update the global maximum if this starting point yields more energy
    NewMax = erlang:max(Max, CurrentPathSum),
    
    % Recurse to the next element (which is the previous index in original array)
    solve(Rest, Idx - 1, K, NewAccArray, NewMax).