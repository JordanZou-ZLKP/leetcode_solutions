-spec maximum_total_damage(Power :: [integer()]) -> integer().
maximum_total_damage(Power) ->
    % Step 1: Sort the power list
    SortedPower = lists:sort(Power),
    
    % Step 2: Aggregate identical spell values into {Value, TotalDamage}
    % Example: [1,1,3,4] -> [{1, 2}, {3, 3}, {4, 4}]
    Aggregated = aggregate(SortedPower),
    
    % Step 3: Run Dynamic Programming
    solve_dp(Aggregated).

%% Helper to aggregate sorted integers
aggregate([]) -> [];
aggregate([H | T]) -> aggregate(T, H, H).

aggregate([], CurrentVal, CurrentSum) ->
    [{CurrentVal, CurrentSum}];
aggregate([H | T], CurrentVal, CurrentSum) when H =:= CurrentVal ->
    % Same value, accumulate damage
    aggregate(T, CurrentVal, CurrentSum + H);
aggregate([H | T], CurrentVal, CurrentSum) ->
    % New value found, store previous and start new
    [{CurrentVal, CurrentSum} | aggregate(T, H, H)].

%% Helper to solve the DP problem
solve_dp(Items) ->
    % Queue stores recent history that might still conflict with future items.
    % Format: {Value, MaxScoreAtThisValue}
    Queue = queue:new(),
    % SafeMax tracks the max score of items that are "far enough" in the past (dist > 2)
    SafeMax = 0,
    % LastMax tracks the absolute max score found so far (skip or take)
    LastMax = 0,
    solve_dp(Items, Queue, SafeMax, LastMax).

solve_dp([], _Queue, _SafeMax, LastMax) ->
    LastMax;
solve_dp([{Val, Dmg} | Rest], Queue, SafeMax, LastMax) ->
    % 1. Update SafeMax: move items from Queue to SafeMax if they are compatible.
    % Condition for compatibility: ItemKey < Val - 2
    {NewSafeMax, NewQueue} = drain_compatible(Queue, Val, SafeMax),
    
    % 2. Calculate options
    % Option A: Take current. We can add Dmg to any score that is "Safe"
    TakeScore = Dmg + NewSafeMax,
    
    % Option B: Skip current. The score is simply what we achieved up to the previous step
    SkipScore = LastMax,
    
    % 3. Determine the max score at this specific step
    CurrentMax = max(TakeScore, SkipScore),
    
    % 4. Add current result to Queue (it might conflict with the immediate next items)
    NextQueue = queue:in({Val, CurrentMax}, NewQueue),
    
    solve_dp(Rest, NextQueue, NewSafeMax, CurrentMax).

%% Drains items from the queue that are no longer in conflict range of CurrentVal
%% Conflict range: [Val - 2, Val + 2].
%% Since we look backwards, we are compatible if OldVal < Val - 2.
drain_compatible(Queue, CurrentVal, CurrentSafeMax) ->
    case queue:peek(Queue) of
        {value, {OldVal, OldScore}} when OldVal < CurrentVal - 2 ->
            % This item is now safe to combine with CurrentVal (and all future Vals)
            NewSafeMax = max(CurrentSafeMax, OldScore),
            {_, PoppedQueue} = queue:out(Queue),
            drain_compatible(PoppedQueue, CurrentVal, NewSafeMax);
        _ ->
            % Queue is empty OR the head is still too close (OldVal >= CurrentVal - 2)
            {CurrentSafeMax, Queue}
    end.