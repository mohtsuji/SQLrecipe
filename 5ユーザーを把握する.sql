-- 5.1

DROP TABLE IF EXISTS mst_users;
CREATE TABLE mst_users(
    user_id         varchar(255)
  , sex             varchar(255)
  , birth_date      varchar(255)
  , register_date   varchar(255)
  , register_device varchar(255)
  , withdraw_date   varchar(255)
);
INSERT INTO mst_users
VALUES
    ('U001', 'M', '1977-06-17', '2016-10-01', 'pc' , NULL        )
  , ('U002', 'F', '1953-06-12', '2016-10-01', 'sp' , '2016-10-10')
  , ('U003', 'M', '1965-01-06', '2016-10-01', 'pc' , NULL        )
  , ('U004', 'F', '1954-05-21', '2016-10-05', 'pc' , NULL        )
  , ('U005', 'M', '1987-11-23', '2016-10-05', 'sp' , NULL        )
  , ('U006', 'F', '1950-01-21', '2016-10-10', 'pc' , '2016-10-10')
  , ('U007', 'F', '1950-07-18', '2016-10-10', 'app', NULL        )
  , ('U008', 'F', '2006-12-09', '2016-10-10', 'sp' , NULL        )
  , ('U009', 'M', '2004-10-23', '2016-10-15', 'pc' , NULL        )
  , ('U010', 'F', '1987-03-18', '2016-10-16', 'pc' , NULL        )
;
DROP TABLE IF EXISTS action_log;
CREATE TABLE action_log(
    session  varchar(255)
  , user_id  varchar(255)
  , action   varchar(255)
  , category varchar(255)
  , products varchar(255)
  , amount   integer
  , stamp    varchar(255)
);
INSERT INTO action_log
VALUES
    ('989004ea', 'U001', 'purchase', 'drama' , 'D001,D002', 2000, '2016-11-03 18:10:00')
  , ('989004ea', 'U001', 'view'    , NULL    , NULL       , NULL, '2016-11-03 18:00:00')
  , ('989004ea', 'U001', 'favorite', 'drama' , 'D001'     , NULL, '2016-11-03 18:00:00')
  , ('989004ea', 'U001', 'review'  , 'drama' , 'D001'     , NULL, '2016-11-03 18:00:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D001'     , NULL, '2016-11-03 18:00:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D001'     , NULL, '2016-11-03 18:00:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D001'     , NULL, '2016-11-03 18:00:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D001'     , NULL, '2016-11-03 18:00:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D001'     , NULL, '2016-11-03 18:00:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D002'     , NULL, '2016-11-03 18:01:00')
  , ('989004ea', 'U001', 'add_cart', 'drama' , 'D001,D002', NULL, '2016-11-03 18:02:00')
  , ('989004ea', 'U001', 'purchase', 'drama' , 'D001,D002', 2000, '2016-11-03 18:10:00')
  , ('47db0370', 'U002', 'add_cart', 'drama' , 'D001'     , NULL, '2016-11-03 19:00:00')
  , ('47db0370', 'U002', 'purchase', 'drama' , 'D001'     , 1000, '2016-11-03 20:00:00')
  , ('47db0370', 'U002', 'add_cart', 'drama' , 'D002'     , NULL, '2016-11-03 20:30:00')
  , ('87b5725f', 'U001', 'add_cart', 'action', 'A004'     , NULL, '2016-11-04 12:00:00')
  , ('87b5725f', 'U001', 'add_cart', 'action', 'A005'     , NULL, '2016-11-04 12:00:00')
  , ('87b5725f', 'U001', 'add_cart', 'action', 'A006'     , NULL, '2016-11-04 12:00:00')
  , ('9afaf87c', 'U002', 'purchase', 'drama' , 'D002'     , 1000, '2016-11-04 13:00:00')
  , ('9afaf87c', 'U001', 'purchase', 'action', 'A005,A006', 1000, '2016-11-04 15:00:00')
;
select * from mst_users mu ;
select * from action_log al ;


-- 5.1.1.1 アクション数と割合を計算する
with
status as (
	select 
		-- ログ全体のユニークユーザ数を求める
		count(distinct session) as total_uu
	from action_log al
)
select
	al.action
	-- アクションUU
	, count(distinct al.session) as action_uu
	-- アクション数
	, count(1) as action_count
	-- 全体UU
	, s.total_uu
	-- 利用率：アクションUU/全体UU
	, 100.0 * count(distinct al.session) / s.total_uu as usage_rate
	-- 一人あたりアクション数：アクション数/アクションUU
	, 1.0 * count(1) / count(distinct al.session) as count_per_user
from action_log al 
-- ログ全体のユニークユザー数を結合する
cross join status as s 
group by al.action, s.total_uu
	;

-- 5.1.1.2 ログイン状態を判別するクエリ
select 
	session
	, user_id
	-- user_idがNULLまたは空文字でない場合はlogin判定(<>は!=と同じ意味)
	, case when coalesce(user_id, '') <> '' then 'login' else 'guest' end 
		as login_status
from action_log al 
;

