-spec max_total_fruits(Fruits :: [[integer()]], StartPos :: integer(), K :: integer()) -> integer().
max_total_fruits(Fruits, StartPos, K) ->
    N = length(Fruits),
    
    % 1. Pre-process data: Split into Positions and Amounts
    {PosList, AmtList} = split_fruits(Fruits, [], []),
    
    % 2. Convert Positions to Tuple for O(1) access
    PosTuple = list_to_tuple(PosList),
    
    % 3. Build Prefix Sums for Amounts and convert to Tuple
    % PrefixTuple will have N+1 elements, starting with 0.
    % Sum(Left, Right) = element(Right + 1) - element(Left)
    PrefixList = build_prefix_sum(AmtList, 0, [0]),
    PrefixTuple = list_to_tuple(PrefixList),
    
    % 4. Sliding Window
    % Left and Right are 1-based indices into the PosTuple
    solve_sliding_window(1, 1, N, PosTuple, PrefixTuple, StartPos, K, 0).

%% ---------------------------------------------------------
%% Helper Functions
%% ---------------------------------------------------------

%% Splits the input list of lists into two separate lists for positions and amounts.
split_fruits([], PosAcc, AmtAcc) ->
    {lists:reverse(PosAcc), lists:reverse(AmtAcc)};
split_fruits([[P, A] | T], PosAcc, AmtAcc) ->
    split_fruits(T, [P | PosAcc], [A | AmtAcc]).

%% Builds a prefix sum list. 
%% Result includes an initial 0, so size is N+1.
build_prefix_sum([], _, Acc) ->
    lists:reverse(Acc);
build_prefix_sum([H | T], CurrentSum, Acc) ->
    NewSum = CurrentSum + H,
    build_prefix_sum(T, NewSum, [NewSum | Acc]).

%% Sliding Window Logic
%% Left, Right: Current window indices (1-based)
%% MaxFruits: The maximum fruits collected so far
solve_sliding_window(Left, Right, N, _Pos, _Prefix, _Start, _K, MaxFruits) when Right > N ->
    % Base case: Right pointer exceeded list length
    MaxFruits;
solve_sliding_window(Left, Right, N, PosTuple, PrefixTuple, StartPos, K, MaxFruits) ->
    % Get physical positions
    PosL = element(Left, PosTuple),
    PosR = element(Right, PosTuple),
    
    % Calculate cost to cover range [PosL, PosR] starting from StartPos
    Cost = calculate_cost(PosL, PosR, StartPos),
    
    if
        Cost > K ->
            % Cost too high, shrink window from Left.
            % But we must ensure Left never exceeds Right in the next step logic logically,
            % though strictly in this algorithm, if Left==Right and Cost > K, 
            % we increment Left making Left > Right. We handle that in next iteration.
            NewLeft = Left + 1,
            if 
                NewLeft > Right -> 
                    % If window becomes empty, reset Right to catch up
                    solve_sliding_window(NewLeft, NewLeft, N, PosTuple, PrefixTuple, StartPos, K, MaxFruits);
                true ->
                    solve_sliding_window(NewLeft, Right, N, PosTuple, PrefixTuple, StartPos, K, MaxFruits)
            end;
        true ->
            % Cost is valid (<= K). Calculate fruits in this window.
            % PrefixTuple is 1-based, with an initial 0.
            % Sum [Left, Right] = Prefix[Right+1] - Prefix[Left]
            CurrentFruits = element(Right + 1, PrefixTuple) - element(Left, PrefixTuple),
            NewMax = max(MaxFruits, CurrentFruits),
            
            % Try to expand window to Right
            solve_sliding_window(Left, Right + 1, N, PosTuple, PrefixTuple, StartPos, K, NewMax)
    end.

%% Calculates the minimum steps to visit both L and R starting from Start.
%% Formula: (Distance between L and R) + min(Distance from Start to L, Distance from Start to R)
calculate_cost(PosL, PosR, StartPos) ->
    DistL = abs(StartPos - PosL),
    DistR = abs(StartPos - PosR),
    (PosR - PosL) + min(DistL, DistR).