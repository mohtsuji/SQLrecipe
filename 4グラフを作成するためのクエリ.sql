-- 4.1.1　時系列データを集約する
DROP TABLE IF EXISTS purchase_log;
CREATE TABLE purchase_log(
    dt              varchar(255)
  , order_id        integer
  , user_id         varchar(255)
  , purchase_amount integer
);
INSERT INTO purchase_log
VALUES
    ('2014-01-01',  1, 'rhwpvvitou', 13900)
  , ('2014-01-01',  2, 'hqnwoamzic', 10616)
  , ('2014-01-02',  3, 'tzlmqryunr', 21156)
  , ('2014-01-02',  4, 'wkmqqwbyai', 14893)
  , ('2014-01-03',  5, 'ciecbedwbq', 13054)
  , ('2014-01-03',  6, 'svgnbqsagx', 24384)
  , ('2014-01-03',  7, 'dfgqftdocu', 15591)
  , ('2014-01-04',  8, 'sbgqlzkvyn',  3025)
  , ('2014-01-04',  9, 'lbedmngbol', 24215)
  , ('2014-01-04', 10, 'itlvssbsgx',  2059)
  , ('2014-01-05', 11, 'jqcmmguhik',  4235)
  , ('2014-01-05', 12, 'jgotcrfeyn', 28013)
  , ('2014-01-05', 13, 'pgeojzoshx', 16008)
  , ('2014-01-06', 14, 'msjberhxnx',  1980)
  , ('2014-01-06', 15, 'tlhbolohte', 23494)
  , ('2014-01-06', 16, 'gbchhkcotf',  3966)
  , ('2014-01-07', 17, 'zfmbpvpzvu', 28159)
  , ('2014-01-07', 18, 'yauwzpaxtx',  8715)
  , ('2014-01-07', 19, 'uyqboqfgex', 10805)
  , ('2014-01-08', 20, 'hiqdkrzcpq',  3462)
  , ('2014-01-08', 21, 'zosbvlylpv', 13999)
  , ('2014-01-08', 22, 'bwfbchzgnl',  2299)
  , ('2014-01-09', 23, 'zzgauelgrt', 16475)
  , ('2014-01-09', 24, 'qrzfcwecge',  6469)
  , ('2014-01-10', 25, 'njbpsrvvcq', 16584)
  , ('2014-01-10', 26, 'cyxfgumkst', 11339)
;

select * from purchase_log ;

-- 4.1.1.1 時系列データの日別売上と平均購入額を集計する
select 
	dt
	, count(*) as purchase_count
	, sum(purchase_amount) as total_amount
	, avg(purchase_amount) as avg_amount
from purchase_log 
group by dt
order by dt
;


-- 4.1.2.1 時系列データの日別売上と7日間移動平均を集計するクエリ
select 
	dt
	, count(*) as purchase_count
	, sum(purchase_amount) as total_amount
	, avg(sum(purchase_amount)) -- sum(amount)に対してWINDOW関数のAVGを使用している 
		over(order by dt rows between 6 preceding and current row)
		as seven_day_avg
	-- 厳密に7日間の平均を計算する（直近で7日間平均が取れない箇所は除外する）
	, case 
		when 7 = count(*) over(order by dt rows between 6 preceding and current row)
		then avg(sum(purchase_amount)) over(order by dt rows between 6 preceding and current row)
	end as seven_day_avg_strict
from purchase_log 
group by dt
order by dt
;


-- 4.1.3.1 日別の売上と当月累計売上を集計するクエリ
select 
	dt
	, substring(dt, 1, 7) as year_month
	, sum(purchase_amount) as total_amount
	, sum(sum(purchase_amount)) -- sum(amount)に対してWINDOW関数のSUMを使用している 
		over(partition by substring(dt, 1, 7) order by dt rows unbounded preceding)
		as agg_amount
from purchase_log 
group by dt
order by dt
;


-- 4.1.3.2 4.1.3.1をWITH句を利用してわかりやすくする
with
daily_purchase as (
	select 
		dt
		, sum(purchase_amount) as purchase_amount
		, substring(dt, 1, 4) as year
		, substring(dt, 6, 2) as month
		, substring(dt, 9, 4) as date
	from purchase_log 
	group by dt
	order by dt
)
select 
	dt
	, concat(year, month)
	, purchase_amount
	, sum(purchase_amount) 
		over(partition by year, month order by dt rows unbounded preceding)
		as agg_amount
from daily_purchase
;


