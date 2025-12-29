-spec find_lex_smallest_string(S :: unicode:unicode_binary(), A :: integer(), B :: integer()) -> unicode:unicode_binary().
find_lex_smallest_string(One, A, B) ->
    S = binary_to_list(One),
    % 1. Convert string "5525" to list of integers [5, 5, 2, 5]
    Nums = [C - $0 || C <- S],
    
    % 2. Generate all unique rotations reachable by rotating right by B
    Rotations = generate_rotations(Nums, B),
    
    % 3. Determine search space for additions based on parity of B
    % If B is odd, we can modify both even and odd indices independently.
    % If B is even, we can only modify odd indices.
    IncrementPairs = case B rem 2 of
        1 -> [{EvenInc, OddInc} || EvenInc <- lists:seq(0, 9), OddInc <- lists:seq(0, 9)];
        0 -> [{0, OddInc} || OddInc <- lists:seq(0, 9)]
    end,
    
    % 4. Generate all candidates
    Candidates = [
        apply_increments(Rot, A, Pair) 
        || Rot <- Rotations, 
           Pair <- IncrementPairs
    ],
    
    % 5. Find the lexicographically smallest candidate
    BestNums = lists:min(Candidates),
    
    % 6. Convert back to string
    Rone = [D + $0 || D <- BestNums],
    R = list_to_binary(Rone).


%% --- Helper Functions ---

%% @doc Generates all distinct rotations of List by step B.
generate_rotations(List, B) ->
    generate_rotations(List, B, sets:new(), []).

generate_rotations(Curr, B, Seen, Acc) ->
    case sets:is_element(Curr, Seen) of
        true -> 
            Acc; % Cycle detected, return accumulated rotations
        false ->
            Next = rotate_right(Curr, B),
            generate_rotations(Next, B, sets:add_element(Curr, Seen), [Curr | Acc])
    end.

%% @doc Rotates a list to the right by K positions.
rotate_right(List, K) ->
    Len = length(List),
    Shift = K rem Len,
    {Front, Back} = lists:split(Len - Shift, List),
    Back ++ Front.

%% @doc Applies (EvenInc * A) to even indices and (OddInc * A) to odd indices.
apply_increments(List, A, {EvenInc, OddInc}) ->
    transform_list(List, 0, A, EvenInc, OddInc).

transform_list([], _, _, _, _) -> [];
transform_list([H|T], Index, A, EvenInc, OddInc) ->
    % Determine how much to add based on current index parity
    Multiplier = if 
        Index rem 2 == 0 -> EvenInc;
        true -> OddInc
    end,
    
    % Apply addition modulo 10
    NewVal = (H + Multiplier * A) rem 10,
    
    [NewVal | transform_list(T, Index + 1, A, EvenInc, OddInc)].