-- 5.1.1.3 ログイン状態によるアクション数の集計クエリ
with
action_log_with_status as (
select 
	session
	, user_id
	, action
	-- user_idがNULLまたは空文字でない場合はlogin判定(<>は!=と同じ意味)
	, case when coalesce(user_id, '') <> '' then 'login' else 'guest' end 
		as login_status
from action_log al 
)
select
	coalesce (action, 'all') as action 
	, coalesce (login_status, 'all') as login_status
	, count(distinct session) as action_uu
	, count(1) as action_count
from action_log_with_status
group by 
	rollup(action, login_status) -- actionとlogin_statusの全ての組み合わせを計上する
;

-- 5.1.1.4 会員状態を判別するクエリ
DROP TABLE IF EXISTS mst_users;
CREATE TABLE mst_users(
    user_id         varchar(255)
  , sex             varchar(255)
  , birth_date      varchar(255)
  , register_date   varchar(255)
  , register_device varchar(255)
  , withdraw_date   varchar(255)
);
INSERT INTO mst_users
VALUES
    ('U001', 'M', '1977-06-17', '2016-10-01', 'pc' , NULL        )
  , ('U002', 'F', '1953-06-12', '2016-10-01', 'sp' , '2016-10-10')
  , ('U003', 'M', '1965-01-06', '2016-10-01', 'pc' , NULL        )
  , ('U004', 'F', '1954-05-21', '2016-10-05', 'pc' , NULL        )
  , ('U005', 'M', '1987-11-23', '2016-10-05', 'sp' , NULL        )
  , ('U006', 'F', '1950-01-21', '2016-10-10', 'pc' , '2016-10-10')
  , ('U007', 'F', '1950-07-18', '2016-10-10', 'app', NULL        )
  , ('U008', 'F', '2006-12-09', '2016-10-10', 'sp' , NULL        )
  , ('U009', 'M', '2004-10-23', '2016-10-15', 'pc' , NULL        )
  , ('U010', 'F', '1987-03-18', '2016-10-16', 'pc' , NULL        )
;
select * from mst_users mu ;

with
mst_users_with_int_birth_date as (
	select 
		*
		-- 特定の日付の整数表現
		, 20170101 as int_specific_date
		--文字列の生年月日を、日付の整数表現に変換
		, cast(replace(substring(birth_date, 1, 10), '-', '') as integer) as int_birth_date
	from mst_users mu 
)
, mst_users_with_age as (
	select
		*,
		-- 特定の日付における年齢
		floor((int_specific_date - int_birth_date) / 10000) as age
	from mst_users_with_int_birth_date
)
select
	user_id, sex, birth_date, age
from mst_users_with_age
;


-- 5.1.2.2 5.1.2.3性別の年齢から区分を作成し、人数を把握する
with
mst_users_with_int_birth_date as (
	select 
		*
		-- 特定の日付の整数表現
		, 20170101 as int_specific_date
		--文字列の生年月日を、日付の整数表現に変換
		, cast(replace(substring(birth_date, 1, 10), '-', '') as integer) as int_birth_date
	from mst_users mu 
)
, mst_users_with_age as (
	select
		*,
		-- 特定の日付における年齢
		floor((int_specific_date - int_birth_date) / 10000) as age
	from mst_users_with_int_birth_date
)
, mst_users_category as (
	select
		user_id
		, sex
		, birth_date
		, age
		, concat(
			case 
				when 20 <= age then sex 
				else ''
			end
			, case 
				when age between 4 and 12 then 'C'
				when age between 13 and 19 then 'T'
				when age between 20 and 34 then '1'
				when age between 35 and 49 then '2'
				when age >= 50 then '3'
			end	
			) as category
	from mst_users_with_age
)
select
	category
	, count(1) as user_count
from mst_users_category
group by category
	;


-- 5.1.3.1 年齢別区分とカテゴリを集計する
with
mst_users_with_int_birth_date as (
	select 
		*
		-- 特定の日付の整数表現
		, 20170101 as int_specific_date
		--文字列の生年月日を、日付の整数表現に変換
		, cast(replace(substring(birth_date, 1, 10), '-', '') as integer) as int_birth_date
	from mst_users mu 
)
, mst_users_with_age as (
	select
		*,
		-- 特定の日付における年齢
		floor((int_specific_date - int_birth_date) / 10000) as age
	from mst_users_with_int_birth_date
)
, mst_users_category as (
	select
		user_id
		, sex
		, birth_date
		, age
		, concat(
			case 
				when 20 <= age then sex 
				else ''
			end
			, case 
				when age between 4 and 12 then 'C'
				when age between 13 and 19 then 'T'
				when age between 20 and 34 then '1'
				when age between 35 and 49 then '2'
				when age >= 50 then '3'
			end	
			) as category
	from mst_users_with_age
)
select
	p.category as product_category
	, u.category as user_category 
	, count(*) as purchase_count
from action_log as p 
inner join mst_users_category as u
on p.user_id = u.user_id
where -- 購入ログに絞り込む
	action = 'purchase'
group by 
	p.category, u.category
;


-- 5.1.4 ユーザーの訪問頻度を集計する
with
action_log_with_dt as (
	select
		*
		-- たいむすたんぷから日付を抽出
		, substring(stamp, 1, 10) as dt
	from action_log al 
)
, action_day_count_per_users as (
	select
		user_id
		, count(distinct dt) as action_day_count
	from action_log_with_dt
	where -- 2016年11月1日〜11月7日の1週間分を対象とする
		dt between '2016-11-01' and '2016-11-07'
	group by user_id
)
select 
	action_day_count
	, count(distinct user_id) as user_count
