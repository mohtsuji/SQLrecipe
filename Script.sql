DROP TABLE IF EXISTS access_log;
CREATE TABLE access_log(
    stamp      timestamp
  , session    varchar(255)
  , action     varchar(255)
  , keyword    text
  , url        text
  , referrer   text
  , result_num integer
);
INSERT INTO access_log
VALUES
    ('2017-01-05 23:35:13', '0CVKaz', 'search', 'mynavi quest2'                       , 'http://www.example.com/search_result?q=mynavi+quest'                        , ''                                                                         ,   0 )
  , ('2017-01-05 23:36:08', '0CVKaz', 'search', 'mynavi quest the awakening of data'  , 'http://www.example.com/search_result?q=mynavi+quest+the+awakening+of+data'  , ''                                                                         , 630 )
  , ('2017-01-05 23:37:17', '0CVKaz', 'detail', ''                                    , 'http://www.example.com/detail?id=170'                                       , 'http://www.example.com/search_result?q=mynavi+quest+the+awakening+of+data', NULL)
  , ('2017-01-05 23:38:38', '0CVKaz', 'detail', ''                                    , 'http://www.example.com/detail?id=133'                                       , 'http://www.example.com/search_result?q=mynavi+quest+the+awakening+of+data', NULL)
  , ('2017-01-05 23:40:10', '0CVKaz', 'search', 'mynavi quest the awakening of data'  , 'http://www.example.com/search_result?q=mynavi+quest+the+awakening+of+data'  , ''                                                                         , 630 )
  , ('2017-01-05 23:41:43', '0CVKaz', 'detail', ''                                    , 'http://www.example.com/detail?id=64'                                        , 'http://www.example.com/search_result?q=mynavi+quest+the+awakening+of+data', NULL)
  , ('2017-01-05 23:43:10', '0CVKaz', 'search', 'mynavi quest the awakening of data'  , 'http://www.example.com/search_result?q=mynavi+quest+the+awakening+of+data'  , ''                                                                         , 630 )
  , ('2017-01-05 23:34:57', '1QceiB', 'search', 'yamada taro'                         , 'http://www.example.com/search_result?q=yamada+taro'                         , ''                                                                         , 367 )
  , ('2017-01-05 23:35:37', '1QceiB', 'search', 'yamada taro football'                , 'http://www.example.com/search_result?q=yamada+taro+football'                , ''                                                                         , 105 )
  , ('2017-01-05 23:36:48', '1QceiB', 'detail', ''                                    , 'http://www.example.com/detail?id=99'                                        , 'http://www.example.com/search_result?q=yamada+taro+football'              , NULL)
  , ('2017-01-05 23:37:27', '1QceiB', 'detail', ''                                    , 'http://www.example.com/detail?id=142'                                       , 'http://www.example.com/search_result?q=yamada+taro+football'              , NULL)
  , ('2017-01-05 23:38:52', '1QceiB', 'search', 'yamada taro football transfers'      , 'http://www.example.com/search_result?q=yamada+taro+football+transfers'      , ''                                                                         ,  50 )
  , ('2017-01-05 23:39:50', '1QceiB', 'detail', ''                                    , 'http://www.example.com/detail?id=7'                                         , 'http://www.example.com/search_result?q=yamada+taro+football'              , NULL)
  , ('2017-01-05 23:41:23', '1QceiB', 'search', 'yamada taro football transfers where', 'http://www.example.com/search_result?q=yamada+taro+football+transfers+where', ''                                                                         ,   0 )
  , ('2017-01-05 23:34:39', '1hI43A', 'search', 'english'                             , 'http://www.example.com/search_result?q=english'                             , ''                                                                         , 343 )
  , ('2017-01-05 23:36:08', '1hI43A', 'search', 'history of english'                  , 'http://www.example.com/search_result?q=history+of+english'                  , ''                                                                         , 757 )
  , ('2017-01-05 23:36:39', '1hI43A', 'detail', ''                                    , 'http://www.example.com/detail?id=9'                                         , 'http://www.example.com/search_result?q=history+of+english'                , NULL)
  , ('2017-01-05 23:38:10', '1hI43A', 'detail', ''                                    , 'http://www.example.com/detail?id=137'                                       , 'http://www.example.com/search_result?q=history+of+english'                , NULL)
  , ('2017-01-05 23:39:17', '1hI43A', 'search', 'history of english origin'           , 'http://www.example.com/search_result?q=history+of+english+origin'           , ''                                                                         , 963 )
  , ('2017-01-05 23:40:04', '1hI43A', 'detail', ''                                    , 'http://www.example.com/detail?id=158'                                       , 'http://www.example.com/search_result?q=history+of+english'                , NULL)
  , ('2017-01-05 23:40:52', '1hI43A', 'search', 'history of english england'          , 'http://www.example.com/search_result?q=history+of+english+england'          , ''                                                                         , 303 )
  , ('2017-01-06 23:34:36', '2bGs3i', 'search', 'nail'                                , 'http://www.example.com/search_result?q=nail'                                , ''                                                                         , 730 )
  , ('2017-01-06 23:35:41', '2bGs3i', 'search', 'manikure'                            , 'http://www.example.com/search_result?q=manikure'                            , ''                                                                         , 0   )
  , ('2017-01-06 23:35:41', '2bGs3i', 'search', 'manicure'                            , 'http://www.example.com/search_result?q=manicure'                            , ''                                                                         , 64  )
  , ('2017-01-06 23:36:33', '2bGs3i', 'detail', ''                                    , 'http://www.example.com/detail?id=123'                                       , 'http://www.example.com/search_result?q=manicure'                          , NULL)
  , ('2017-01-06 23:38:01', '2bGs3i', 'detail', ''                                    , 'http://www.example.com/detail?id=11'                                        , 'http://www.example.com/search_result?q=manicure'                          , NULL)
  , ('2017-01-06 23:38:52', '2bGs3i', 'search', 'manicure red'                        , 'http://www.example.com/search_result?q=manicure+red'                        , ''                                                                         , 827 )
  , ('2017-01-06 23:40:17', '2bGs3i', 'detail', ''                                    , 'http://www.example.com/detail?id=56'                                        , 'http://www.example.com/search_result?q=manicure'                          , NULL)
  , ('2017-01-06 23:41:14', '2bGs3i', 'search', 'manicure dark red'                   , 'http://www.example.com/search_result?q=manicure+dark+red'                   , ''                                                                         , 920 )
  , ('2017-01-06 23:34:54', '2mmGwD', 'search', 'fab'                                 , 'http://www.example.com/search_result?q=fab'                                 , ''                                                                         , 646 )
  , ('2017-01-06 23:35:29', '2mmGwD', 'search', 'fabulous'                            , 'http://www.example.com/search_result?q=fabulous'                            , 'http://www.example.com/search_result?q=fab'                               , 179 )
  , ('2017-01-06 23:36:49', '2mmGwD', 'detail', ''                                    , 'http://www.example.com/detail?id=87'                                        , 'http://www.example.com/search_result?q=fabulous'                          , NULL)
  , ('2017-01-06 23:38:14', '2mmGwD', 'detail', ''                                    , 'http://www.example.com/detail?id=24'                                        , 'http://www.example.com/search_result?q=fabulous'                          , NULL)
  , ('2017-01-06 23:39:08', '2mmGwD', 'search', 'fabulous how to use'                 , 'http://www.example.com/search_result?q=fabulous+how+to+use'                 , ''                                                                         , 856 )
  , ('2017-01-06 23:40:05', '2mmGwD', 'detail', ''                                    , 'http://www.example.com/detail?id=51'                                        , 'http://www.example.com/search_result?q=fabulous+how+to+use'               , NULL)
  , ('2017-01-06 23:41:34', '2mmGwD', 'search', 'fabulous synonym'                    , 'http://www.example.com/search_result?q=fabulous+synonym'                    , ''                                                                         , 875 )
