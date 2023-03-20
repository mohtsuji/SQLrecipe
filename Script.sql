-- 6.1.4 アクセスされる曜日、時間帯を把握する
DROP TABLE IF EXISTS access_log;
CREATE TABLE access_log(
    stamp         varchar(255)
  , short_session varchar(255)
  , long_session  varchar(255)
  , url           text
  , referrer      text
);
INSERT INTO access_log
VALUES
    ('2016-10-01 12:00:00', '0CVKaz', '1CwlSX', 'http://www.example.com/?utm_source=google&utm_medium=search'       , 'http://www.google.co.jp/xxx'      )
  , ('2016-10-01 13:00:00', '0CVKaz', '1CwlSX', 'http://www.example.com/detail?id=1'                                , ''                                 )
  , ('2016-10-01 13:00:00', '1QceiB', '3JMO2k', 'http://www.example.com/list/cd'                                    , ''                                 )
  , ('2016-10-01 14:00:00', '1QceiB', '3JMO2k', 'http://www.example.com/detail?id=1'                                , 'http://search.google.co.jp/xxx'   )
  , ('2016-10-01 15:00:00', '1hI43A', '6SN6DD', 'http://www.example.com/list/newly'                                 , ''                                 )
  , ('2016-10-01 16:00:00', '1hI43A', '6SN6DD', 'http://www.example.com/list/cd'                                    , 'http://www.example.com/list/newly')
  , ('2016-10-01 17:00:00', '2bGs3i', '1CwlSX', 'http://www.example.com/'                                           , ''                                 )
  , ('2016-10-01 18:00:00', '2is8PX', '7Dn99b', 'http://www.example.com/detail?id=2'                                , 'https://twitter.com/xxx'          )
  , ('2016-10-02 12:00:00', '2mmGwD', 'EFnoNR', 'http://www.example.com/'                                           , ''                                 )
  , ('2016-10-02 13:00:00', '2mmGwD', 'EFnoNR', 'http://www.example.com/list/cd'                                    , 'http://search.google.co.jp/xxx'   )
  , ('2016-10-02 14:00:00', '3CEHe1', 'FGkTe9', 'http://www.example.com/list/dvd'                                   , ''                                 )
  , ('2016-10-02 15:00:00', '3Gv8vO', '1CwlSX', 'http://www.example.com/detail?id=2'                                , ''                                 )
  , ('2016-10-02 16:00:00', '3cv4gm', 'KBlKgT', 'http://www.example.com/list/newly'                                 , 'http://search.yahoo.co.jp/xxx'    )
  , ('2016-10-02 17:00:00', '3cv4gm', 'KBlKgT', 'http://www.example.com/'                                           , 'https://www.facebook.com/xxx'     )
  , ('2016-10-02 18:00:00', '690mvB', 'FGkTe9', 'http://www.example.com/list/dvd?utm_source=yahoo&utm_medium=search', 'http://www.yahoo.co.jp/xxx'       )
  , ('2016-10-03 12:00:00', '6oABhM', '3JMO2k', 'http://www.example.com/detail?id=3'                                , 'http://search.yahoo.co.jp/xxx'    )
  , ('2016-10-03 13:00:00', '7jjxQX', 'KKTw9P', 'http://www.example.com/?utm_source=mynavi&utm_medium=affiliate'    , 'http://www.mynavi.jp/xxx'         )
  , ('2016-10-03 14:00:00', 'AAuoEU', '6SN6DD', 'http://www.example.com/list/dvd'                                   , 'https://www.facebook.com/xxx'     )
  , ('2016-10-03 15:00:00', 'AAuoEU', '6SN6DD', 'http://www.example.com/list/newly'                                 , ''                                 )
;
select * from access_log ;

