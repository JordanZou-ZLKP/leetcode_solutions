-spec my_atoi(S :: unicode:unicode_binary()) -> integer().
-define(INT_MAX, 2147483647).
-define(INT_MIN, -2147483648).

my_atoi(Sone) when is_binary(Sone) ->
    S = binary_to_list(Sone),
    Str = unicode:characters_to_list(S), % Ensure it's a proper string list
    Len = length(Str),
    
    {ok, I} = skip_whitespace(Str, 0, Len),
    if 
        I >= Len -> 
            0; % Reached end after whitespace
        true ->
            {Sign, NextI} = case lists:nth(I + 1, Str) of
                $+ -> {1, I + 1};
                $- -> {-1, I + 1};
                _ -> {1, I}
            end,
            
            case read_digits(Str, Len, NextI, 0) of
                {0, _} -> 
                    0; % No valid digit was read
                {Num, _} ->
                    Res = Sign * Num,
                    clamp(Res)
            end
    end.

skip_whitespace(Str, I, Len) when I < Len ->
    case lists:nth(I + 1, Str) of
        $\s -> skip_whitespace(Str, I + 1, Len);
        _ -> {ok, I}
    end;
skip_whitespace(_, I, _) -> {ok, I}.

read_digits(Str, Len, I, Acc) when I < Len ->
    Char = lists:nth(I + 1, Str),
    if 
        Char >= $0, Char =< $9 ->
            Digit = Char - $0,
            NewAcc = Acc * 10 + Digit,
            if 
                NewAcc > ?INT_MAX ->
                    read_digits(Str, Len, I + 1, NewAcc);
                true ->
                    read_digits(Str, Len, I + 1, NewAcc)
            end;
        true ->
            {Acc, I} % Stop at first non-digit
    end;
read_digits(_, _, I, Acc) ->
    {Acc, I}.

clamp(X) when X > ?INT_MAX -> ?INT_MAX;
clamp(X) when X < ?INT_MIN -> ?INT_MIN;
clamp(X) -> X.