-- 4.1.4 昨年との対比をみる
DROP TABLE IF EXISTS purchase_log;
CREATE TABLE purchase_log(
    dt              varchar(255)
  , order_id        integer
  , user_id         varchar(255)
  , purchase_amount integer
);
INSERT INTO purchase_log
VALUES
    ('2014-01-01',    1, 'rhwpvvitou', 13900)
  , ('2014-02-08',   95, 'chtanrqtzj', 28469)
  , ('2014-03-09',  168, 'bcqgtwxdgq', 18899)
  , ('2014-04-11',  250, 'kdjyplrxtk', 12394)
  , ('2014-05-11',  325, 'pgnjnnapsc',  2282)
  , ('2014-06-12',  400, 'iztgctnnlh', 10180)
  , ('2014-07-11',  475, 'eucjmxvjkj',  4027)
  , ('2014-08-10',  550, 'fqwvlvndef',  6243)
  , ('2014-09-10',  625, 'mhwhxfxrxq',  3832)
  , ('2014-10-11',  700, 'wyrgiyvaia',  6716)
  , ('2014-11-10',  775, 'cwpdvmhhwh', 16444)
  , ('2014-12-10',  850, 'eqeaqvixkf', 29199)
  , ('2015-01-09',  925, 'efmclayfnr', 22111)
  , ('2015-02-10', 1000, 'qnebafrkco', 11965)
  , ('2015-03-12', 1075, 'gsvqniykgx', 20215)
  , ('2015-04-12', 1150, 'ayzvjvnocm', 11792)
  , ('2015-05-13', 1225, 'knhevkibbp', 18087)
  , ('2015-06-10', 1291, 'wxhxmzqxuw', 18859)
  , ('2015-07-10', 1366, 'krrcpumtzb', 14919)
  , ('2015-08-08', 1441, 'lpglkecvsl', 12906)
  , ('2015-09-07', 1516, 'mgtlsfgfbj',  5696)
  , ('2015-10-07', 1591, 'trgjscaajt', 13398)
  , ('2015-11-06', 1666, 'ccfbjyeqrb',  6213)
  , ('2015-12-05', 1741, 'onooskbtzp', 26024)
;
select * from purchase_log ;

-- 4.1.4.1 月別売上と昨年対比を計算する
with
daily_purchase as (
	select 
		dt
		, sum(purchase_amount) as purchase_amount
		, substring(dt, 1, 4) as year
		, substring(dt, 6, 2) as month
		, substring(dt, 9, 4) as date
	from purchase_log 
	group by dt
	order by dt
)
select 
	month
	, sum(case year when '2014' then purchase_amount end) as amount_2014
	, sum(case when year = '2015' then purchase_amount end) as amount_2015
	, 100.0
		* sum(case when year = '2015' then purchase_amount end)
		/ sum(case when year = '2014' then purchase_amount end)
		as rate
from daily_purchase
group by month
order by month 
;


-- 4.1.5 Zチャートを作成する
DROP TABLE IF EXISTS purchase_log;
CREATE TABLE purchase_log(
    dt              varchar(255)
  , order_id        integer
  , user_id         varchar(255)
  , purchase_amount integer
);
INSERT INTO purchase_log
VALUES
    ('2014-01-01',    1, 'rhwpvvitou', 13900)
  , ('2014-02-08',   95, 'chtanrqtzj', 28469)
  , ('2014-03-09',  168, 'bcqgtwxdgq', 18899)
  , ('2014-04-11',  250, 'kdjyplrxtk', 12394)
  , ('2014-05-11',  325, 'pgnjnnapsc',  2282)
  , ('2014-06-12',  400, 'iztgctnnlh', 10180)
  , ('2014-07-11',  475, 'eucjmxvjkj',  4027)
  , ('2014-08-10',  550, 'fqwvlvndef',  6243)
  , ('2014-09-10',  625, 'mhwhxfxrxq',  3832)
  , ('2014-10-11',  700, 'wyrgiyvaia',  6716)
  , ('2014-11-10',  775, 'cwpdvmhhwh', 16444)
  , ('2014-12-10',  850, 'eqeaqvixkf', 29199)
  , ('2015-01-09',  925, 'efmclayfnr', 22111)
  , ('2015-02-10', 1000, 'qnebafrkco', 11965)
  , ('2015-03-12', 1075, 'gsvqniykgx', 20215)
  , ('2015-04-12', 1150, 'ayzvjvnocm', 11792)
  , ('2015-05-13', 1225, 'knhevkibbp', 18087)
  , ('2015-06-10', 1291, 'wxhxmzqxuw', 18859)
  , ('2015-07-10', 1366, 'krrcpumtzb', 14919)
  , ('2015-08-08', 1441, 'lpglkecvsl', 12906)
  , ('2015-09-07', 1516, 'mgtlsfgfbj',  5696)
  , ('2015-10-07', 1591, 'trgjscaajt', 13398)
  , ('2015-11-06', 1666, 'ccfbjyeqrb',  6213)
  , ('2015-12-05', 1741, 'onooskbtzp', 26024)