;

select * from access_log al ;

with 
search_keyword_stat as (
	-- 検索キーワード全体の集計結果
	select 
		keyword
		, result_num
		, count(1) as search_count
		, 100.0 * count(1) / count(1) over() as search_share
	from access_log al 
	where action = 'search'
	group by keyword, result_num
)
-- NoMatchワードの集計結果
select 
	keyword
	, search_count
	, search_share
	-- noMatchのキーワードの中でそのキーワードの検索回数が占める割合
	, 100.0 * search_count / sum(search_count) over() as no_match_share
from search_keyword_stat
where result_num = 0
	;


-- 8.1.6
DROP TABLE IF EXISTS search_result;
CREATE TABLE search_result(
    keyword varchar(255)
  , rank    integer
  , item    varchar(255)
);
INSERT INTO search_result
VALUES
  ('sql'     ,  1, 'book001')
, ('sql'     ,  2, 'book005')
, ('sql'     ,  3, 'book012')
, ('sql'     ,  4, 'book004')
, ('sql'     ,  5, 'book003')
, ('sql'     ,  6, 'book010')
, ('sql'     ,  7, 'book024')
, ('sql'     ,  8, 'book025')
, ('sql'     ,  9, 'book050')
, ('sql'     , 10, 'book100')
, ('postgres',  1, 'book002')
, ('postgres',  2, 'book004')
, ('postgres',  3, 'book012')
, ('postgres',  4, 'book008')
, ('postgres',  5, 'book003')
, ('postgres',  6, 'book010')
, ('postgres',  7, 'book035')
, ('postgres',  8, 'book040')
, ('postgres',  9, 'book077')
, ('postgres', 10, 'book100')
, ('hive'    ,  1, 'book200')
;
DROP TABLE IF EXISTS correct_result;
CREATE TABLE correct_result(
    keyword varchar(255)
  , item    varchar(255)
);
INSERT INTO correct_result
VALUES
  ('sql'     , 'book003')
