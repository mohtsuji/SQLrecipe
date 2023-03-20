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
select 
	dt
	, ad_id
	, case 
		when impressions > 0 then 100.0 * clicks / impressions -- 0以上のみ計算する
	  end as ctr_as_percent
	, 100.0 * clicks / nullif(impressions, 0) as ctr_as_percent_by_null -- nullif関数はimpressionsが0だったらNULLにする
from advertising_stats;


-- 3.2.4.1 絶対値と2条平均平方根を計算する
DROP TABLE IF EXISTS location_1d;
CREATE TABLE location_1d (
    x1 integer
  , x2 integer
);

INSERT INTO location_1d
VALUES
    ( 5 , 10)
  , (10 ,  5)
  , (-2 ,  4)
  , ( 3 ,  3)
  , ( 0 ,  1)
;

select * from location_1d ;

select 
	abs(x1 - x2) as abs -- abs関数で絶対値を計算
	, sqrt(power(x1 - x2, 2)) as rms -- poser関数で累乗（2乗）にして、それをsqrt関数で平方根を取る
from location_1d;


-- 3.2.4.2 二次元のデータに対して二乗平均平方根（ユークリッド距離）を計算する 	
DROP TABLE IF EXISTS location_2d;
CREATE TABLE location_2d (
    x1 integer
  , y1 integer
  , x2 integer
  , y2 integer
);

INSERT INTO location_2d
VALUES
    (0, 0, 2, 2)
  , (3, 5, 1, 2)
  , (5, 3, 2, 1)
;
select * from location_2d ;

select 
	sqrt(power(x1 - x2, 2) + power(y1 - y2, 2)) as dist
	, point(x1, y1) <-> point(x2, y2) as dist_2 -- point関数でも距離を計算可能
from location_2d ;
	

-- 3.2.5.1 日付と時刻を計算する

DROP TABLE IF EXISTS mst_users_with_birthday;
CREATE TABLE mst_users_with_birthday (
    user_id        varchar(255)
  , register_stamp varchar(255)
  , birth_date     varchar(255)
);

INSERT INTO mst_users_with_birthday
VALUES
    ('U001', '2016-02-28 10:00:00', '2000-02-29')
  , ('U002', '2016-02-29 10:00:00', '2000-02-29')
  , ('U003', '2016-03-01 10:00:00', '2000-02-29')
;
select * from mst_users_with_birthday;

select 
	user_id
	, register_stamp
	, register_stamp::timestamp as register_timestamp -- ::でcastの意味
	, register_stamp::timestamp + '1 hour'::interval as after_1_hour -- 時間の計算はintevalで行う
	, register_stamp::timestamp - '30 minutes'::interval as before_30_minutes
	, register_stamp::date as register_date
	, (register_stamp::date + '1 day'::interval) as after_1_day_test
	, (register_stamp::date + '1 day'::interval)::date as after_1_day
	, (register_stamp::date - '1 month'::interval)::date as before_1_month
from mst_users_with_birthday;
	

-- 3.2.5.3 年齢を計算する
select 
	user_id
	, current_date  as today
	, register_stamp::date as register_date
	, birth_date::date as birth_date
	, age(birth_date::date) as age -- age関数は現在の日時と引数の日時の差分をとってくれる
	, extract(year from age(birth_date::date)) as current_age
	, extract(year from age(register_stamp::date, birth_date::date)) as register_age
from mst_users_with_birthday ;
	

-- 3.2.5.6 文字列型の誕生日から、登録時点と現在時点での年齢を計算する
-- （-をなくした形で整数型にして、引き算して10000で割ると経過年数が計算できる)
-- （20160228 - 20160229) / 10000を行っている
select 
	user_id
	, substring(register_stamp, 1, 10) as register_date
	, birth_date
	-- 登録時点での年齢を計算する
	, floor((cast(replace(substring(register_stamp, 1,10), '-', '') as integer)
			- cast(replace(birth_date, '-', '') as integer))
			/ 10000) as register_age
	-- 現在時点での年齢を計算する
	, floor((cast(replace(cast(current_date as text), '-', '') as integer)
			- cast(replace(birth_date, '-', '') as integer))
			/ 10000) as birth_age
from mst_users_with_birthday ;
	
	
-- 3.2.6.1 inet型を活用してIPアドレスを比較する
-- inet型とは：postgresqlに用意されているIPアドレスを扱うための型
-- inet同士の比較は<, >を使用する
select 
	cast('127.0.0.1' as inet) < cast('127.0.0.2' as inet) as lt
	, cast('127.0.0.1' as inet) > cast('192.168.0.1' as inet) as gt
;

-- 3.2.6.2 inet型を用いてIPアドレスの範囲を扱うクエリ
select cast('127.0.0.1' as inet) << cast('127.0.0.0/8' as inet) as is_contained;
	
-- 3.2.6.3 IPアドレスから4つのオクテット部分を切り出すクエリ
select 
	ip
	, cast(split_part(ip, '.', 1) as integer) as ip_part_1
	, cast(split_part(ip, '.', 2) as integer) as ip_part_2
	, cast(split_part(ip, '.', 3) as integer) as ip_part_3
	, cast(split_part(ip, '.', 4) as integer) as ip_part_4
from (select '192.168.0.1' as ip) as t
;

-- IPアドレスを整数型の表記に変換することで比較可能な形にする
select 
	ip
	, cast(split_part(ip, '.', 1) as integer) * 2^24
	+ cast(split_part(ip, '.', 2) as integer) * 2^16
	+ cast(split_part(ip, '.', 3) as integer) * 2^8
	+ cast(split_part(ip, '.', 4) as integer) * 2^0
	as ip_integer
from (select '192.168.0.1' as ip) as t
;

-- IPアドレスを0埋めして文字列に変換することで比較可能な形にする
-- lpadは指定した文字で指定した数左埋めする->lpad(文字列, 埋める数, 埋める文字)
select 
	ip
	, lpad(split_part(ip, '.', 1), 3, '0')
	|| lpad(split_part(ip, '.', 2), 3, '0') --- ||は文字列の連結
	|| lpad(split_part(ip, '.', 3), 3, '0')
	|| lpad(split_part(ip, '.', 4), 3, '0')
	as ip_padding
from (select '192.168.0.1' as ip) as t
;