;

select * from purchase_log ;

-- 4.1.5.1 2015年の売上に対してZチャートを作成する
with
daily_purchase as (
	select 
		dt
		, sum(purchase_amount) as purchase_amount
		, substring(dt, 1, 4) as year
		, substring(dt, 6, 2) as month
		, substring(dt, 9, 4) as date
	from purchase_log 
	group by dt
	order by dt
) -- 月別の売上を集計
, monthly_amount as (
	select 
		year
		, month 
		, sum(purchase_amount) as amount	
	from daily_purchase
	group by year, month
	order by year, month
)
, calc_index as (
	select 
		year
		, month 
		-- 2015年の累計売上
		, sum(case year when '2015' then amount end) 
			over(order by year, month rows unbounded preceding)
				as agg_amount
		-- 当月から11ヶ月前までの合計売上を計算
		, sum(amount) 
			over(order by year, month rows between 11 preceding and current row)
			as year_avg_amount
	from monthly_amount
	order by year, month
)
select 
	concat(year, '-', month) as year_month
	, agg_amount
	, year_avg_amount
from calc_index
where year = '2015'
order by year_month
;


-- 4.1.6 売上に関する指標を集計する
DROP TABLE IF EXISTS purchase_log;
CREATE TABLE purchase_log(
    dt              varchar(255)
  , order_id        integer
  , user_id         varchar(255)
  , purchase_amount integer
);
INSERT INTO purchase_log
VALUES
    ('2014-01-01',    1, 'rhwpvvitou', 13900)
  , ('2014-02-08',   95, 'chtanrqtzj', 28469)
  , ('2014-03-09',  168, 'bcqgtwxdgq', 18899)
  , ('2014-04-11',  250, 'kdjyplrxtk', 12394)
  , ('2014-05-11',  325, 'pgnjnnapsc',  2282)
  , ('2014-06-12',  400, 'iztgctnnlh', 10180)
  , ('2014-07-11',  475, 'eucjmxvjkj',  4027)
  , ('2014-08-10',  550, 'fqwvlvndef',  6243)
  , ('2014-09-10',  625, 'mhwhxfxrxq',  3832)
  , ('2014-10-11',  700, 'wyrgiyvaia',  6716)
  , ('2014-11-10',  775, 'cwpdvmhhwh', 16444)
  , ('2014-12-10',  850, 'eqeaqvixkf', 29199)
  , ('2015-01-09',  925, 'efmclayfnr', 22111)
  , ('2015-02-10', 1000, 'qnebafrkco', 11965)
  , ('2015-03-12', 1075, 'gsvqniykgx', 20215)
  , ('2015-04-12', 1150, 'ayzvjvnocm', 11792)
  , ('2015-05-13', 1225, 'knhevkibbp', 18087)
  , ('2015-06-10', 1291, 'wxhxmzqxuw', 18859)
  , ('2015-07-10', 1366, 'krrcpumtzb', 14919)
  , ('2015-08-08', 1441, 'lpglkecvsl', 12906)
  , ('2015-09-07', 1516, 'mgtlsfgfbj',  5696)
  , ('2015-10-07', 1591, 'trgjscaajt', 13398)
  , ('2015-11-06', 1666, 'ccfbjyeqrb',  6213)
  , ('2015-12-05', 1741, 'onooskbtzp', 26024)
;
select * from purchase_log ;



-- 4.1.6.1 なんかデータおかしくて動かん
with
daily_purchase as (
	select 
		dt
		, order_id
		, sum(purchase_amount) as purchase_amount
		, substring(dt, 1, 4) as year
		, substring(dt, 6, 2) as month
		, substring(dt, 9, 4) as date
	from purchase_log 
	group by dt
	order by dt
)
select 
	year 
	, month 
	, sum(purchase_amount) as monthly
	, sum(order_id) as orders
from daily_purchase
;
	

-- 4.2 多面的な軸からでーたをしゅうやくする
DROP TABLE IF EXISTS purchase_detail_log;
CREATE TABLE purchase_detail_log(
    dt           varchar(255)
  , order_id     integer
  , user_id      varchar(255)
  , item_id      varchar(255)
  , price        integer
  , category     varchar(255)
  , sub_category varchar(255)
);