, ('sql'     , 'book005')
, ('sql'     , 'book008')
, ('sql'     , 'book010')
, ('sql'     , 'book025')
, ('sql'     , 'book100')
, ('postgres', 'book008')
, ('postgres', 'book010')
, ('postgres', 'book030')
, ('postgres', 'book055')
, ('postgres', 'book066')
, ('postgres', 'book100')
, ('hive'    , 'book200')
, ('redshift', 'book300')
;
select * from search_result ;
select * from correct_result ;


-- 8.1.6.1 
with
search_result_with_correct_items as (
	select 
		coalesce (r.keyword, c.keyword) as keyword
		, r.rank
		, coalesce (r.item, c.item) as item
		-- c.itemがNULLでないなら、そのitemは正しいということ
		, case when c.item is not null then 1 else 0 end as correct
	from search_result as r
	full outer join correct_result as c 
		on r.item = c.item
		and r.keyword = c.keyword
)
, search_result_with_recall as (
	select 
		*
		-- 検索結果の上位から、正解データに含まれるアイテムの数を累計する
		, sum(correct)
			-- rankがNULLの場合、ソート順で最後に位置させたいため、便宜上、十分大きな値に変換する
			over(partition by keyword order by coalesce(rank, 10000) asc 
			rows between unbounded preceding and current row) as cum_correct
		, case 
			-- 検索結果に含まれないアイテムのレコードは、便宜上再現率を0とする
			when rank is null then 0.0
			else 
				100.0 
				* sum(correct) over(partition by keyword order by coalesce(rank, 10000) asc 
					rows between unbounded preceding and current row)
				/ sum(correct) over(partition by keyword)
		end as recall
	from search_result_with_correct_items
)
, recall_over_rank_5 as (
	select
		*
		-- 検索結果の順位が大きい順に番号を振る
		-- 検索結果に出ていないアイテムの順位は、便宜上0として扱う
		, row_number() over(partition by keyword order by coalesce(rank, 0) desc) as desc_number
	from search_result_with_recall
	where --検索結果の順位が５以下または検索結果に含まれないアイテムのみを表示
		coalesce (rank, 0) <= 5
)
select 
	*