with
access_log_with_dow as (
	select 
		stamp
		-- 日曜日(0)から土曜日(6)までの曜日番号を取得する
		, date_part('dow', stamp::timestamp) as dow
		-- 00:00:00からの経過秒数を計算する
		, cast(substring(stamp, 12, 2) as int) * 60 * 60
			+ cast(substring(stamp, 15, 2) as int) * 60
			+ cast(substring(stamp, 18, 2) as int)
			as whole_seconds
		-- タイムスタンプを切り捨てる秒数を定義する
		-- ここでは30分（1800秒）に指定
		, 30 * 60 as interval_seconds
	from access_log 
)
, access_log_with_floor_seconds as (
	select
		stamp
		, dow
		-- 00:00:00からの経過時間をinterval_secondsで切り捨てる
		, cast((floor(whole_seconds / interval_seconds) * interval_seconds) as int)
			as floor_seconds
	from 
	access_log_with_dow
)
, access_log_with_index_time as (
	select
		stamp
		, dow
		-- 総秒数からタイムスタンプの時刻表記に変換する
		-- lpad(text, 文字数, textが文字数に満たなかった場合指定の文字で左埋めする)
		, lpad(floor(floor_seconds / (60 * 60))::text , 2, '0') || ':' -- 時間を取得
			|| lpad(floor(floor_seconds % (60 * 60) / 60)::text, 2, '0') || ':' --分を取得
			|| lpad(floor(floor_seconds % 60)::text, 2, '0') -- 秒を取得
			as index_time
	from access_log_with_floor_seconds
)
select
	index_time
	, count(case dow when 0 then 1 end) as sun
	, count(case dow when 1 then 1 end) as mon
	, count(case dow when 2 then 1 end) as tue
	, count(case dow when 3 then 1 end) as wed
	, count(case dow when 4 then 1 end) as thu
	, count(case dow when 5 then 1 end) as fri
	, count(case dow when 6 then 1 end) as sat
from access_log_with_index_time
group by index_time
order by index_time
	;


-- 6.2.1 入り口ページと出口ページを把握する
DROP TABLE IF EXISTS activity_log;
CREATE TABLE activity_log(
    stamp        varchar(255)
  , session      varchar(255)
  , action       varchar(255)
  , option       varchar(255)
  , path         varchar(255)
  , search_type  varchar(255)
);
INSERT INTO activity_log
VALUES
    ('2017-01-09 12:18:43', '989004ea', 'view', 'search', '/search_list/' , 'Area-L-with-Job' )
  , ('2017-01-09 12:19:27', '989004ea', 'view', 'page'  , '/search_input/', ''                )
  , ('2017-01-09 12:20:03', '989004ea', 'view', 'search', '/search_list/' , 'Pref'            )
  , ('2017-01-09 12:18:43', '47db0370', 'view', 'search', '/search_list/' , 'Area-S'          )
  , ('2017-01-09 12:18:43', '1cf7678e', 'view', 'detail', '/detail/'      , ''                )
  , ('2017-01-09 12:19:04', '1cf7678e', 'view', 'page'  , '/'             , ''                )
  , ('2017-01-09 12:18:43', '5eb2e107', 'view', 'detail', '/detail/'      , ''                )
  , ('2017-01-09 12:18:43', 'fe05e1d8', 'view', 'detail', '/detail/'      , ''                )
  , ('2017-01-09 12:18:43', '87b5725f', 'view', 'detail', '/detail/'      , ''                )
  , ('2017-01-09 12:20:22', '87b5725f', 'view', 'search', '/search_list/' , 'Line'            )
  , ('2017-01-09 12:20:46', '87b5725f', 'view', 'page'  , '/'             , ''                )
  , ('2017-01-09 12:21:26', '87b5725f', 'view', 'page'  , '/search_input/', ''                )
  , ('2017-01-09 12:22:51', '87b5725f', 'view', 'search', '/search_list/' , 'Station-with-Job')
  , ('2017-01-09 12:24:13', '87b5725f', 'view', 'detail', '/detail/'      , ''                )
  , ('2017-01-09 12:25:25', '87b5725f', 'view', 'page'  , '/complete'             , ''                )
  , ('2017-01-09 12:18:43', 'eee2bb21', 'view', 'detail', '/detail/'      , ''                )
  , ('2017-01-09 12:18:43', '5d5b0997', 'view', 'detail', '/detail/'      , ''                )
  , ('2017-01-09 12:18:43', '111f2996', 'view', 'search', '/search_list/' , 'Pref'            )
  , ('2017-01-09 12:19:11', '111f2996', 'view', 'page'  , '/search_input/', ''                )
  , ('2017-01-09 12:20:10', '111f2996', 'view', 'page'  , '/'             , ''                )
  , ('2017-01-09 12:21:14', '111f2996', 'view', 'page'  , '/search_input/', ''                )
  , ('2017-01-09 12:18:43', '3efe001c', 'view', 'detail', '/detail/'      , ''                )
  , ('2017-01-09 12:18:43', '9afaf87c', 'view', 'search', '/search_list/' , ''                )
  , ('2017-01-09 12:20:18', '9afaf87c', 'view', 'detail', '/detail/'      , ''                )
  , ('2017-01-09 12:21:39', '9afaf87c', 'view', 'detail', '/detail/'      , ''                )
  , ('2017-01-09 12:22:52', '9afaf87c', 'view', 'search', '/complete' , 'Line-with-Job'   )
  , ('2017-01-09 12:18:43', 'd45ec190', 'view', 'detail', '/detail/'      , ''                )
  , ('2017-01-09 12:18:43', '0fe39581', 'view', 'search', '/search_list/' , 'Area-S'          )
  , ('2017-01-09 12:18:43', '36dd0df7', 'view', 'search', '/search_list/' , 'Pref-with-Job'   )
  , ('2017-01-09 12:19:49', '36dd0df7', 'view', 'detail', '/detail/'      , ''                )
  , ('2017-01-09 12:18:43', '8cc03a54', 'view', 'search', '/search_list/' , 'Area-L'          )
  , ('2017-01-09 12:18:43', 'cabf98e8', 'view', 'page'  , '/search_input/', ''                )
