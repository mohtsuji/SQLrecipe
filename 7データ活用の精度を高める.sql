-- 7.1.2.1 隣接都道府県マスタを用いて宿泊先をカテゴライズするクエリ
DROP TABLE IF EXISTS neighbor_pref; 
CREATE TABLE neighbor_pref(
    pref_id             integer
  , pref_name           varchar(255)
  , neighbor_pref_id    integer
  , neighbor_pref_name  varchar(255)
);
INSERT INTO neighbor_pref
VALUES
    (1, '北海道', 2, '青森県')
  , (2, '青森県', 1, '北海道')
  , (2, '青森県', 3, '岩手県')
  , (2, '青森県', 5, '秋田県')
  , (3, '岩手県', 2, '青森県')
  , (3, '岩手県', 4, '宮城県')
  , (3, '岩手県', 5, '秋田県')
;
DROP TABLE IF EXISTS reservations;
CREATE TABLE reservations(
    rsv_id            integer
  , stamp             varchar(255)
  , member_id         integer
  , member_pref_id    integer
  , member_pref_name  varchar(255)
  , spot_id           integer
  , spot_pref_id      integer
  , spot_pref_name    varchar(255)
);
INSERT INTO reservations
VALUES
    (27414, '2016-12-31 07:36:48', 50063, 21, '岐阜県', 4454, 47, '沖縄県')
  , (27415, '2016-12-31 15:34:21', 43065, 19, '山梨県', 4899, 27, '大阪府')
  , (27416, '2016-12-31 16:05:10', 31038, 6 , '山形県', 7839, 15, '新潟県')
  , (27417, '2016-12-31 17:48:57', 53901, 34, '広島県', 1972, 4 , '宮城県')
  , (27418, '2016-12-31 23:24:33', 54998, 12, '千葉県', 2227, 3 , '岩手県')
  , (27419, '2017-01-01 02:43:20', 34078, 47, '沖縄県', 5522, 12, '千葉県')
  , (27420, '2017-01-01 05:06:10', 53307, 26, '京都府', 6559, 12, '千葉県')
  , (27421, '2017-01-01 08:37:36', 35423, 24, '三重県', 5500, 20, '長野県')
;
select * from neighbor_pref ; -- 隣接している都道府県のみ都道府県番号を突き合わせている
select * from reservations ;

select 
	r.rsv_id
	, r.member_id
	, r.member_pref_name
	, r.spot_pref_name
	-- 宿泊先の都道府県IDが、利用者の居住地か、隣接都道府県マスタに一致するかで場合分け
	, case r.spot_pref_id
		when r.member_pref_id then '同一都道府県'
		when n.neighbor_pref_id then '隣接都道府県'
		else '遠方都道府県'
	end as category
from reservations as r
left join neighbor_pref as n 
	-- 都道府県マスタは、pref_idとneightbor_pref_idで一意になっているものとする
	on r.member_pref_id = n.pref_id
	and r.spot_pref_id = n.neighbor_pref_id
;

select 
	 *
from reservations as r
left join neighbor_pref as n 
	-- 都道府県マスタは、pref_idとneightbor_pref_idで一意になっているものとする
	on r.member_pref_id = n.pref_id
	and r.spot_pref_id = n.neighbor_pref_id
;


-- 7.2.1.1 セッションあたりのページ数閲覧数ランキングを割合で表示するクエリ
DROP TABLE IF EXISTS action_log_with_noise;
CREATE TABLE action_log_with_noise(
    stamp       varchar(255)
  , session     varchar(255)
  , action      varchar(255)
  , products    varchar(255)
  , url         text
  , ip          varchar(255)
  , user_agent  text
);
INSERT INTO action_log_with_noise
VALUES
  ('2016-11-03 18:00:00', '1b700', 'view'    , ''    , 'http://www.example.com/detail?id=1', '98.139.183.24' , 'Mozilla/5.0 (compatible; Bingbot/2.0; +http://www.bing.com/bingbot.htm)'                                                 )