from recall_over_rank_5
--検索結果が上位５件のうち、最も順位が大きいレコードに絞る
where desc_number = 1
;


-- 8.2.1 アソシエーション分析を行う
DROP TABLE IF EXISTS purchase_detail_log;
CREATE TABLE purchase_detail_log(
    stamp       varchar(255)
  , session     varchar(255)
  , purchase_id integer
  , product_id  varchar(255)
);
INSERT INTO purchase_detail_log
  VALUES
    ('2016-11-03 18:10', '989004ea',  1, 'D001')
  , ('2016-11-03 18:10', '989004ea',  1, 'D002')
  , ('2016-11-03 20:00', '47db0370',  2, 'D001')
  , ('2016-11-04 13:00', '1cf7678e',  3, 'D002')
  , ('2016-11-04 15:00', '5eb2e107',  4, 'A001')
  , ('2016-11-04 15:00', '5eb2e107',  4, 'A002')
  , ('2016-11-04 16:00', 'fe05e1d8',  5, 'A001')
  , ('2016-11-04 16:00', 'fe05e1d8',  5, 'A003')
  , ('2016-11-04 17:00', '87b5725f',  6, 'A001')
  , ('2016-11-04 17:00', '87b5725f',  6, 'A003')
  , ('2016-11-04 17:00', '87b5725f',  6, 'A004')
  , ('2016-11-04 18:00', '5d5b0997',  7, 'A005')
  , ('2016-11-04 18:00', '5d5b0997',  7, 'A006')
  , ('2016-11-04 19:00', '111f2996',  8, 'A002')
  , ('2016-11-04 19:00', '111f2996',  8, 'A003')
  , ('2016-11-04 20:00', '3efe001c',  9, 'A001')
  , ('2016-11-04 20:00', '3efe001c',  9, 'A003')
  , ('2016-11-04 21:00', '9afaf87c', 10, 'D001')
  , ('2016-11-04 21:00', '9afaf87c', 10, 'D003')
  , ('2016-11-04 22:00', 'd45ec190', 11, 'D001')
  , ('2016-11-04 22:00', 'd45ec190', 11, 'D002')
  , ('2016-11-04 23:00', '36dd0df7', 12, 'A002')
  , ('2016-11-04 23:00', '36dd0df7', 12, 'A003')
  , ('2016-11-04 23:00', '36dd0df7', 12, 'A004')
  , ('2016-11-05 15:00', 'cabf98e8', 13, 'A002')
  , ('2016-11-05 15:00', 'cabf98e8', 13, 'A004')
  , ('2016-11-05 16:00', 'f3b47933', 14, 'A005')
;

select * from purchase_detail_log pdl ;


with
purchase_id_count as (
	-- 購入詳細ログからユニークな購入ログ数を計算
	select 
		count(distinct purchase_id) as purchase_count
	from purchase_detail_log pdl 
)
, purchase_detail_log_with_counts as (
	select
		d.purchase_id 
		, p.purchase_count
		, d.product_id 
		-- 商品別購入数を計算
		, count(*) over(partition by d.product_id) as product_count
	from purchase_detail_log as d 
	cross join purchase_id_count as p-- 購入ログ数をすべてのレコードと結合
)
, product_pair_with_stat as (
	-- 購入された商品のペアを作成する
	select
		l1.product_id as p1
		, l2.product_id as p2
		, l1.product_count as p1_count
		, l2.product_count as p2_count
		, count(1) as p1_p2_count-- ２つの商品の同時購入数
		, l1.purchase_count as purchase_count
	from purchase_detail_log_with_counts as l1
	inner join purchase_detail_log_with_counts as l2
		on l1.purchase_id = l2.purchase_id
	where --同じ商品の組み合わせは排除する
		l1.product_id <> l2.product_id
	group by 
		l1.product_id
		, l2.product_id
		, l1.product_count
		, l2.product_count
		, l1.purchase_count
)
select 
	p1, p2
	, 100.0 * p1_p2_count / purchase_count as support -- 支持率
	, 100.0 * p1_p2_count / p1_count as confidence -- 信頼度
	, (100.0 * p1_p2_count / p1_count)
		/ (100.0 * p2_count / purchase_count) as lift -- リフトを計算