from action_day_count_per_users
group by action_day_count
	;


-- 5.1.4.1 構成比と構成比累計を計算する
with
action_log_with_dt as (
	select
		*
		-- たいむすたんぷから日付を抽出
		, substring(stamp, 1, 10) as dt
	from action_log al 
)
, action_day_count_per_users as (
	select
		user_id
		, count(distinct dt) as action_day_count
	from action_log_with_dt
	where -- 2016年11月1日〜11月7日の1週間分を対象とする
		dt between '2016-11-01' and '2016-11-07'
	group by user_id
)
select 
	action_day_count
	, count(distinct user_id) as user_count
	-- 構成比
	, 100.0
		* count(distinct user_id)
		/ sum(count(distinct user_id)) over()
		as composition_ratio
	-- 構成比累計
	, 100.0 
		* sum(count(distinct user_id)) 
			over(order by action_day_count rows between unbounded preceding and current row)
		/ sum(count(distinct user_id)) over()
		as cumulative_ratio
from action_day_count_per_users
group by action_day_count
;

-- 5.1.5 ベン図でユーザーのアクションを集計する

-- 5.1.5.1 ユーザーごとのアクションフラグを集計する
select 
	user_id 
	, sign(sum(case when action = 'purchase' then 1 else 0 end)) as has_purchase
	, sign(sum(case when action = 'review' then 1 else 0 end)) as has_review
	, sign(sum(case when action = 'favorite' then 1 else 0 end)) as has_favorite
from action_log al 
group by user_id
;


-- 5.1.5.2 すべてのアクションの組み合わせについてユーザー数をカウントする
with
user_action_log as (
	select 
		user_id 
		, sign(sum(case when action = 'purchase' then 1 else 0 end)) as has_purchase
		, sign(sum(case when action = 'review' then 1 else 0 end)) as has_review
		, sign(sum(case when action = 'favorite' then 1 else 0 end)) as has_favorite
	from action_log al 
	group by user_id
)
select 
	-- cube関数を用いて、アクションの全ての組み合わせを求める
	has_purchase
	, has_review
	, has_favorite
	, count(1) as users
from user_action_log
group by
	-- 空（NULL)になっているレコードは、そのカラムの値を問わないという意味
	cube(has_purchase, has_review, has_favorite)
	;


-- 5.1.5.5 5.1.5.2の結果を見やすく整形する
with
user_action_log as (
	select 
		user_id 
		, sign(sum(case when action = 'purchase' then 1 else 0 end)) as has_purchase
		, sign(sum(case when action = 'review' then 1 else 0 end)) as has_review
		, sign(sum(case when action = 'favorite' then 1 else 0 end)) as has_favorite
	from action_log al 
	group by user_id
)
, action_venn_diagram as (
	select 
		-- cube関数を用いて、アクションの全ての組み合わせを求める
		has_purchase
		, has_review
		, has_favorite
		, count(1) as users
	from user_action_log
	group by
		-- 空（NULL)になっているレコードは、そのカラムの値を問わないという意味
		cube(has_purchase, has_review, has_favorite)
)
select 
	-- 0, 1のふらぐをもじれつにせいけい
	case has_purchase
		when 1 then 'purchase' when 0 then 'not purchase' else 'any'
	end as has_purchase
	, case has_review
		when 1 then 'review' when 0 then 'not review' else 'any'
	end as has_review
	, case has_favorite
		when 1 then 'favorite' when 0 then 'not favorite' else 'any'
	end as has_favorite
	, users
	-- 前ユニークユーザ数に対する割合を求める
	, 100.0 * users
		/ nullif(
			-- すべてのアクションについてNULLであるユーザ数が、全ユニークユーザー数となるので、
			-- その行のユーザ数をWINDOW関数で求める
			sum(case when has_purchase is null
				and has_review is null 
				and has_favorite is null
				then users else 0 end) over()
			, 0)
		as ratio
from action_venn_diagram
order by has_purchase, has_review, has_favorite
		;

-- 5.1.6 デシル分析でユーザーを10段階のグループに分ける

-- 5.1.6.1 購入額の多い順にユーザーグループを10分割する
with
user_purchase_amount as (
	select 
		user_id
		, sum(amount) as purchase_amount
	from action_log al 
	where action = 'purchase'
	group by user_id
)
select 
	user_id
	, purchase_amount
	-- ntile関数：指定した数のグループ数に、レコード数が均等になるように分けてくれる
	, ntile(10) over(order by purchase_amount desc) as decile
from user_purchase_amount
	;

-- 5.1.6.2 10分割したデシルごとの集約を行う
with
user_purchase_amount as (
	select 
		user_id
		, sum(amount) as purchase_amount
	from action_log al 
	where action = 'purchase'
	group by user_id
)
, decile_with_purchase_amount as (
	select 
		user_id
		, purchase_amount
		-- ntile関数：指定した数のグループ数に、レコード数が均等になるように分けてくれる
		, ntile(10) over(order by purchase_amount desc) as decile
	from user_purchase_amount
)
select
	decile
	, sum(purchase_amount) as amount 
	, avg(purchase_amount) as avg_amount
	, sum(sum(purchase_amount)) over(order by decile) as cumulative_amount
	, sum(sum(purchase_amount)) over() as total_amount
