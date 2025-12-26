%% Your functions will be called as such:
%% food_ratings_init_(Foods, Cuisines, Ratings),
%% food_ratings_change_rating(Food, NewRating),
%% Param_2 = food_ratings_highest_rated(Cuisine),

%% food_ratings_init_ will be called before every test case, in which you can do some necessary initializations.
-spec food_ratings_init_(Foods :: [unicode:unicode_binary()], Cuisines :: [unicode:unicode_binary()], Ratings :: [integer()]) -> any().
food_ratings_init_(Foods, Cuisines, Ratings) ->
    %% 清理之前的状态（防止测试用例之间污染）
    erase(),
    
    %% 组合三个列表: [{Food, Cuisine, Rating}, ...]
    Triples = lists:zip3(Foods, Cuisines, Ratings),
    
    %% 构建初始状态
    {FinalFMap, FinalCMap} = lists:foldl(
        fun({Food, Cuisine, Rating}, {FMap, CMap}) ->
            %% 1. 更新 FoodMap
            NewFMap = FMap#{Food => {Cuisine, Rating}},
            
            %% 2. 更新 CuisineMap
            %% 获取该菜系对应的树，如果不存在则创建一个空树
            Tree = maps:get(Cuisine, CMap, gb_trees:empty()),
            %% 构造 Key: {-Rating, Food}
            %% 这样 gb_trees:smallest 就能取到 评分最高(负值最小) 且 字典序最小 的项
            Key = {-Rating, Food},
            NewTree = gb_trees:insert(Key, ok, Tree),
            NewCMap = CMap#{Cuisine => NewTree},
            
            {NewFMap, NewCMap}
        end,
        {maps:new(), maps:new()},
        Triples
    ),
    
    %% 将状态存入进程字典
    put(food_ratings_data, {FinalFMap, FinalCMap}),
    null.

-spec food_ratings_change_rating(Food :: unicode:unicode_binary(), NewRating :: integer()) -> any().
food_ratings_change_rating(Food, NewRating) ->
    %% 从进程字典获取状态
    {FMap, CMap} = get(food_ratings_data),
    
    %% 1. 获取旧信息 (O(1))
    {Cuisine, OldRating} = maps:get(Food, FMap),
    
    %% 2. 只有当评分确实改变时才操作 (小优化)
    case OldRating =:= NewRating of
        true -> null;
        false ->
            %% 3. 更新 FoodMap
            NewFMap = FMap#{Food => {Cuisine, NewRating}},
            
            %% 4. 更新 CuisineMap (涉及 gb_trees 的删除和插入)
            Tree = maps:get(Cuisine, CMap),
            
            %% 删除旧节点: Key = {-OldRating, Food} (O(log K))
            OldKey = {-OldRating, Food},
            Tree1 = gb_trees:delete(OldKey, Tree),
            
            %% 插入新节点: Key = {-NewRating, Food} (O(log K))
            NewKey = {-NewRating, Food},
            Tree2 = gb_trees:insert(NewKey, ok, Tree1),
            
            NewCMap = CMap#{Cuisine => Tree2},
            
            %% 将新状态写回进程字典
            put(food_ratings_data, {NewFMap, NewCMap}),
            null
    end.

-spec food_ratings_highest_rated(Cuisine :: unicode:unicode_binary()) -> unicode:unicode_binary().
food_ratings_highest_rated(Cuisine) ->
    %% 获取状态
    {_FMap, CMap} = get(food_ratings_data),
    
    %% 获取该菜系的树
    Tree = maps:get(Cuisine, CMap),
    
    %% 获取树中最小的 Key (即评分最高且字典序最小)
    %% Complexity: O(log K) 或者 O(1) (取决于 gb_trees 实现，通常取最小值很快)
    {{_NegRating, Food}, _Val} = gb_trees:smallest(Tree),
    
    Food.

%% Your functions will be called as such:
%% food_ratings_init_(Foods, Cuisines, Ratings),
%% food_ratings_change_rating(Food, NewRating),
%% Param_2 = food_ratings_highest_rated(Cuisine),

%% food_ratings_init_ will be called before every test case, in which you can do some necessary initializations.