from product_pair_with_stat
order by p1, p2
;


-- 8.3.2.1 アイテムレコメンドシステムを作成する
DROP TABLE IF EXISTS action_log;
CREATE TABLE action_log(
    stamp   varchar(255)
  , user_id varchar(255)
  , action  varchar(255)
  , product varchar(255)
);
INSERT INTO action_log
VALUES
    ('2016-11-03 18:00:00', 'U001', 'view'    , 'D001')
  , ('2016-11-03 18:01:00', 'U001', 'view'    , 'D002')
  , ('2016-11-03 18:02:00', 'U001', 'view'    , 'D003')
  , ('2016-11-03 18:03:00', 'U001', 'view'    , 'D004')
  , ('2016-11-03 18:04:00', 'U001', 'view'    , 'D005')
  , ('2016-11-03 18:05:00', 'U001', 'view'    , 'D001')
  , ('2016-11-03 18:06:00', 'U001', 'view'    , 'D005')
  , ('2016-11-03 18:10:00', 'U001', 'purchase', 'D001')
  , ('2016-11-03 18:10:00', 'U001', 'purchase', 'D005')
  , ('2016-11-03 19:00:00', 'U002', 'view'    , 'D001')
  , ('2016-11-03 19:01:00', 'U002', 'view'    , 'D003')
  , ('2016-11-03 19:02:00', 'U002', 'view'    , 'D005')
  , ('2016-11-03 19:03:00', 'U002', 'view'    , 'D003')
  , ('2016-11-03 19:04:00', 'U002', 'view'    , 'D005')
  , ('2016-11-03 19:10:00', 'U002', 'purchase', 'D001')
  , ('2016-11-03 19:10:00', 'U002', 'purchase', 'D005')
  , ('2016-11-03 20:00:00', 'U003', 'view'    , 'D001')
  , ('2016-11-03 20:01:00', 'U003', 'view'    , 'D004')
  , ('2016-11-03 20:02:00', 'U003', 'view'    , 'D005')
  , ('2016-11-03 20:10:00', 'U003', 'purchase', 'D004')
  , ('2016-11-03 20:10:00', 'U003', 'purchase', 'D005')
;
select * from action_log al ;

with 
ratings as (
	select 
		user_id 
		, product 
		-- 商品の閲覧数
		, sum(case when action = 'view' then 1 else 0 end) as view_count
		-- 商品の購入数
		, sum(case when action = 'purchase' then 1 else 0 end) as purchase_count
		-- 閲覧数と購入数を3:7の割合で重み付き平均する
		, 0.3 * sum(case when action = 'view' then 1 else 0 end)
		 + 0.7 * sum(case when action = 'purchase' then 1 else 0 end)
		 as score
	from action_log 
	group by user_id, product
)
select 
	r1.product as target
	, r2.product as related
	-- 両方のアイテムを閲覧または購入しているユーザー数
	, count(r1.user_id) as users
	-- スコア同士の掛け算を合計して、関連度を計算する（ベクトルの内積の考え方で、大きいほど関連度が高い）
	, sum(r1.score * r2.score) as score
	-- 商品の関連度順
	, row_number() 
		over(partition by r1.product order by sum(r1.score * r2.score) desc)
		as rank
from ratings as r1
inner join ratings as r2
	-- 共通のユーザが存在する商品のペアを作成する
	on r1.user_id = r2.user_id
where -- 同じアイテムのペアは排除する
	r1.product <> r2.product
group by r1.product, r2.product
order by target, rank
;






