, ('2016-11-03 19:00:00', '1b700', 'add_cart', 'D001', 'http://www.example.com/detail?id=2', '98.139.183.24' , 'Mozilla/5.0 (compatible; Bingbot/2.0; +http://www.bing.com/bingbot.htm)'                                                 )
, ('2016-11-03 19:00:00', '1b700', 'purchase', 'D001', 'http://www.example.com/detail?id=2', '98.139.183.24' , 'Mozilla/5.0 (compatible; Bingbot/2.0; +http://www.bing.com/bingbot.htm)'                                                 )
, ('2016-11-03 20:00:00', '0fb22', 'view'    , ''    , 'http://www.example.com/detail?id=3', '210.154.149.63', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/602.3.12 (KHTML, like Gecko) Version/10.0.2 Safari/602.3.12' )
, ('2016-11-03 21:00:00', '0fb22', 'view'    , ''    , 'http://www.example.com/detail?id=1', '210.154.149.63', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/602.3.12 (KHTML, like Gecko) Version/10.0.2 Safari/602.3.12' )
, ('2016-11-04 18:00:00', 'fdb83', 'view'    , ''    , 'http://www.example.com/detail?id=2', '127.0.0.1'     , 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36'       )
, ('2016-11-04 19:00:00', 'fe8df', 'view'    , ''    , 'http://www.example.com/detail?id=3', '192.0.0.10'    , 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 Safari/537.36'            )
, ('2016-11-04 20:00:00', 'fe8df', 'view'    , ''    , 'http://www.example.com/detail?id=1', '192.0.0.10'    , 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 Safari/537.36'            )
, ('2016-11-04 20:00:00', 'fe8df', 'view'    , ''    , 'http://www.example.com/detail?id=1', '192.0.0.10'    , 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 Safari/537.36'            )
, ('2016-11-04 21:00:00', '14bec', 'view'    , ''    , 'http://www.example.com/detail?id=2', '10.0.0.3'      , 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0'                                               )
, ('2016-11-04 22:00:00', '14bec', 'add_cart', ''    , 'http://www.example.com/detail?id=3', '10.0.0.3'      , 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0'                                               )
, ('2016-11-04 22:00:00', '694dd', 'view'    , ''    , 'http://www.example.com/detail?id=1', '172.16.0.5'    , ''                                                                                                                        )
, ('2016-11-04 22:00:00', '7af12', 'view'    , ''    , 'http://www.example.com/detail?id=2', '192.168.0.23'  , 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36')
, ('2016-11-04 22:00:00', '7af12', 'add_cart', 'D002', 'http://www.example.com/detail?id=3', '192.168.0.23'  , 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36')
, ('2016-11-04 22:00:00', '7af12', 'purchase', 'D002', 'http://www.example.com/detail?id=3', '192.168.0.23'  , 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36')
, ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=1', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
, ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=2', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
, ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
, ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=1', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
, ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=2', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
, ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
, ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=1', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
, ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=2', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
, ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
, ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', ''                                                                                                                        )
, ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=1', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
, ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=2', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
, ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
, ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
, ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=4', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
, ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=2', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
, ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
;

select * from action_log_with_noise alwn ;

with session_count as (
	select 
		session 
		, count(1) as count
	from action_log_with_noise alwn 
	group by session
)
select 
	session
	, count
	, rank() over(order by count desc) as rank 
	, percent_rank() over(order by count desc) as percent_rank
from session_count
	;


-- 7.2.2 クローラーを除外する
DROP TABLE IF EXISTS action_log_with_noise;
CREATE TABLE action_log_with_noise(
    stamp       varchar(255)
  , session     varchar(255)
  , action      varchar(255)
  , products    varchar(255)
  , url         text
  , ip          varchar(255)
  , user_agent  text
);
INSERT INTO action_log_with_noise
VALUES
    ('2016-11-03 18:00:00', '1b700', 'view'    , ''    , 'http://www.example.com/detail?id=1', '98.139.183.24' , 'Mozilla/5.0 (compatible; Bingbot/2.0; +http://www.bing.com/bingbot.htm)'                                                 )
  , ('2016-11-03 19:00:00', '1b700', 'add_cart', 'D001', 'http://www.example.com/detail?id=2', '98.139.183.24' , 'Mozilla/5.0 (compatible; Bingbot/2.0; +http://www.bing.com/bingbot.htm)'                                                 )
  , ('2016-11-03 19:00:00', '1b700', 'purchase', 'D001', 'http://www.example.com/detail?id=2', '98.139.183.24' , 'Mozilla/5.0 (compatible; Bingbot/2.0; +http://www.bing.com/bingbot.htm)'                                                 )
  , ('2016-11-03 20:00:00', '0fb22', 'view'    , ''    , 'http://www.example.com/detail?id=3', '210.154.149.63', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/602.3.12 (KHTML, like Gecko) Version/10.0.2 Safari/602.3.12' )
  , ('2016-11-03 21:00:00', '0fb22', 'view'    , ''    , 'http://www.example.com/detail?id=1', '210.154.149.63', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/602.3.12 (KHTML, like Gecko) Version/10.0.2 Safari/602.3.12' )
  , ('2016-11-04 18:00:00', 'fdb83', 'view'    , ''    , 'http://www.example.com/detail?id=2', '127.0.0.1'     , 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36'       )
  , ('2016-11-04 19:00:00', 'fe8df', 'view'    , ''    , 'http://www.example.com/detail?id=3', '192.0.0.10'    , 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 Safari/537.36'            )
  , ('2016-11-04 20:00:00', 'fe8df', 'view'    , ''    , 'http://www.example.com/detail?id=1', '192.0.0.10'    , 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 Safari/537.36'            )
  , ('2016-11-04 20:00:00', 'fe8df', 'view'    , ''    , 'http://www.example.com/detail?id=1', '192.0.0.10'    , 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 Safari/537.36'            )
  , ('2016-11-04 21:00:00', '14bec', 'view'    , ''    , 'http://www.example.com/detail?id=2', '10.0.0.3'      , 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0'                                               )
  , ('2016-11-04 22:00:00', '14bec', 'add_cart', ''    , 'http://www.example.com/detail?id=3', '10.0.0.3'      , 'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0'                                               )
  , ('2016-11-04 22:00:00', '694dd', 'view'    , ''    , 'http://www.example.com/detail?id=1', '172.16.0.5'    , ''                                                                                                                        )
  , ('2016-11-04 22:00:00', '7af12', 'view'    , ''    , 'http://www.example.com/detail?id=2', '192.168.0.23'  , 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36')
  , ('2016-11-04 22:00:00', '7af12', 'add_cart', 'D002', 'http://www.example.com/detail?id=3', '192.168.0.23'  , 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36')
  , ('2016-11-04 22:00:00', '7af12', 'purchase', 'D002', 'http://www.example.com/detail?id=3', '192.168.0.23'  , 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36')
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=1', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=2', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=1', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=2', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=1', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=2', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', ''                                                                                                                        )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=1', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=2', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=4', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=2', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
  , ('2016-11-04 22:00:00', 'c33fb', 'view'    , ''    , 'http://www.example.com/detail?id=3', '216.58.220.238', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'                                                )
;

select * from action_log_with_noise alwn ;

with
mst_bot_user_agent(rule) as (
	values
	('%bot%')
	, ('%crawler%')
	, ('%spider%')
	, ('%archiver%')
)
, filtered_action_log as (
	select 
		l.stamp 
		, l.session
		, l.action
		, l.products 
		, l.url 
		, l.ip 
		, l.user_agent
	from action_log_with_noise as l
	where 
		not exists (
			select 1
			from mst_bot_user_agent as m
			where l.user_agent like m.rule
		) 
)
select *
from filtered_action_log
;


-- 7.3.1.2 キーが重複しているレコードを確認する
DROP TABLE IF EXISTS mst_categories;
CREATE TABLE mst_categories(
    id     integer
  , name   varchar(255)
  , stamp  varchar(255)
);
INSERT INTO mst_categories
VALUES
    (1, 'ladys_fashion', '2016-01-01 10:00:00')
  , (2, 'mens_fashion' , '2016-01-01 10:00:00')
  , (3, 'book'         , '2016-01-01 10:00:00')
  , (4, 'game'         , '2016-01-01 10:00:00')
  , (5, 'dvd'          , '2016-01-01 10:00:00')
  , (6, 'food'         , '2016-01-01 10:00:00')
  , (7, 'supplement'   , '2016-01-01 10:00:00')
  , (6, 'cooking'      , '2016-02-01 10:00:00')
;
select * from mst_categories ;

select 
	id
	, count(*) as record_num
	-- データを配列に集約し、カンマ区切りの文字列に変換
	, string_agg(name, ',') as name_list
from mst_categories 
group by id
-- キーが２つ以上あるレコードに絞り込む
having count(*) > 1
;


-- 7.4.1.1 追加されたマスタデータを抽出するクエリ
DROP TABLE IF EXISTS mst_products_20161201;
CREATE TABLE mst_products_20161201(
    product_id  varchar(255)
  , name        varchar(255)
  , price       integer
  , updated_at  varchar(255)
);
INSERT INTO mst_products_20161201
VALUES
    ('A001', 'AAA', 300, '2016-11-03 18:00:00')
  , ('A002', 'AAB', 400, '2016-11-03 19:00:00')
  , ('B001', 'BBB', 500, '2016-11-03 20:00:00')
  , ('B002', 'BBD', 300, '2016-11-03 21:00:00')
  , ('C001', 'CCA', 400, '2016-11-04 18:00:00')
  , ('D001', 'DAA', 500, '2016-11-04 19:00:00')
;
DROP TABLE IF EXISTS mst_products_20170101;
CREATE TABLE mst_products_20170101(
    product_id  varchar(255)
  , name        varchar(255)
  , price       integer
  , updated_at  varchar(255)
);
INSERT INTO mst_products_20170101
  VALUES
    ('A001', 'AAA', 300, '2016-11-03 18:00:00')
  , ('A002', 'AAB', 400, '2016-11-03 19:00:00')
  , ('B002', 'BBD', 300, '2016-11-03 21:00:00')
  , ('C001', 'CCA', 500, '2016-12-04 18:00:00')
  , ('D001', 'DAA', 500, '2016-11-04 19:00:00')
  , ('D002', 'DAD', 500, '2016-12-04 19:00:00')
;

select * from mst_products_20161201 ;
select * from mst_products_20170101;

-- left join でNULLになったレコードが新しいレコード
select
	new_mst.*
from mst_products_20170101 as new_mst
left join mst_products_20161201  as old_mst
	on new_mst.product_id = old_mst.product_id
where old_mst.product_id is null
;


-- 7.4.1.4 変更されたマスタデータをすべて抽出するクエリ

-- coalesceは最初に見つかったNULLではない値を返す
select 
	new_mst.product_id as new_product_id
	, old_mst.product_id as old_product_id
	, coalesce (new_mst.product_id, old_mst.product_id) as product_id
	, coalesce (new_mst.name, old_mst.name) as name
	, coalesce (new_mst.price, old_mst.price) as price
	, coalesce (new_mst.updated_at, old_mst.updated_at) as updated_at
	, case 
		when old_mst.updated_at is null then 'added'
		when new_mst.updated_at is null then 'deleted'
		when new_mst.updated_at != old_mst.updated_at then 'updated'
	end as status
from mst_products_20170101 as new_mst
-- full outer joinはどちらかのテーブルにしか含まれないデータはNULLにしてすべて結合してくれる
full outer join mst_products_20161201  as old_mst
	on new_mst.product_id = old_mst.product_id
-- is distinct from を使用すれば、片方がNULLでも正しく比較してくれる
where new_mst.updated_at is distinct from old_mst.updated_at
;


-- 7.4.2.1 ３つの指標に基づくランキングを作成するクエリ
DROP TABLE IF EXISTS access_log;
CREATE TABLE access_log(
    stamp          varchar(255)
  , short_session  varchar(255)
  , long_session   varchar(255)
  , path           varchar(255)
);
INSERT INTO access_log
VALUES
    ('2016-10-01 12:00:00', '0CVKaz', '1CwlSX', '/detail')
  , ('2016-10-01 13:00:00', '0CVKaz', '1CwlSX', '/detail')
  , ('2016-10-01 13:00:00', '1QceiB', '3JMO2k', '/search')
  , ('2016-10-01 14:00:00', '1QceiB', '3JMO2k', '/detail')
  , ('2016-10-01 15:00:00', '1hI43A', '6SN6DD', '/search')
  , ('2016-10-01 16:00:00', '1hI43A', '6SN6DD', '/detail')
  , ('2016-10-01 17:00:00', '2bGs3i', '1CwlSX', '/top'   )
  , ('2016-10-01 18:00:00', '2is8PX', '7Dn99b', '/search')
  , ('2016-10-02 12:00:00', '2mmGwD', 'EFnoNR', '/top'   )
  , ('2016-10-02 13:00:00', '2mmGwD', 'EFnoNR', '/detail')
  , ('2016-10-02 14:00:00', '3CEHe1', 'FGkTe9', '/search')
  , ('2016-10-02 15:00:00', '3Gv8vO', '1CwlSX', '/detail')
  , ('2016-10-02 16:00:00', '3cv4gm', 'KBlKgT', '/top'   )
  , ('2016-10-02 17:00:00', '3cv4gm', 'KBlKgT', '/search')
  , ('2016-10-02 18:00:00', '690mvB', 'FGkTe9', '/top'   )
  , ('2016-10-03 12:00:00', '6oABhM', '3JMO2k', '/detail')
  , ('2016-10-03 13:00:00', '7jjxQX', 'KKTw9P', '/top'   )
  , ('2016-10-03 14:00:00', 'AAuoEU', '6SN6DD', '/top'   )
  , ('2016-10-03 15:00:00', 'AAuoEU', '6SN6DD', '/search')
;
select * from access_log al ;

with
path_stat as (
	-- パス別の訪問回数、訪問者数、ページビューを計算する
	select 
		path 
		, count(distinct long_session) as access_users
		, count(distinct short_session) as access_count
		, count(*) as page_view
	from access_log al 
	group by path
)
, path_ranking as (
	-- 訪問回数、訪問者数、ページビューごとにrankingを作成する
	select 'access_user' as type, path, rank() over(order by access_users desc) as rank from path_stat
	union all
	select 'access_count' as type, path, rank() over(order by access_count desc) as rank from path_stat
	union all
	select 'page_view' as type, path, rank() over(order by page_view desc) as rank from path_stat
)
select
	*
from path_ranking
order by type, rank
;

-- スペアマンの順位相関係数でランキングの近さを計算する
with
path_stat as (
	-- パス別の訪問回数、訪問者数、ページビューを計算する
	select 
		path 
		, count(distinct long_session) as access_users
		, count(distinct short_session) as access_count
		, count(*) as page_view
	from access_log al 
	group by path
)
, path_ranking as (
	-- 訪問回数、訪問者数、ページビューごとにrankingを作成する
	select 'access_user' as type, path, rank() over(order by access_users desc) as rank from path_stat
	union all
	select 'access_count' as type, path, rank() over(order by access_count desc) as rank from path_stat
	union all
	select 'page_view' as type, path, rank() over(order by page_view desc) as rank from path_stat
)
, pair_ranking as (
	-- パスごとに２つのタイプの組み合わせを作成する（3*3*3で27パターンできるはず）
	select
		r1.path
		, r1.type as type1
		, r1.rank as rank1
		, r2.type as type2
		, r2.rank as rank2
		-- ランキング順位の差を計算する(差分を２乗する)
		, power(r1.rank - r2.rank, 2) as diff
	from path_ranking as r1
	inner join path_ranking as r2
		on r1.path = r2.path
)
select 
	type1
	, type2
	, 1 - (6.0 * sum(diff) / (power(count(1), 3) - count(1))) as spearman
from pair_ranking
group by type1, type2
order by type1, spearman desc 
		;