from decile_with_purchase_amount
group by decile
	;

-- 5.1.6.3 購入額の多いdecile順に構成比と構成比累計を計算する
with
user_purchase_amount as (
	select 
		user_id
		, sum(amount) as purchase_amount
	from action_log al 
	where action = 'purchase'
	group by user_id
)
, decile_with_purchase_amount as (
	select 
		user_id
		, purchase_amount
		-- ntile関数：指定した数のグループ数に、レコード数が均等になるように分けてくれる
		, ntile(10) over(order by purchase_amount desc) as decile
	from user_purchase_amount
)
, decile_amount as (
	select
		decile
		, sum(purchase_amount) as amount 
		, avg(purchase_amount) as avg_amount
		, sum(sum(purchase_amount)) over(order by decile) as cumulative_amount
		, sum(sum(purchase_amount)) over() as total_amount
	from decile_with_purchase_amount
	group by decile
)
select 
	decile
	, amount 
	, avg_amount
	, 100.0 * amount / total_amount as total_ratio
	, 100.0 * cumulative_amount / total_amount as cumulative_ratio
from decile_amount
	;

-- 5.1.7.1 ユーザーごとにRFMを集計する
-- R = Recency：最新
-- F = Frequency：頻度
-- M = Monetary：合計金額
with
purchase_log as (
	select 
		user_id 
		, amount
		-- タイムスタンプから日付を抽出
		, substring(stamp, 1, 10) as dt
	from action_log al 
	where action = 'purchase'
)
select 
	user_id 
	, max(dt) as revent_date
	, current_date - max(dt::date) as recency
	, count(dt) as frequency
	, sum(amount) as monetary
from purchase_log
group by user_id
	;

-- 5.1.7.2 ユーザーごとのRFMランクを計算する & 5.1.7.3各グループの人数を確認する
with
purchase_log as (
	select 
		user_id 
		, amount
		-- タイムスタンプから日付を抽出
		, substring(stamp, 1, 10) as dt
	from action_log al 
	where action = 'purchase'
)
, user_rfm as (
	select 
		user_id 
		, max(dt) as recent_date
		, current_date - max(dt::date) as recency
		, count(dt) as frequency
		, sum(amount) as monetary
	from purchase_log
	group by user_id
)
, rfm_rank as (
	select 
		user_id
		, recent_date
		, recency
		, frequency
		, monetary
		, case 
			when recency < 14 then 5
			when recency < 28 then 4
			when recency < 60 then 3
			when recency < 90 then 2
			else 1
		end as r
		, case 
			when 20 <= frequency then 5
			when 10 <= frequency then 4
			when 5 <= frequency then 3
			when 2 <= frequency then 2
			when 1 = frequency then 1
		end as f
		, case 
			when 300000 <= monetary then 5
			when 100000 <= monetary then 4
			when 30000 <= monetary then 3
			when 5000 <= monetary then 2
			else 1
		end as m
	from user_rfm
)
, rfm_index as (
	select
		-- 1-5までの連番テーブルを作成する
		generate_series(1, 5) as rfm_index
)
, rfm_flag as (
	select
		*
		, case when m.rfm_index = r.r then 1 else 0 end as r_flag
		, case when m.rfm_index = r.f then 1 else 0 end as f_flag
		, case when m.rfm_index = r.m then 1 else 0 end as m_flag
	from rfm_index m
	cross join rfm_rank r
)
select
	rfm_index
	, sum(r_flag) as r
	, sum(f_flag) as f
	, sum(m_flag) as m
from rfm_flag
group by rfm_index
		;

-- 5.1.7.4 総合ランクを算出する
with
purchase_log as (
	select 
		user_id 
		, amount
		-- タイムスタンプから日付を抽出
		, substring(stamp, 1, 10) as dt
	from action_log al 
	where action = 'purchase'
)
, user_rfm as (
	select 
		user_id 
		, max(dt) as recent_date
		, current_date - max(dt::date) as recency
		, count(dt) as frequency
		, sum(amount) as monetary
	from purchase_log
	group by user_id
)
, rfm_rank as (
	select 
		user_id
		, recent_date
		, recency
		, frequency
		, monetary
		, case 
			when recency < 14 then 5
			when recency < 28 then 4
			when recency < 60 then 3
			when recency < 90 then 2
			else 1
		end as r
		, case 
			when 20 <= frequency then 5
			when 10 <= frequency then 4
			when 5 <= frequency then 3
			when 2 <= frequency then 2
			when 1 = frequency then 1
		end as f
		, case 
			when 300000 <= monetary then 5
			when 100000 <= monetary then 4
			when 30000 <= monetary then 3
			when 5000 <= monetary then 2
			else 1
		end as m
	from user_rfm
)
select
	r + f + m as total_rank
	, r, f, m
	, count(user_id)
from rfm_rank
group by r, f, m
order by total_rank desc, r desc, f desc, m desc
;


