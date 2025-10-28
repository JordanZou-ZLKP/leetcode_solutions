-spec is_palindrome(X :: integer()) -> boolean().
is_palindrome(X) ->
    if
        X < 0 orelse (X rem 10 =:= 0 andalso X =/= 0) ->
            false;
        true ->
            is_palindrome_helper(X, 0)
    end.

is_palindrome_helper(X, RevHalf) when X > RevHalf ->
    Digit = X rem 10,
    NewRevHalf = RevHalf * 10 + Digit,
    NewX = X div 10,
    is_palindrome_helper(NewX, NewRevHalf);
is_palindrome_helper(X, RevHalf) ->
    (X =:= RevHalf) orelse (X =:= RevHalf div 10).