INSERT INTO purchase_detail_log
VALUES
    ('2015-12-01',   1, 'U001', 'D001', 200, 'ladys_fashion', 'bag'        )
  , ('2015-12-08',  95, 'U002', 'D002', 300, 'dvd'          , 'documentary')
  , ('2015-12-09', 168, 'U003', 'D003', 500, 'game'         , 'accessories')
  , ('2015-12-11', 250, 'U004', 'D004', 800, 'ladys_fashion', 'jacket'     )
  , ('2015-12-11', 325, 'U005', 'D005', 200, 'mens_fashion' , 'jacket'     )
  , ('2015-12-12', 400, 'U006', 'D006', 400, 'cd'           , 'classic'    )
  , ('2015-12-11', 475, 'U007', 'D007', 400, 'book'         , 'business'   )
  , ('2015-12-10', 550, 'U008', 'D008', 600, 'food'         , 'meats'      )
  , ('2015-12-10', 625, 'U009', 'D009', 600, 'food'         , 'fish'       )
  , ('2015-12-11', 700, 'U010', 'D010', 200, 'supplement'   , 'protain'    )
;
select * from purchase_detail_log ;

-- 4.2.1.1 カテゴリ別の売上と小計を同時に取得するクエリ
-- 複数の次元でデータを集約させるので、WITH句でいくつかの小さいテーブルを作成してそれらを結合する
with
sub_category_amount as (
	select
		-- 小カテゴリの売上を集計する
		category
		, sub_category
		, sum(price) as amount
	from  purchase_detail_log 
	group by category, sub_category
)
, category_amount as (
	select 
		-- 大カテゴリごとの売上を集計する
		category
		, sum(price) as amount
		, 'all' as sub_category -- sub_category列をALLとすることで全てのsub_categoryを含むことを示す
	from purchase_detail_log
	group by category
)
, total_amount as (
	select 
		--全体の売上を集計する
		sum(price) as amount
		, 'all' as sub_category
		, 'all' as category
	from purchase_detail_log 
)
select category, sub_category, amount from sub_category_amount
union all
select category, sub_category, amount from category_amount
union all
select category, sub_category, amount from total_amount
order by category
;


-- 4.2.1.2 ROLLUP関数で上と同じことをする（UNION ALLを使うよりパフォーマンスがいい）
select 
	coalesce (category, 'all') as category
	, coalesce (sub_category, 'all') as sub_category
	, sum(price) as amount
from purchase_detail_log 
group by 
	rollup(category, sub_category) -- 指定したカラムの全ての組み合わせを作成する？
;


-- 4.2.2 ABC分析を行う
DROP TABLE IF EXISTS purchase_detail_log;
CREATE TABLE purchase_detail_log(
    dt           varchar(255)
  , order_id     integer
  , user_id      varchar(255)
  , item_id      varchar(255)
  , price        integer
  , category     varchar(255)
  , sub_category varchar(255)
);
INSERT INTO purchase_detail_log
VALUES
    ('2015-12-01',   1, 'U001', 'D001', 200, 'ladys_fashion', 'bag'        )
  , ('2015-12-08',  95, 'U002', 'D002', 300, 'dvd'          , 'documentary')
  , ('2015-12-09', 168, 'U003', 'D003', 500, 'game'         , 'accessories')
  , ('2015-12-11', 250, 'U004', 'D004', 800, 'ladys_fashion', 'jacket'     )
  , ('2015-12-11', 325, 'U005', 'D005', 200, 'mens_fashion' , 'jacket'     )
  , ('2015-12-12', 400, 'U006', 'D006', 400, 'cd'           , 'classic'    )
  , ('2015-12-11', 475, 'U007', 'D007', 400, 'book'         , 'business'   )
  , ('2015-12-10', 550, 'U008', 'D008', 600, 'food'         , 'meats'      )
  , ('2015-12-10', 625, 'U009', 'D009', 600, 'food'         , 'fish'       )
  , ('2015-12-11', 700, 'U010', 'D010', 200, 'supplement'   , 'protain'    )
;
select * from purchase_detail_log ;