-- 5.1.6.7 RとFの2次元でユーザー数を集計する
with
purchase_log as (
	select 
		user_id 
		, amount
		-- タイムスタンプから日付を抽出
		, substring(stamp, 1, 10) as dt
	from action_log al 
	where action = 'purchase'
)
, user_rfm as (
	select 
		user_id 
		, max(dt) as recent_date
		, current_date - max(dt::date) as recency
		, count(dt) as frequency
		, sum(amount) as monetary
	from purchase_log
	group by user_id
)
, rfm_rank as (
	select 
		user_id
		, recent_date
		, recency
		, frequency
		, monetary
		, case 
			when recency < 14 then 5
			when recency < 28 then 4
			when recency < 60 then 3
			when recency < 90 then 2
			else 1
		end as r
		, case 
			when 20 <= frequency then 5
			when 10 <= frequency then 4
			when 5 <= frequency then 3
			when 2 <= frequency then 2
			when 1 = frequency then 1
		end as f
		, case 
			when 300000 <= monetary then 5
			when 100000 <= monetary then 4
			when 30000 <= monetary then 3
			when 5000 <= monetary then 2
			else 1
		end as m
	from user_rfm
)
select
	concat('r_', r) as r_rank
	, count(case when f = 5 then 1 end) as f_5
	, count(case when f = 4 then 1 end) as f_4
	, count(case when f = 3 then 1 end) as f_3
	, count(case when f = 2 then 1 end) as f_2
	, count(case when f = 1 then 1 end) as f_1
from rfm_rank
group by r
;

-- 5.2 ユーザー全体の時系列による状態変化を見つける
DROP TABLE IF EXISTS mst_users;
CREATE TABLE mst_users(
    user_id         varchar(255)
  , sex             varchar(255)
  , birth_date      varchar(255)
  , register_date   varchar(255)
  , register_device varchar(255)
  , withdraw_date   varchar(255)
);
INSERT INTO mst_users
VALUES
    ('U001', 'M', '1977-06-17', '2016-10-01', 'pc' , NULL        )
  , ('U002', 'F', '1953-06-12', '2016-10-01', 'sp' , '2016-10-10')
  , ('U003', 'M', '1965-01-06', '2016-10-01', 'pc' , NULL        )
  , ('U004', 'F', '1954-05-21', '2016-10-05', 'pc' , NULL        )
  , ('U005', 'M', '1987-11-23', '2016-10-05', 'sp' , NULL        )
  , ('U006', 'F', '1950-01-21', '2016-10-10', 'pc' , '2016-10-10')
  , ('U007', 'F', '1950-07-18', '2016-10-10', 'app', NULL        )
  , ('U008', 'F', '2006-12-09', '2016-10-10', 'sp' , NULL        )
  , ('U009', 'M', '2004-10-23', '2016-10-15', 'pc' , NULL        )
  , ('U010', 'F', '1987-03-18', '2016-10-16', 'pc' , NULL        )
  , ('U011', 'F', '1993-10-21', '2016-10-18', 'pc' , NULL        )
  , ('U012', 'M', '1993-12-22', '2016-10-18', 'app', NULL        )
  , ('U013', 'M', '1988-02-09', '2016-10-20', 'app', NULL        )
  , ('U014', 'F', '1994-04-07', '2016-10-25', 'sp' , NULL        )
  , ('U015', 'F', '1994-03-01', '2016-11-01', 'app', NULL        )
  , ('U016', 'F', '1991-09-02', '2016-11-01', 'pc' , NULL        )
  , ('U017', 'F', '1972-05-21', '2016-11-01', 'app', NULL        )
  , ('U018', 'M', '2009-10-12', '2016-11-01', 'app', NULL        )
  , ('U019', 'M', '1957-05-18', '2016-11-01', 'pc' , NULL        )
  , ('U020', 'F', '1954-04-17', '2016-11-03', 'app', NULL        )
  , ('U021', 'M', '2002-08-14', '2016-11-03', 'sp' , NULL        )
  , ('U022', 'M', '1979-12-09', '2016-11-03', 'app', NULL        )
  , ('U023', 'M', '1992-01-12', '2016-11-04', 'sp' , NULL        )
  , ('U024', 'F', '1962-10-16', '2016-11-05', 'app', NULL        )
  , ('U025', 'F', '1958-06-26', '2016-11-05', 'app', NULL        )
  , ('U026', 'M', '1969-02-21', '2016-11-10', 'sp' , NULL        )
  , ('U027', 'F', '2001-07-10', '2016-11-10', 'pc' , NULL        )
  , ('U028', 'M', '1976-05-26', '2016-11-15', 'app', NULL        )
  , ('U029', 'M', '1964-04-06', '2016-11-28', 'pc' , NULL        )
  , ('U030', 'M', '1959-10-07', '2016-11-28', 'sp' , NULL        )
;
select * from mst_users;

-- 5.2.1.1 日時で登録者数の推移を集計する
select 
	register_date 
	, count(distinct user_id) as register_count
from mst_users
group by register_date
order by register_date
;


-- 5.2.1.2 各月の登録数と先月比を計算する
with
mst_users_with_year_month as (
	select 
		*
		, substring(register_date, 1, 7) as year_month
	from mst_users mu 
)
select
	year_month
	, count(distinct user_id) as register_count
	-- lag関数で1つ前のレコード（先月）の値を取得
	, lag(count(distinct user_id)) over(order by year_month) as last_month_count
	, 1.0
		* count(distinct user_id)
		/ lag(count(distinct user_id)) over(order by year_month)
		as month_over_month_ratio
from mst_users_with_year_month
group by year_month
order by year_month
;

