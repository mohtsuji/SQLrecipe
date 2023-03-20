-- 3.3.1.1 テーブルの特徴を把握する
DROP TABLE IF EXISTS review;
CREATE TABLE review (
    user_id    varchar(255)
  , product_id varchar(255)
  , score      numeric
);

INSERT INTO review
VALUES
    ('U001', 'A001', 4.0)
  , ('U001', 'A002', 5.0)
  , ('U001', 'A003', 5.0)
  , ('U002', 'A001', 3.0)
  , ('U002', 'A002', 3.0)
  , ('U002', 'A003', 4.0)
  , ('U003', 'A001', 5.0)
  , ('U003', 'A002', 4.0)
  , ('U003', 'A003', 4.0)
;
select * from review;

select 
	count(*) as total_count
	, count(distinct user_id) as user_count
	, count(distinct product_id) as product_count
	, sum(score) as sum_score
	, avg(score) as avg_score
	, min(score) as min_score
	, max(score) as max_score
from review;

-- ユーザごとにテーブルの特徴を把握する
-- group byを使用すると、group byに指定した絡むをユニークキーとして新たなテーブルが作成されている
-- その過程でgroup byに指定されていないカラムの値は失われているので、
-- group byに指定したカラムと集約関数以外はSELECTできなくなる
select 
	user_id
	, count(*) as total_count
	, count(distinct product_id) as product_count
	, sum(score) as sum_score
	, avg(score) as avg_score
	, min(score) as min_score
	, max(score) as max_score
from review
group by user_id;


-- 3.3.1.3 WINDOW関数を用いて集約関数の結果と元の値（group byで失われた値）を同時に扱う
-- WINDOW関数でPARTITION BYを利用してグルーピングする
-- WINDOW関数->集約関数の後にOVER()をつける。OVER()の中でカラムを指定しなかったら全体が集約される
select 
	user_id
	, product_id
	, score
	-- 全体のscore平均値
	, avg(score) over() as total_avg_score
	-- ユーザごとのscore平均値
	, avg(score) over(partition by user_id) as user_avg_score
	-- 自分の平均とのscoreの差
	, score - avg(score) over(partition by user_id) as user_avg_score_diff
from review ;


-- テーブル内の順序を扱う
-- WINDOW関数でOVER(ORDER BY)して好きな順序で並べてランキングする
DROP TABLE IF EXISTS popular_products;
CREATE TABLE popular_products (
    product_id varchar(255)
  , category   varchar(255)
  , score      numeric
);

INSERT INTO popular_products
VALUES
    ('A001', 'action', 94)
  , ('A002', 'action', 81)
  , ('A003', 'action', 78)
  , ('A004', 'action', 64)
  , ('D001', 'drama' , 90)
  , ('D002', 'drama' , 82)
  , ('D003', 'drama' , 78)
  , ('D004', 'drama' , 58)
;
select * from popular_products ;

select
	product_id
	, score
	-- スコア順に一意なランキングを付与する
	, row_number() over(order by score desc) as row
	-- 同順位を許容するランキングを付与する
	, rank() over(order by score desc) as rank
	-- 同順位を許容し、同順位の次の順位を飛ばさないランキングを付与する
	, dense_rank() over(order by score desc) as dense_rank 
	-- 現在の行より前の行の値を取得する
	, lag(product_id) over(order by score desc) as lag1
	, lag(product_id, 2) over(order by score desc) as lag2 -- 2つ前の行を取得
	-- 現在の行より後の行の値を取得する
	, lead(product_id) over(order by score desc) as lag1
	, lead(product_id, 2) over(order by score desc) as lag2 -- 2つ後の行を取得
from popular_products
order by row;


-- 3.3.2.2 WINDOW関数とORDER BYを用いて好きな順序で集約関数を適用する
select 
	product_id
	, score
	-- スコア順に一意のランキングを付与する
	, row_number() over(order by score desc) as row
	-- ランキング上位からの累計スコア合計値を計算する
	, sum(score) over(order by score desc 
						rows between unbounded preceding and current row)
						as cum_score
	-- 現在の行と前後1行ずつの、合計3行の平均スコアを計算する
	, avg(score) over(order by score desc
						rows between 1 preceding and 1 following)
						as local_avg
	-- ランキング最上位の商品IDを取得する
	, first_value(product_id) over(order by score desc
					rows between unbounded preceding and unbounded following)
					as first_value
	-- ランキング最下位の商品IDを取得する
	, last_value(product_id) over(order by score desc
					rows between unbounded preceding and unbounded following)
					as last_value
from popular_products
order by row;


-- 3.3.2.3 WINDOW関数のフレーム（範囲）指定ごとに商品IDを集約する
select 
	product_id
	, score
	-- スコア順に一意のランキングを付与する
	, row_number() over(order by score desc) as row
	-- ランキングの最初から最後までの範囲を対象に商品IDを集約（array_aggは任意の型の配列を作成する）
	, array_agg(product_id) over(order by score desc
								rows between unbounded preceding and unbounded following)
							as whole_agg
	-- ランキングの最初から現在までの範囲を対象に商品IDを集約（array_aggは任意の型の配列を作成する）
	, array_agg(product_id) over(order by score desc
								rows between unbounded preceding and current row)
							as cum_agg
	-- ランキングの1つ前から1つ後までの範囲を対象に商品IDを集約（array_aggは任意の型の配列を作成する）
	, array_agg(product_id) over(order by score desc
								rows between 1 preceding and 1 following)
							as local_agg
from popular_products
where category = 'action'
order by row; 