-- 4.2.2.1 売上構成比累計とABCランクを計算するクエリ
with
monthly_sales as (
	select 
		category
		-- 項目別売上を計算
		, sum(price) as amount
	from purchase_detail_log
	group by category
)
, sales_composition_ratio as (
	select 
		category
		, amount
		-- 構成比：100.0 * 項目別売上 / 全体売上
		, 100.0 * amount / sum(amount) over() as composition_ratio -- sumは単なる集約関数ではなくWINDOW関数にしないとcategoryを表示できなくなる
		-- 構成比累計: 100.0 * 項目別累計売上 / 全体売上
		, 100.0 * sum(amount) over(order by amount desc)
			/ sum(amount) over() as cumulative_ratio
	from monthly_sales
)
select
	*
	-- 構成比累計の範囲に応じてランク分け
	, case
		when cumulative_ratio between 0 and 70 then 'A'
		when cumulative_ratio between 70 and 90 then 'B'
		when cumulative_ratio between 90 and 100 then 'C'
	end as abc_rank
from sales_composition_ratio
;


-- 4.2.3 ファンチャートを作成する
DROP TABLE IF EXISTS purchase_detail_log;
CREATE TABLE purchase_detail_log(
    dt           varchar(255)
  , order_id     integer
  , user_id      varchar(255)
  , item_id      varchar(255)
  , price        integer
  , category     varchar(255)
  , sub_category varchar(255)
);
INSERT INTO purchase_detail_log
VALUES
    ('2015-12-01',   1, 'U001', 'D001', 200, 'ladys_fashion', 'bag'        )
  , ('2015-12-08',  95, 'U002', 'D002', 300, 'dvd'          , 'documentary')
  , ('2015-12-09', 168, 'U003', 'D003', 500, 'game'         , 'accessories')
  , ('2015-12-11', 250, 'U004', 'D004', 800, 'ladys_fashion', 'jacket'     )
  , ('2015-12-11', 325, 'U005', 'D005', 200, 'mens_fashion' , 'jacket'     )
  , ('2015-12-12', 400, 'U006', 'D006', 400, 'cd'           , 'classic'    )
  , ('2015-12-11', 475, 'U007', 'D007', 400, 'book'         , 'business'   )
  , ('2015-12-10', 550, 'U008', 'D008', 600, 'food'         , 'meats'      )
  , ('2015-12-10', 625, 'U009', 'D009', 600, 'food'         , 'fish'       )
  , ('2015-12-11', 700, 'U010', 'D010', 200, 'supplement'   , 'protain'    )
;
select * from purchase_detail_log ;


-- 4.2.3.1 ファンチャート作成に必要なデータを取得する
with
daily_category_amount as (
	select 
		dt
		, category
		, substring(dt, 1, 4) as year
		, substring(dt, 6, 2) as month
		, substring(dt, 9, 2) as date
		, sum(price) as amount
	from purchase_detail_log
	group by dt, category
)
, monthly_category_amount as (
	select 
		concat(year, '-', month) as year_month
		, category
		, sum(amount) as amount
	from daily_category_amount
	group by year, month, category
)
select 
	year_month
	, category
	, amount
	, first_value(amount) 
		over(partition by category
				order by year_month, category 
				rows unbounded preceding)
		as base_amount
	, 100.0 * amount 
		/ first_value(amount) 
		over(partition by category
				order by year_month, category 
				rows unbounded preceding)
		as rate
from monthly_category_amount
;


-- 4.2.4 ヒストグラムを作成する

-- 4.2.4.1 最大値、最小値、範囲を求める
with
stats as (
	select 
		max(price) + 1 as max_price -- max+1にすることで、maxの値も範囲内に収まるようにする
		, min(price) as min_price
		, max(price) + 1 - min(price) as range_price
		-- 階級数は10にする
		, 10 as bucket_num
	from purchase_detail_log
)
, purchase_log_with_bucket as (
	select
		price
		, range_price
		, min_price
		-- 正規化金額：対象の金額から最小金額を引く
		, price - min_price as diff
		-- 階級範囲：金額範囲を階級数で割る
		, 1.0 * range_price / bucket_num as bucket_range
		--　階級の判定：FLOOR（正規化金額 / 階級範囲）
		, floor(
			1.0 * (price - min_price)
			/ (1.0 * range_price / bucket_num)
			-- indexを1から始めるために1を足す
			) + 1 as bucket
	from purchase_detail_log , stats -- この書き方でCROSS JOINになるらしい
)
select
	bucket
	-- 各階級の上限と下限を計算する
	, min_price + bucket_range * (bucket - 1) as lower_limit
	, min_price + bucket_range * bucket as upper_limit
	-- 度数をカウントする
	, count(price) as num_purchase
	-- 合計金額を計算する
	, sum(price) as total_amount
from purchase_log_with_bucket
group by bucket, min_price, bucket_range
order by bucket
;
