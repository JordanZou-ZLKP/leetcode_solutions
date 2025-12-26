-spec number_of_pairs(Points :: [[integer()]]) -> integer().
number_of_pairs(Points) ->
    % 1. Convert list of lists to list of tuples for easier handling: [[x,y]] -> [{x,y}]
    TuplePoints = [{X, Y} || [X, Y] <- Points],
    
    % 2. Sort points: 
    %    Primary Key: X Ascending
    %    Secondary Key: Y Descending (so that higher points come first when on same vertical line)
    SortedPoints = lists:sort(fun({X1, Y1}, {X2, Y2}) ->
        if
            X1 < X2 -> true;
            X1 > X2 -> false;
            true -> Y1 >= Y2 % If X is same, Y descending
        end
    end, TuplePoints),
    
    % 3. Iterate to find pairs
    find_pairs(SortedPoints).

%% @doc Outer loop: iterates through each point as point A
find_pairs([]) -> 0;
find_pairs([A | Rest]) ->
    % Valid pairs starting with A + Valid pairs in the rest of the list
    check_targets(A, Rest, []) + find_pairs(Rest).

%% @doc Inner loop: iterates through subsequent points as point B
%% A: The 'upper-left' candidate
%% Targets: The list of potential 'B' points
%% MiddlePoints: Accumulates points found strictly between A and current B in the sorted list
check_targets(_, [], _) -> 0;
check_targets(A = {Ax, Ay}, [B = {Bx, By} | Rest], MiddlePoints) ->
    % Condition 1: A must be upper-left of B.
    % Since we sorted by X asc, Ax <= Bx is guaranteed.
    % We only need to check if Ay >= By.
    IsUpperLeft = Ay >= By,
    
    % Condition 2: No other points in the rectangle.
    % We check if any point in 'MiddlePoints' lies inside the rectangle formed by A and B.
    IsValid = IsUpperLeft andalso is_empty_rect(A, B, MiddlePoints),
    
    Count = if IsValid -> 1; true -> 0 end,
    
    % Recursive step:
    % We proceed to the next candidate in 'Rest'.
    % Crucially, the current 'B' becomes a 'MiddlePoint' for any future target further down the list.
    Count + check_targets(A, Rest, [B | MiddlePoints]).

%% @doc Checks if any point in the list 'Obstacles' is inside the rectangle defined by A and B
is_empty_rect(_, _, []) -> true;
is_empty_rect(A = {Ax, Ay}, B = {Bx, By}, [{Mx, My} | Rest]) ->
    % Rectangle bounds: X in [Ax, Bx], Y in [By, Ay]
    % Note: Problem states "including the border", so we use =< and >=
    InX = (Mx >= Ax) andalso (Mx =< Bx),
    InY = (My >= By) andalso (My =< Ay),
    
    case InX andalso InY of
        true -> false; % Found an obstacle
        false -> is_empty_rect(A, B, Rest)
    end.