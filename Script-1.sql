-- create database SQL_recipe_psq;

-- 3.1.1コードをラベルに変えるクエリ

DROP TABLE IF EXISTS mst_users;
CREATE TABLE mst_users(
    user_id         varchar(255)
  , register_date   varchar(255)
  , register_device integer
);

INSERT INTO mst_users
VALUES
    ('U001', '2016-08-26', 1)
  , ('U002', '2016-08-26', 2)
  , ('U003', '2016-08-27', 3)
;

select * from mst_users mu ;

SELECT
	user_id,
	CASE 
		when register_device = 1 then 'PC'
		when register_device = 2 then 'SP'
		when register_device = 3 then 'アプリ'
		else ' '
	END as device_name
from mst_users;

-- 3.1.2.1 リファラーのドメインを抽出するクエリ

DROP TABLE IF EXISTS access_log ;
CREATE TABLE access_log (
    stamp    varchar(255)
  , referrer text
  , url      text
);

INSERT INTO access_log 
VALUES
    ('2016-08-26 12:02:00', 'http://www.other.com/path1/index.php?k1=v1&k2=v2#Ref1', 'http://www.example.com/video/detail?id=001')
  , ('2016-08-26 12:02:01', 'http://www.other.net/path1/index.php?k1=v1&k2=v2#Ref1', 'http://www.example.com/video#ref'          )
  , ('2016-08-26 12:02:01', 'https://www.other.com/'                               , 'http://www.example.com/book/detail?id=002' )
;

select
	stamp
	-- [^/]は^が否定の意味なので、/以外の意味（要するに[^/]*は/まで、という意味になる）
	, substring(referrer from 'https?://([^/]*)') as refferer_host
from access_log;


-- 3.1.2.2 URLのパスとGETパラメーターにある特定のキーの値を取り出すクエリ
select
	stamp
	, url
	, substring(url from '//[^/]+([^?#]+)') as path
	, substring(url from 'id=([^/&]*)') as id
from access_log ;


-- 3.1.3.1 URLのパスをスラッシュで分割して階層を抽出するクエリ
SELECT 
	stamp
	, url
	, split_part(substring(url from '//[^/]+([^?#]+)'), '/', 2) as path_1
	, split_part(substring(url from '//[^/]+([^#?]+)'), '/', 3) as path_2
from access_log ;


-- 3.1.4 現在の日付を取得する
-- cuurent_timestampはタイムゾーンつき、localtimestampはタイムゾーンなし
select current_timestamp, localtimestamp, current_date; 


-- 3.1.4.2　文字列を日付に変更する
select
	cast('2016-01-30' as date) as dt
	, cast('2016-01-30 12:00:00' as timestamp) as stamp
;


-- 3.1.4.3 タイムスタンプ型のデータから年月日などを取り出すクエリ
select 
	stamp
	, extract(year from stamp) as year
	, extract(month from stamp) as month
	, extract(day from stamp) as day
	, extract(hour from stamp) as hour
from (select cast('2016-01-01 12:00:00' as timestamp) as stamp) as t;

-- 3.1.4.4 （別解)タイムスタンプ型のデータから年月日などを取り出すクエリ
select 
	stamp
	, substring(stamp, 1, 4) as year
	, substring(stamp, 6, 2) as month
	, substring(stamp, 9, 2) as day
	, substring(stamp, 12, 2) as hour
	, substring(stamp, 1, 7) as year_month
from (select cast('2016-01-01 12:00:00' as text) as stamp) as t;


-- 3.1.5.1 欠損値をデフォルト値に置き換える
DROP TABLE IF EXISTS purchase_log_with_coupon;
CREATE TABLE purchase_log_with_coupon (
    purchase_id varchar(255)
  , amount      integer
  , coupon      integer
);

INSERT INTO purchase_log_with_coupon
VALUES
    ('10001', 3280, NULL)
  , ('10002', 4650,  500)
  , ('10003', 3870, NULL)
;

select * from purchase_log_with_coupon ;

select 
	purchase_id
	, amount
	, coupon
	, amount - coupon as discount_amount1 --nullが入っている箇所はNULLが返ってきてしまう
	, amount - coalesce (coupon, 0) as discount_amount2 --NULLを0に置き換えて計算（OK)
from purchase_log_with_coupon ;


-- 3.2.1.1 文字列を連結する
DROP TABLE IF EXISTS mst_user_location;
CREATE TABLE mst_user_location (
    user_id   varchar(255)
  , pref_name varchar(255)
  , city_name varchar(255)
);

INSERT INTO mst_user_location
VALUES
    ('U001', '東京都', '千代田区')
  , ('U002', '東京都', '渋谷区'  )
  , ('U003', '千葉県', '八千代区')
;
select * from mst_user_location ;

-- 文字列の連結はconcatまたは||で行う
select 
	user_id
	, concat(pref_name, city_name) as pref_city
	, pref_name || city_name as pref_city2
from mst_user_location ;


-- 3.2.2.1 ２つのカラムの比較を行う
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
select * from quarterly_sales;

select 	
	year
	, q1
	, q2
	, case 
		when q1 < q2 then '+'
		when q1 = q2 then '='
		else '-'
	  end as judge_q1_q2
	, q2 - q1 as diff_q2_q1
	, sign(q2 - q1) as sign_q2_q1 --sign関数は引数が正の値なら1, 0なら0, 負の値なら-1を返す
from quarterly_sales
order by year;


-- 複数のカラムを比較して最大最小をみつける
select 
	year 
	, greatest(q1,q2,q3,q4) as greatest_sales -- 一番大きい値を取得
	, least(q1,q2,q3,q4) least_sales -- 一番小さい値を取得
from quarterly_sales
order by year;

	
-- 3.2.2.4 平均値を求めるクエリ
select 
	year 
	, (coalesce(q1, 0) + coalesce(q2, 0) + coalesce(q3, 0) + coalesce(q4, 0)) / 4 as average
from quarterly_sales
order by year;


-- NULLが含まれないカラムのみを使用して平均値を求めるクエリ
-- （NULLでなければcolalesceで正の値になり、それはsign関数で1になるので、足すとNULL以外を足していることになる）
select 
	year 
	, (coalesce(q1, 0) + coalesce(q2, 0) + coalesce(q3, 0) + coalesce(q4, 0)) /
	(sign(coalesce(q1, 0)) + sign(coalesce(q2, 0)) + sign(coalesce(q3, 0)) + sign(coalesce(q4, 0)))
	as average
from quarterly_sales
order by year;


-- 3.2.3.1　整数型のデータの除算を行う
DROP TABLE IF EXISTS advertising_stats;
CREATE TABLE advertising_stats (
    dt          varchar(255)
  , ad_id       varchar(255)
  , impressions integer
  , clicks      integer
);

INSERT INTO advertising_stats
VALUES
    ('2017-04-01', '001', 100000,  3000)
  , ('2017-04-01', '002', 120000,  1200)
  , ('2017-04-01', '003', 500000, 10000)
  , ('2017-04-02', '001',      0,     0)
  , ('2017-04-02', '002', 130000,  1400)
  , ('2017-04-02', '003', 620000, 15000)
;
select * from advertising_stats ;

select 
	dt
	, ad_id
	, cast(clicks as double precision) / impressions as ctr -- 小数点以下の値も表示するためにdouble precisionにcastしておく
	, 100.0 * clicks / impressions as ctr_as_percent -- 100.0を予め掛け算することで暗黙的にdouble precisionにcastする
from advertising_stats
where dt = '2017-04-01'
;

-- ０除算を避ける方法

