-- 3.3.2.4 WINDOW関数でPARTITION BYとORDER BYを組み合わせて使用する
select 
	category
	, product_id
	, score
	-- カテゴリごとにスコア順に一意なランキングを付与する
	, row_number() over(partition by category order by score desc) as row
from popular_products 
order by category, row
;


-- 3.3.2.5 各カテゴリごとのランキング上位2件までの商品を抽出する
-- WINDOW関数の結果をWHERE句で使用できないのでサブクエリを利用
select 
	*
from 
	(select 
		category
		, product_id
		, score
		-- カテゴリごとにスコア順に一意なランキングを付与する
		, row_number() over(partition by category order by score desc) as rank
	from popular_products 
	) as popular_products_with_rank
where rank <= 2
	;	


-- 3.3.2.6 distictを利用して各カテゴリの最上位商品のみを抜き出す
select distinct
	category
	, first_value(product_id) over(partition by category order by score desc
		rows between unbounded preceding and unbounded following)
from popular_products ;


-- 3.3.3
DROP TABLE IF EXISTS daily_kpi;
CREATE TABLE daily_kpi (
    dt        varchar(255)
  , indicator varchar(255)
  , val       integer
);

INSERT INTO daily_kpi
VALUES
    ('2017-01-01', 'impressions', 1800)
  , ('2017-01-01', 'sessions'   ,  500)
  , ('2017-01-01', 'users'      ,  200)
  , ('2017-01-02', 'impressions', 2000)
  , ('2017-01-02', 'sessions'   ,  700)
  , ('2017-01-02', 'users'      ,  250)
;

DROP TABLE IF EXISTS purchase_detail_log;
CREATE TABLE purchase_detail_log (
    purchase_id integer
  , product_id  varchar(255)
  , price       integer
);

INSERT INTO purchase_detail_log
VALUES
    (100001, 'A001', 300)
  , (100001, 'A002', 400)
  , (100001, 'A003', 200)
  , (100002, 'D001', 500)
  , (100002, 'D002', 300)
  , (100003, 'A001', 300)
;
select * from daily_kpi;
select * from purchase_detail_log ;


-- 3.3.3.1 行を列に変換する
-- 行を軸にして横持ちデータに変換する
-- このデータではcase式の条件式がtrueになるレコードが1件ずつしかないのでMAX関数を利用する
select 
	dt
	, max(case when indicator = 'impressions' then val end) as impressions
	, max(case when indicator = 'sessions' then val end) as sessions
	, max(case when indicator = 'users' then val end) as users
from daily_kpi
group by dt
order by dt;


-- 3.3.3.2 行を列に変換したときに、列数がばらつき可能性がある場合は、一つの文字列として集約させる
-- string_agg(カラム, 連結文字)で1つの文字列にする
select 
	purchase_id
	-- 商品IDをカンマ区切りの１つの文字列に変換する
	, string_agg(product_id, ',') as product_ids
	, sum(price) as amount
from purchase_detail_log 
group by purchase_id
order by purchase_id;


-- 3.3.4 横持ちデータを縦持ちデータに変換する
DROP TABLE IF EXISTS quarterly_sales;
CREATE TABLE quarterly_sales (
    year integer
  , q1   integer
  , q2   integer
  , q3   integer
  , q4   integer
);

INSERT INTO quarterly_sales
VALUES
    (2015, 82000, 83000, 78000, 83000)
  , (2016, 85000, 85000, 80000, 81000)
  , (2017, 92000, 81000, NULL , NULL )
;
select * from quarterly_sales ;


-- 3.3.4.1 連番を持つピボットテーブルを用いて列を行に変換する

-- union allは行結合を行う
select 1 as idx
		union all select 2 as idx
		union all select 3 as idx
		union all select 4 as idx
;

select 
	q.year
	-- Q1からQ4までにラベルを付与する
	, case 
		when p.idx = 1 then 'q1'
		when p.idx = 2 then 'q2'
		when p.idx = 3 then 'q3'
		when p.idx = 4 then 'q4'
	end	as quarter
	-- Q1からQ4までの売上を表示
	, case 
		when p.idx = 1 then q.q1
		when p.idx = 2 then q.q2
		when p.idx = 3 then q.q3
		when p.idx = 4 then q.q4
	end	as sales
from 
	quarterly_sales as q
	cross join -- 1から4までの数字を各データに付与する
	(
		select 1 as idx
		union all select 2 as idx
		union all select 3 as idx
		union all select 4 as idx
	) as p
;

 -- 3.3.4.2 テーブル関数を用いて配列を縦に分解する（UNNEST関数） 
select unnest(array['A001','A002','A003']) as product_id;


-- 3.3.4.3 テーブル関数を用いてカンマ区切りのデータを行に展開する
DROP TABLE IF EXISTS purchase_log;
CREATE TABLE  purchase_log(
    purchase_id integer
  , product_ids  text
);

INSERT INTO purchase_log
VALUES
	(100001, 'A001,A002,A003')
	,(100002, 'D001,D003')
	, (100003, 'A001')
;
select * from purchase_log ;

select 
	purchase_id
	, product_id
from
	purchase_log as p
-- string_to_arrayで一度stirngを配列にして、それを縦型に分解（UNNEST）したものをCORSS JOINする
cross join unnest(string_to_array(product_ids, ',')) as product_id
;


-- regexp_split_to_tableを使用すればもっと簡単にできる
select 
	purchase_id
	-- カンマ区切りの文字列を一度に行に展開する
	, regexp_split_to_table(product_ids, ',') as product_id
from purchase_log ;
	
