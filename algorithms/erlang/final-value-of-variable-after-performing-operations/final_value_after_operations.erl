-module(foo).
-export([main/1]).

main([]) ->
    Input = [<<"--X">>,<<"X++">>,<<"X++">>],
    R = final_value_after_operations(Input),
    io:format("~p~n",[R]).

-spec final_value_after_operations(Operations :: [unicode:unicode_binary()]) -> integer().
final_value_after_operations(Operations) ->
    lists:foldl(fun(Op, X) ->
        case Op of
            <<"++X">> -> X + 1;
            <<"X++">> -> X + 1;
            <<"--X">> -> X - 1;
            <<"X--">> -> X - 1
        end
    end, 0, Operations).