-- 5.2.1.3 デバイスごとの登録数を計算する
with
mst_users_with_year_month as (
	select 
		*
		, substring(register_date, 1, 7) as year_month
	from mst_users mu 
)
select
	year_month
	, count(distinct user_id) as register_count
	, count(distinct case when register_device = 'pc' then user_id end) as register_pc
	, count(distinct case when register_device = 'sp' then user_id end) as register_sp
	, count(distinct case when register_device = 'app' then user_id end) as register_app
from mst_users_with_year_month
group by year_month
;


-- 5.2.2 ユーザーの継続率を把握するクエリ
with
action_log_with_mst_users as (
	select 
		u.user_id
		, u.register_date 
		-- アクションの日付と、ログ全体の最新日付を日付型として取得
		, cast(a.stamp as date) as action_date
		, max(cast(a.stamp as date)) over() as latest_date
		-- 登録日の一日後の日付を計算する
		, cast(u.register_date::date + '1 day'::interval as date) as next_day_1
	from mst_users u
	left join action_log a 
		on u.user_id = a.user_id
	order by register_date
)
, user_action_flag as (
	select 
		user_id 
		, register_date 
		-- 4.登録日の1日後にアクションしたかどうかを0,1のフラグで表す
		, sign(
			-- 3.登録日の1日後にアクションした回数をユーザーごとに合計する
			sum(
				-- 1.登録日の1日後が、ログの最新日付以前に含まれるか確認
				case when next_day_1 <= latest_date then
					-- 2.登録日の1日後の日付にアクションしている場合は1, それ以外は0を返す
					case when next_day_1 = action_date then 1 else 0 end
				end
			)
		) as next_1_day_action
	from action_log_with_mst_users
	group by user_id, register_date
)
select 
	register_date
	-- 翌日継続率を計算する
	, avg(100.0 * next_1_day_action) as repeat_rate_1_day
from user_action_flag
group by register_date
order by register_date
;


-- 5.2.2.4 継続率の指標を管理するマスタテーブルを作成する
with
repeat_interval(index_name, interval_date) as (
	values
	('01 day repeat', 1)
	, ('02 day repeat', 2)
	, ('03 day repeat', 3)
	, ('04 day repeat', 4)
	, ('05 day repeat', 5)
	, ('06 day repeat', 6)
	, ('07 day repeat', 7)
)
, action_log_with_index_date as (
	select
		u.user_id 
		, u.register_date 
		-- アクションの日付と、ログ全体の最新日付をdate型で取得
		, cast(a.stamp as date) as action_date
		, max(cast(a.stamp as date)) over() as latest_date
		-- とうろくびのn日後の日付を計算する
		, r.index_name
		, cast(cast(u.register_date as date) + interval '1 day' * r.interval_date as date)
			as index_date
	from mst_users u
	left join action_log a 
		on u.user_id = a.user_id
	cross join repeat_interval r
)
, user_action_flag as (
	select
		user_id 
		, register_date 
		, index_name
		-- 4.登録日の1日後にアクションしたかどうかを0,1のフラグで表す
		, sign(
			-- 3.登録日の1日後にアクションした回数をユーザーごとに合計する
			sum(
				-- 1.登録日の1日後が、ログの最新日付以前に含まれるか確認
				case when index_date <= latest_date then
					-- 2.登録日の1日後の日付にアクションしている場合は1, それ以外は0を返す
					case when index_date = action_date then 1 else 0 end
				end
			)
		) as index_date_action
	from action_log_with_index_date
	group by user_id, register_date, index_name, index_date
)
select 
	register_date 
	, index_name
	, avg(100.0 * index_date_action) as repeat_rate
from user_action_flag
group by register_date, index_name
order by register_date, index_name
	;


-- 5.2.2.6 定着率を算出する
with
repeat_interval(index_name, interval_begin_date, interval_end_date) as (
	values
	('07 day retension', 1, 7)
	, ('14 day retension', 8, 14)
	, ('21 day retension', 15, 21)
	, ('28 day retension', 22, 28)
)
, action_log_with_index_date as (
	select
		u.user_id 
		, u.register_date 
		, index_name
		-- アクションの日付と、ログ全体の最新日付をdate型で取得
		, cast(a.stamp as date) as action_date
		, max(cast(a.stamp as date)) over() as latest_date
		-- 指標の対象期間の開始日と終了日を計算する
		, cast(u.register_date::date + '1 day'::interval * r.interval_begin_date as date)
			as index_begin_date
		, cast(u.register_date::date + '1 day'::interval * r.interval_end_date as date)
			as index_end_date
	from mst_users u
	left join action_log a
		on u.user_id = a.user_id 
	cross join repeat_interval r
)
, user_action_flag as (
	select
		user_id 
		, register_date 
		, index_name
		-- 4.指標の対象期間にアクションしたかどうかを0,1のフラグで表す
		, sign(
			-- 3.指標の対象期間にアクションした回数をユーザーごとに合計する
			sum(
				-- 1.指標の対象期間の終了日が、ログの最新日付以前に含まれるか確認
				case when index_end_date <= latest_date then
					-- 2.指標の対象期間にアクションしている場合は1, それ以外は0を返す
					case when action_date between index_begin_date and index_end_date then 1 else 0 end
				end
			)
		) as index_date_action
	from action_log_with_index_date
	group by user_id, register_date, index_name, index_begin_date, index_end_date
)
select 
	register_date 
	, index_name
	, avg(100.0 * index_date_action) as repeat_rate
