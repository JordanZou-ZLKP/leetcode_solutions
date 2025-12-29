-spec trap_rain_water(HeightMap :: [[integer()]]) -> integer().
trap_rain_water(HeightMap) ->
    M = length(HeightMap),
    if
        M < 3 -> 0; %% Less than 3 rows cannot trap water
        true ->
            N = length(hd(HeightMap)),
            if
                N < 3 -> 0; %% Less than 3 cols cannot trap water
                true ->
                    %% Convert list of lists to tuple of tuples for O(1) read access
                    %% This is more efficient than lists for random access.
                    Grid = list_to_tuple([list_to_tuple(Row) || Row <- HeightMap]),
                    solve(M, N, Grid)
            end
    end.

%% ====================================================================
%% Internal Logic
%% ====================================================================

solve(M, N, Grid) ->
    %% 1. Initialize Heap and Visited set with the boundary cells
    {Heap, Visited} = init_boundary(M, N, Grid),
    
    %% 2. Process cells using BFS with Priority Queue
    process_heap(Heap, Visited, Grid, M, N, 0).

%% Initialize the boundary (perimeter) into the heap and visited map
init_boundary(M, N, Grid) ->
    %% Helper to add a cell
    Add = fun(R, C, {HAcc, VAcc}) ->
        Height = get_height(R, C, Grid),
        %% Key format: {Height, Row, Col} ensuring uniqueness and correct sorting
        NewHAcc = gb_trees:enter({Height, R, C}, ok, HAcc),
        NewVAcc = VAcc#{{R, C} => true},
        {NewHAcc, NewVAcc}
    end,

    Acc0 = {gb_trees:empty(), #{}},

    %% Add Top (Row 1) and Bottom (Row M)
    Acc1 = lists:foldl(fun(C, Acc) ->
        A1 = Add(1, C, Acc),
        Add(M, C, A1)
    end, Acc0, lists:seq(1, N)),

    %% Add Left (Col 1) and Right (Col N), excluding corners already handled
    lists:foldl(fun(R, Acc) ->
        A1 = Add(R, 1, Acc),
        Add(R, N, A1)
    end, Acc1, lists:seq(2, M - 1)).

%% Main BFS Loop
process_heap(Heap, Visited, Grid, M, N, TotalVolume) ->
    case gb_trees:is_empty(Heap) of
        true ->
            TotalVolume;
        false ->
            %% Pop the smallest height cell from heap
            {{H, R, C}, _Val, NextHeap} = gb_trees:take_smallest(Heap),
            
            %% Check neighbors
            {NewHeap, NewVisited, NewVolume} = 
                check_neighbors(R, C, H, NextHeap, Visited, Grid, M, N, TotalVolume),
            
            process_heap(NewHeap, NewVisited, Grid, M, N, NewVolume)
    end.

check_neighbors(R, C, H, Heap, Visited, Grid, M, N, Vol) ->
    %% Directions: Right, Left, Down, Up
    Dirs = [{0, 1}, {0, -1}, {1, 0}, {-1, 0}],
    
    lists:foldl(fun({Dr, Dc}, {HAcc, VAcc, VolAcc}) ->
        NR = R + Dr,
        NC = C + Dc,
        
        %% Check Bounds
        IsValid = (NR >= 1) andalso (NR =< M) andalso (NC >= 1) andalso (NC =< N),
        
        if
            not IsValid ->
                {HAcc, VAcc, VolAcc};
            true ->
                %% Check Visited
                case maps:is_key({NR, NC}, VAcc) of
                    true ->
                        {HAcc, VAcc, VolAcc};
                    false ->
                        NHeight = get_height(NR, NC, Grid),
                        
                        %% Water trapped logic:
                        %% If current boundary H > neighbor height, we trap water.
                        Trapped = max(0, H - NHeight),
                        
                        %% The neighbor enters the heap with the max height 
                        %% (either its own or the water level filled up to H)
                        NewBoundaryHeight = max(H, NHeight),
                        
                        NewHAcc = gb_trees:insert({NewBoundaryHeight, NR, NC}, ok, HAcc),
                        NewVAcc = VAcc#{{NR, NC} => true},
                        
                        {NewHAcc, NewVAcc, VolAcc + Trapped}
                end
        end
    end, {Heap, Visited, Vol}, Dirs).

%% Helper to access grid (1-based index)
get_height(R, C, Grid) ->
    element(C, element(R, Grid)).

%% Utility: max function
max(A, B) when A > B -> A;
max(_, B) -> B.