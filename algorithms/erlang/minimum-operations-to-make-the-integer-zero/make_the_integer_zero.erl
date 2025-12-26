-spec make_the_integer_zero(Num1 :: integer(), Num2 :: integer()) -> integer().
make_the_integer_zero(Num1, Num2) ->
    solve(1, Num1, Num2).

%% Loop k from 1. 
%% We limit recursion to around 60 because if we haven't found a solution 
%% by the time k exceeds the bit-width of standard integers, it's likely impossible
%% or optimal solution lies within small k.
solve(K, _Num1, _Num2) when K > 60 -> 
    -1;
solve(K, Num1, Num2) ->
    Target = Num1 - (K * Num2),
    
    % Check validity conditions
    if
        % Case 1: Target becomes negative or smaller than K.
        % Since 2^i >= 1, sum of k powers must be >= k.
        Target < K ->
            if 
                % If Num2 >= 0, Target will only decrease as K increases.
                % We will never reach a valid state.
                Num2 >= 0 -> -1;
                
                % If Num2 < 0, Target increases as K increases (subtracting negative).
                % We might reach a valid state later.
                true -> solve(K + 1, Num1, Num2)
            end;

        % Case 2: Target is valid range, check bit count.
        true ->
            Bits = count_set_bits(Target),
            if
                % If we have enough "slots" (K) to accommodate the required bits.
                % We can always split bits (2^i = 2^(i-1) + 2^(i-1)) to increase count to match K.
                Bits =< K -> K;
                
                % Not enough K to represent the bits yet.
                true -> solve(K + 1, Num1, Num2)
            end
    end.

%% Helper: Count number of 1s in binary representation (Population Count)
count_set_bits(0) -> 0;
count_set_bits(N) ->
    (N band 1) + count_set_bits(N bsr 1).