from user_action_flag
group by register_date, index_name
order by register_date, index_name
	;


-- 5.2.3 翌日の継続と定着に影響する（登録日当日の）アクションを集計する
with
repeat_interval(index_name, interval_begin_date, interval_end_date) as (
	values ('01 day repeat', 1, 1)
)
, action_log_with_index_date as (
	select
		u.user_id 
		, u.register_date 
		, index_name
		-- アクションの日付と、ログ全体の最新日付をdate型で取得
		, cast(a.stamp as date) as action_date
		, max(cast(a.stamp as date)) over() as latest_date
		-- 指標の対象期間の開始日と終了日を計算する
		, cast(u.register_date::date + '1 day'::interval * r.interval_begin_date as date)
			as index_begin_date
		, cast(u.register_date::date + '1 day'::interval * r.interval_end_date as date)
			as index_end_date
	from mst_users u
	left join action_log a
		on u.user_id = a.user_id 
	cross join repeat_interval r
)
, user_action_flag as (
	select
		user_id 
		, register_date 
		, index_name
		-- 4.指標の対象期間にアクションしたかどうかを0,1のフラグで表す
		, sign(
			-- 3.指標の対象期間にアクションした回数をユーザーごとに合計する
			sum(
				-- 1.指標の対象期間の終了日が、ログの最新日付以前に含まれるか確認
				case when index_end_date <= latest_date then
					-- 2.指標の対象期間にアクションしている場合は1, それ以外は0を返す
					case when action_date between index_begin_date and index_end_date then 1 else 0 end
				end
			)
		) as index_date_action
	from action_log_with_index_date
	group by user_id, register_date, index_name, index_begin_date, index_end_date
)
, mst_actions as (
	select 'view' as action
	union all select 'comment' as action
	union all select 'follow' as action
) -- すべてのユーザとアクションの組み合わせを作成
, mst_user_actions as (
	select 
		u.user_id 
		, u.register_date 
		, a.action
	from mst_users as u
	cross join mst_actions as a
) -- 各ユーザーのアクションログを0, 1フラグで表現する
, register_action_flag as (
	select distinct
		m.user_id
		, m.register_date
		, m.action
		, case 
			when a.action is not null then 1
			else 0
		end as do_action
		, index_name
		, index_date_action
	from mst_user_actions as m
	left join action_log a
		on m.user_id = a.user_id 
		and cast(m.register_date as date) = cast(a.stamp as date)
		and m.action = a.action
	left join user_action_flag as f 
		on m.user_id = f.user_id
	where f.index_date_action is not null -- nullの人は、この日登録したばかりの人なので除外
)
select 
	action 
	, count(1) as users
	, avg(100.0 * do_action) as usage_rate
	, index_name
	, avg(case do_action when 1 then 100.0 * index_date_action end) as idx_rate
	, avg(case do_action when 0 then 100.0 * index_date_action end) as idx_rate
from register_action_flag
group by index_name, action 
order by index_name, action
	;


-- 5.2.6 ユーザーの残存率を集計する
with
mst_intervals as (
	-- 12ヶ月分の連番を作成する
	select generate_series(1, 12) as interval_month
)
, mst_users_with_index_month as (
	select 
		u.user_id 
		, u.register_date 
		-- nヶ月後の日付、登録月、登録月nヶ月後の月を計算
		, cast(u.register_date::date + i.interval_month * '1 month'::interval as date)
			as index_date
		, substring(u.register_date, 1, 7) as register_month
		, substring(cast(
			u.register_date::date + i.interval_month * '1 month'::interval
			as text), 1, 7) as index_month
	from mst_users as u
	cross join mst_intervals as i
) -- アクションログのログ日付を付き表示に変更する
, action_log_in_month as (
	select distinct 
		user_id 
		, substring(stamp, 1, 7) as action_month
	from action_log al 
)
select
	-- ユーザーマスタとアクションログを結合し、月ごとに残存率を集計する
	u.register_month
	, u.index_month
	-- action monthがNULLでない（アクションを行った）ユーザをカウントする
	-- left joinしているのでactionしていなければNULLになっているはず
	, sum(case when a.action_month is not null then 1 else 0 end) as users
	, avg(case when a.action_month is not null then 100.0 else 0.0 end)
		as retention_rate
from mst_users_with_index_month as u
left join action_log_in_month as a
	on u.user_id = a.user_id
	and u.index_month = a.action_month
group by u.register_month, u.index_month
order by u.register_month, u.index_month
	;


