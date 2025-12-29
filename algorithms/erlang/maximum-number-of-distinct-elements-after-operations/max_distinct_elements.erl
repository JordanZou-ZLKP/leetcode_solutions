-spec max_distinct_elements(Nums :: [integer()], K :: integer()) -> integer().
max_distinct_elements(Nums, K) ->
    % 1. Sort the input list (O(N log N))
    SortedNums = lists:sort(Nums),
    
    % Initial state for the fold: 
    % Count = 0 (number of distinct elements found)
    % LastUsed = A value smaller than any possible valid number. 
    % Since nums[i] >= 1 and k >= 0, the minimum possible value is 1 - 10^9.
    % We use a sufficiently small number (e.g., -2*10^9) to ensure the first element is always processed.
    InitialState = {0, -2000000000},
    
    % 2. Iterate through sorted list (O(N))
    {MaxDistinctCount, _} = lists:foldl(fun(X, {Count, LastUsed}) ->
        % The lowest value current X can become
        MinVal = X - K,
        % The highest value current X can become
        MaxVal = X + K,
        
        % Greedy choice: Try to pick the smallest valid value that is 
        % strictly greater than the LastUsed value.
        % This maximizes space for subsequent numbers.
        Candidate = max(MinVal, LastUsed + 1),
        
        % Check if the candidate is within the valid upper bound
        if 
            Candidate =< MaxVal ->
                % If valid, we count it and update LastUsed to this new candidate
                {Count + 1, Candidate};
            true ->
                % If Candidate > MaxVal, we cannot pick a distinct value for this X 
                % that is larger than LastUsed. We skip this X.
                {Count, LastUsed}
        end
    end, InitialState, SortedNums),
    
    MaxDistinctCount.