;

select * from activity_log ;


select 
	session 
	, path 
	, stamp
	-- landingページ（最初にアクセスしたページ）を取得する
	, first_value(path)
		over(partition by session order by stamp asc -- ascは昇順という意味
		-- order byを指定した場合のWINDOW関数のpartitionはデフォルトでは最初の行から現在の行になるので、全行を指定してあげる
		rows between unbounded preceding and unbounded following 
	) as landing
	-- exitページ（最後にアクセスしたページ）を取得する
	, last_value(path)
		over(partition by session order by stamp asc -- ascは昇順という意味
		-- order byを指定した場合のWINDOW関数のpartitionはデフォルトでは最初の行から現在の行になるので、全行を指定してあげる
		rows between unbounded preceding and unbounded following 
	) as exit
from activity_log
;


-- 6.2.2 離脱率と直帰率を計算する
with activity_log_with_exit_flag as (
	select 
		*
		-- 出口ペーじ判定
		, case
			when row_number() over(partition by session order by stamp desc) = 1 then 1
			else 0
		end as is_exit
	from activity_log al 
)
select
	path
	, sum(is_exit) as exit_count
	, count(1) as page_view
	, avg(is_exit) * 100.0 as exit_ratio
from activity_log_with_exit_flag
group by path
;


-- 6.2.3 成果に結びつくページを把握する
select 
	session
	, stamp
	, path
	-- コンバージョンしたページより前のアクセスにフラグを立てる
	, sign(sum(case when path = '/complete' then 1 else 0 end) 
		over(partition by session order by stamp desc
		rows between unbounded preceding and current row))
		as has_conversion
from activity_log al
order by session, stamp;


-- 6.2.4.1 ページの価値を割り振る
with activity_log_with_session_conversion_flag as (
	select 
		session
		, stamp
		, path
		-- コンバージョンしたページより前のアクセスにフラグを立てる
		, sign(sum(case when path = '/complete' then 1 else 0 end) 
			over(partition by session order by stamp desc
			rows between unbounded preceding and current row))
			as has_conversion
	from activity_log al
	order by session, stamp
)
select
	session
	, stamp
	, path
	-- コンバージョンに至るアクセスログに昇順で番号を振る
	, row_number() over(partition by session order by stamp asc) as asc_order
	-- コンバージョンに至るアクセスログに降順で番号を振る
	, row_number() over(partition by session order by stamp desc) as desc_order
	-- コンバージョンに至るアクセスログの数をカウントする
	, count(1) over(partition by session) as page_count
	-- 1.コンバージョンに至るアクセスログに均等に価値を割り振る
	, 1000.0 * count(1) over(partition by session) as fair_assign
	-- 2.コンバージョンに至るアクセスログの最初のページに価値を割りふる
	, case 
		when row_number() over(partition by session order by stamp asc) = 1
			then 1000.0
		else 0.0
	end as first_assign
	-- 3.コンバージョンに至るアクセスログの最後のページに価値を割りふる
	, case 
		when row_number() over(partition by session order by stamp desc) = 1
			then 1000.0
		else 0.0
	end as last_assign
	-- 4.コンバージョンに至るアクセスログの成果地点から近いページにより高く価値を割り振る
	, 1000.0
		* row_number() over(partition by session order by stamp asc)
		-- 連番の合計値で割る(N * (N + 1) / 2)（等差数列の和）
		/ (count(1) over(partition by session)
			* (count(1) over(partition by session) + 1)
		/ 2) as decrease_assign
from activity_log_with_session_conversion_flag
where -- コンバージョンにつながるセッションのログのみを抽出
	has_conversion = 1
	-- 入力、完了、確認ページはページ価値を計算しない
	and path not in ('/input', '/confirm', '/complete')
	;






