-- 5.2.7 訪問頻度からユーザーの属性を定義し集計する
with
t_action_log(user_id, register_date, stamp) as (
	values
	('1', '2016-10-01', '2016-11-01')
	, ('1', '2016-10-01', '2016-10-01')
) 
, monthly_user_action as (
	select distinct
		-- 月ごとにユーザーアクションを集約
		user_id 
		, substring(register_date, 1, 7) as register_month
		, substring(stamp, 1, 7) as action_month
		, substring(cast(stamp::date - interval '1 month' as text), 1, 7) as action_month_prev
	from t_action_log
)
, monthly_user_with_type as (
	select 
		-- 月別のユーザー分類テーブル
		action_month
		, register_month
		, user_id 
		, case 
			-- 登録月がアクションした月に一致する場合は新規ユーザー
			when register_month = action_month then 'new_user'
			-- 前月のアクションが存在する場合はリピートユーザー
			when action_month_prev = 
				lag(action_month) over(partition by user_id order by action_month)
				then 'repeat_user'
			-- 上記以外はカムバックユーザー
			else 'come_back_user'
		end as c
		, action_month_prev	
	from monthly_user_action
)
select
	action_month
	-- 当月のMAU（ユーザーの分類）
	, count(user_id) as mau
	, count(case c when 'new_user' then 1 end) as new_users
	, count(case c when 'repeat_user' then 1 end) as repeat_users
	, count(case c when 'come_back_user' then 1 end) as come_back_users
from monthly_user_with_type
group by action_month
order by action_month
;


-- 5.2.7.2 リピートユーザーを細分化して集計する
with
t_action_log(user_id, register_date, stamp) as (
	values
	('1', '2016-10-01', '2016-11-01')
	, ('1', '2016-10-01', '2016-10-01')
) 
, monthly_user_action as (
	select distinct
		-- 月ごとにユーザーアクションを集約
		user_id 
		, substring(register_date, 1, 7) as register_month
		, substring(stamp, 1, 7) as action_month
		, substring(cast(stamp::date - interval '1 month' as text), 1, 7) as action_month_prev
	from t_action_log
)
, monthly_user_with_type as (
	select 
		-- 月別のユーザー分類テーブル
		action_month
		, register_month
		, user_id 
		, case 
			-- 登録月がアクションした月に一致する場合は新規ユーザー
			when register_month = action_month then 'new_user'
			-- 前月のアクションが存在する場合はリピートユーザー
			when action_month_prev = 
				lag(action_month) over(partition by user_id order by action_month)
				then 'repeat_user'
			-- 上記以外はカムバックユーザー
			else 'come_back_user'
		end as c
		, action_month_prev	
	from monthly_user_action
)
, monthly_users as (
	select
		m1.action_month
		-- 当月のMAU（ユーザーの分類）
		, count(m1.user_id) as mau
		, count(case m1.c when 'new_user' then 1 end) as new_users
		, count(case m1.c when 'repeat_user' then 1 end) as repeat_users
		, count(case m1.c when 'come_back_user' then 1 end) as come_back_users
		-- 前月と当月から細分化したユーザー分類
		, count(case when m1.c = 'repeat_user' and m0.c = 'new_user' then 1 end)
			as new_repeat_users
		, count(case when m1.c = 'repeat_user' and m0.c = 'repeat_user' then 1 end)
			as continuous_repeat_users
		, count(case when m1.c = 'repeat_user' and m0.c = 'come_back_user' then 1 end)
			as come_back_repeat_users
	from -- m1: 当月のユーザー分類テーブル
		monthly_user_with_type as m1 
	left join -- m0: 前月のユーザー分類テーブル
		monthly_user_with_type as m0
		on m1.user_id = m0.user_id
		and m1.action_month_prev = m0.action_month
	group by m1.action_month
)
select 
	*
	-- 前月の新規ユーザーのうち、当月が新規リピートユーザであるユーザーの割合
	, 100.0 * new_repeat_users
		/ nullif(lag(new_users) over(order by action_month), 0) -- 0除算を避けるために0はNULLに変換している 
		as priv_new_repeat_ratio
	-- 前月のリピートユーザーのうち、当月が継続リピートユーザーであるユーザーの割合
	, 100.0 * continuous_repeat_users
		/ nullif(lag(repeat_users) over(order by action_month), 0)
		as priv_continuous_ratio
	-- 前月のカムバックユーザーのうち、当月がカムバックリピートユーザーであるユーザーの割合
	, 100.0 * come_back_repeat_users
		/ nullif(lag(come_back_users) over(order by action_month), 0)
		as priv_come_back_ratio
from monthly_users
order by action_month
	;


-- 5.2.8 訪問種別を定義して成長指数を集計する
with
unique_action_log as (
	select distinct 
		-- 同じ日付のログを2重にカウントしないよう、アクセスログから日付の重複を排除する
		user_id 
		, substring(stamp, 1, 7) as action_date
	from action_log
)
, mst_calendar as (
	select
		-- 集計したい期間のカレンダーテーブルを用意する
		substring(
			generate_series('2016-10-01'::timestamp, 
							'2016-11-04'::timestamp,
							' 1 day'::interval)::text
							, 1, 10)
		as dt
)
, target_date_with_user as (
	select
		-- ユーザーマスターに対して、カレンダーテーブルの全日付をtarget_dateとして付与する
		c.dt as target_date
		, u.user_id 
		, u.register_date 
		, u.withdraw_date
	from mst_users as u
	cross join mst_calendar as c
)
select
	*
from target_date_with_user as u
left join unique_action_log as a 
	on u.user_id = a.user_id
	and u.target_date = a.action_date
where -- 集計期間を登録日以降の日付に絞り込む
	u.register_date <= u.target_date
	-- 退会日が入っている場合は、集計期間を退会日以前の日付に絞り込む
	and (u.withdraw_date is null
		or u.target_date <= u. withdraw_date	
	)
	;




select regexp_split_to_table('1,2', ',');

