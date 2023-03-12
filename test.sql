show databases;

-- create database SQL_recipe;

use SQL_recipe;

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

show tables;
select * from mst_users;

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

select * from access_log;

SELECT 
	stamp
	-- referrerのホスト名部分を抽出する
	, substring(referrer, REGEXP_INSTR(referrer, '(?<=https?://)'), REGEXP_INSTR(referrer, '(')) as referrer_host
from access_log;

SELECT 
	stamp
	-- referrerのホスト名部分を抽出する（一度1つ目のhttp以降のスラッシュの出現までを切り取ってから、https//の部分を削除している）
	-- [^/]は^が否定の意味なので、/以外の意味（要するに[^/]*は/まで、という意味になる）
	,regexp_replace(REGEXP_SUBSTR(referrer, 'https?://[^/]*'), 'https?://', '') as referrer_host
from access_log;

-- [^/]について
select REGEXP_SUBSTR('abcde', '[^ec]*');


-- 3.1.2.2 URLのパスとGETパラメーターにある特定のキーの値を取り出すクエリ
SELECT 
	stamp
	, url
	, REGEXP_REPLACE(REGEXP_SUBSTR(url, '//[^/]+[^?#]+'), '//[^/]+', '') as path
	, REGEXP_REPLACE(REGEXP_SUBSTR(url, 'id=[^&]*'), 'id=', '') as id
from access_log;
;

-- 3.1.3.1 URLのパスをスラッシュで分割して階層を抽出するクエリ
SELECT 
	stamp
	, url
	-- split_partでn番目の要素を抽出する
	, REGEXP_REPLACE( 
		SUBSTRING_INDEX(
			REGEXP_SUBSTR(url, '//[^/]+[^?#]+')
			, '/', 4)
		, '//[^/]*/', '') as path1
	, REGEXP_REPLACE( 
		SUBSTRING_INDEX(
			REGEXP_SUBSTR(url, '//[^/]+[^?#]+')
			, '/', 5)
		, '//[^/]*/.*/', '') as path2
from access_log;

-- 3.1.4 現在の日付を取得する
select
	CURRENT_DATE()
	, CURRENT_TIMESTAMP();

-- 3.1.4.2　文字列を日付に変更する
SELECT 
	CAST('2016-01-01' as date) as date
	, str_to_date('2016/01/01 12:00:00', '%Y/%m/%d %T') as datetime
	, str_to_date('2016/01/01 12:00:00', '%Y/%m/%d %H:%i:%s') as datetime
	, CAST('2016/01/01 12:00:00' as datetime) as datetime
;

-- 3.1.4.3 タイムスタンプ型のデータから年月日などを取り出すクエリ

	





