-spec spellchecker(Wordlist :: [unicode:unicode_binary()], Queries :: [unicode:unicode_binary()]) -> [unicode:unicode_binary()].


spellchecker(Ones, Twos) ->
    Wordlist = [binary_to_list(X) || X <- Ones],
    Queries = [binary_to_list(X) || X <- Twos],
    % 1. 预处理：构建查找表
    {ExactSet, CapMap, VowelMap} = build_maps(Wordlist, maps:new(), maps:new(), maps:new()),
    
    % 2. 查询：对每个 query 进行处理
    Three = [solve_query(Q, ExactSet, CapMap, VowelMap) || Q <- Queries],
    R = [list_to_binary(X) || X <- Three].

%% @private
%% 递归构建 Maps
build_maps([], Exact, Cap, Vowel) ->
    {Exact, Cap, Vowel};
build_maps([Word | Rest], Exact, Cap, Vowel) ->
    Lower = string_to_lower(Word),
    VKey = mask_vowels(Lower),
    
    % Exact Map: 总是添加，用于快速检查存在性
    NewExact = maps:put(Word, true, Exact),
    
    % Cap Map: 仅当 Key 不存在时添加 (保留第一个遇到的单词)
    NewCap = case maps:is_key(Lower, Cap) of
        true -> Cap;
        false -> maps:put(Lower, Word, Cap)
    end,
    
    % Vowel Map: 仅当 Key 不存在时添加 (保留第一个遇到的单词)
    NewVowel = case maps:is_key(VKey, Vowel) of
        true -> Vowel;
        false -> maps:put(VKey, Word, Vowel)
    end,
    
    build_maps(Rest, NewExact, NewCap, NewVowel).

%% @private
%% 处理单个查询，按照优先级顺序查找
solve_query(Query, ExactSet, CapMap, VowelMap) ->
    % 优先级 1: 精确匹配
    case maps:is_key(Query, ExactSet) of
        true -> 
            Query;
        false ->
            Lower = string_to_lower(Query),
            % 优先级 2: 大小写不敏感匹配
            case maps:find(Lower, CapMap) of
                {ok, Match} -> 
                    Match;
                error ->
                    % 优先级 3: 元音错误匹配
                    VKey = mask_vowels(Lower),
                    case maps:find(VKey, VowelMap) of
                        {ok, VMatch} -> 
                            VMatch;
                        error ->
                            % 无匹配
                            ""
                    end
            end
    end.

%% @private
%% 辅助函数：将字符串转为小写 (针对 ASCII)
string_to_lower(Str) ->
    [char_to_lower(C) || C <- Str].

char_to_lower(C) when C >= $A, C =< $Z -> C + 32;
char_to_lower(C) -> C.

%% @private
%% 辅助函数：将元音替换为 *
mask_vowels(Str) ->
    [case is_vowel(C) of true -> $*; false -> C end || C <- Str].

is_vowel($a) -> true;
is_vowel($e) -> true;
is_vowel($i) -> true;
is_vowel($o) -> true;
is_vowel($u) -> true;
is_vowel(_) -> false.