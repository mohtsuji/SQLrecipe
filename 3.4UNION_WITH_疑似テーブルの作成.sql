-- 3.4.1 テーブルを結合する
DROP TABLE IF EXISTS app1_mst_users;
CREATE TABLE app1_mst_users (
    user_id varchar(255)
  , name    varchar(255)
  , email   varchar(255)
);

INSERT INTO app1_mst_users
VALUES
    ('U001', 'Sato'  , 'sato@example.com'  )
  , ('U002', 'Suzuki', 'suzuki@example.com')
;

DROP TABLE IF EXISTS app2_mst_users;
CREATE TABLE app2_mst_users (
    user_id varchar(255)
  , name    varchar(255)
  , phone   varchar(255)
);

INSERT INTO app2_mst_users
VALUES
    ('U001', 'Ito'   , '080-xxxx-xxxx')
  , ('U002', 'Tanaka', '070-xxxx-xxxx')
;

select * from app1_mst_users ;
select * from app2_mst_users ;

-- 3.4.1.1 UNION ALLでテーブルを行結合する（UNION DISTINCTは重複する行を削除して結合する）
-- 片方にしか存在しない行は結合できないので除外（Phone）する、またはNULLにする（email）
-- 元データがどちらのテーブルなのかわかりやすいようにapp_name列を追加する
select 'app1' as app_name, user_id, name, email from app1_mst_users 
union all
select 'app2' as app_name, user_id, name, null as email from app2_mst_users ;


-- 3.4.2 複数のテーブルを列結合する
DROP TABLE IF EXISTS mst_categories;
CREATE TABLE mst_categories (
    category_id integer
  , name        varchar(255)
);
INSERT INTO mst_categories
VALUES
    (1, 'dvd' )
  , (2, 'cd'  )
  , (3, 'book')
;
DROP TABLE IF EXISTS category_sales;
CREATE TABLE category_sales (
    category_id integer
  , sales       integer
);
INSERT INTO category_sales
VALUES
    (1, 850000)
  , (2, 500000)
;
DROP TABLE IF EXISTS product_sale_ranking;
CREATE TABLE product_sale_ranking (
    category_id integer
  , rank        integer
  , product_id  varchar(255)
  , sales       integer
);
INSERT INTO product_sale_ranking
VALUES
    (1, 1, 'D001', 50000)
  , (1, 2, 'D002', 20000)
  , (1, 3, 'D003', 10000)
  , (2, 1, 'C001', 30000)
  , (2, 2, 'C002', 20000)
  , (2, 3, 'C003', 10000)
;

select * from mst_categories ;
select * from category_sales  ;
select * from product_sale_ranking ;

-- 3.4.2.2 LEFT JOIN
select
	m.category_id
	, m.name
	, s.sales
	, r.product_id as top_sale_product
from 
	mst_categories as m
left join
	category_sales as s 
	on m.category_id = s.category_id
left join -- salesのランキングが1位の行のみ結合する
	product_sale_ranking as r 
	on m.category_id = r.category_id
	and r.rank = 1
;


-- 3.4.2.3 相関サブクエリで列結合する3.4.2.2と同じ形になるように結合する
select 
	m.category_id
	, m.name
	-- 相関サブクエリでカテゴリー別の売上額を取得
	--（相関サブクエリ内でidを=で繋いでも、LEFT JOIN同様にマスタデータのidが減ったりはしない）
	, (select s.sales from category_sales as s where m.category_id = s.category_id)
	, (select r.product_id from product_sale_ranking as r 
		where m.category_id = r.category_id
		order by sales desc
		limit 1)
from mst_categories as m;


-- 3.4.4 条件フラグを0, 1で表現する
DROP TABLE IF EXISTS mst_users_with_card_number;
CREATE TABLE mst_users_with_card_number (
    user_id     varchar(255)
  , card_number varchar(255)
);
INSERT INTO mst_users_with_card_number
VALUES
    ('U001', '1234-xxxx-xxxx-xxxx')
  , ('U002', NULL                 )
  , ('U003', '5678-xxxx-xxxx-xxxx')
;
DROP TABLE IF EXISTS purchase_log;
CREATE TABLE purchase_log (
    purchase_id integer
  , user_id     varchar(255)
  , amount      integer
  , stamp       varchar(255)
);
INSERT INTO purchase_log
VALUES
    (10001, 'U001', 200, '2017-01-30 10:00:00')
  , (10002, 'U001', 500, '2017-02-10 10:00:00')
  , (10003, 'U001', 200, '2017-02-12 10:00:00')
  , (10004, 'U002', 800, '2017-03-01 10:00:00')
  , (10005, 'U002', 400, '2017-03-02 10:00:00')
;

select * from mst_users_with_card_number ;
select * from purchase_log  ;

-- 3.4.3.1 カードの登録と購入履歴の有無を0,1のフラグで表現する
select 
	m.user_id
	, m.card_number
	, count(p.user_id) as purchase_count
	-- カード番号の登録がある場合は1, ない場合は0
	, case when m.card_number is not null then 1 else 0 end as has_catd
	-- 購入履歴がある場合は1, ない場合は0（purchase_logにuser_idが存在する＝購入履歴がある）
	, sign(count(p.user_id)) as has_purchased  --sign関数は引数が正の値なら1, 0なら0, 負の値なら-1を返す
from mst_users_with_card_number as m
left join
	purchase_log as p
	on m.user_id = p.user_id
group by m.user_id, m.card_number
;


--WITHを利用して可読性を向上させる
DROP TABLE IF EXISTS product_sales;
CREATE TABLE product_sales (
    category_name varchar(255)
  , product_id    varchar(255)
  , sales         integer
);
INSERT INTO product_sales
VALUES
    ('dvd' , 'D001', 50000)
  , ('dvd' , 'D002', 20000)
  , ('dvd' , 'D003', 10000)
  , ('cd'  , 'C001', 30000)
  , ('cd'  , 'C002', 20000)
  , ('cd'  , 'C003', 10000)
  , ('book', 'B001', 20000)
  , ('book', 'B002', 15000)
  , ('book', 'B003', 10000)
  , ('book', 'B004',  5000)
;
select * from product_sales;

-- 3.4.4.1 カテゴリーごとの順位を付与したテーブルに名前をつける
with product_sale_ranking as (
	select 
		category_name
		, product_id
		, sales
		, row_number() over(partition by category_name order by sales desc) as rank 
	from product_sales
)
select * from product_sale_ranking
;

-- 3.4.4.1 カテゴリーごとのランキングからユニークな順位の一覧を計算する
-- （各カテゴリの中で最も商品数が多いものの商品数を数える）
with product_sale_ranking as (
	select 
		category_name
		, product_id
		, sales
		, row_number() over(partition by category_name order by sales desc) as rank 
	from product_sales
)
select distinct 
	rank 
from product_sale_ranking
;

-- 3.4.4.3 行をランキングにして各カテゴリの売上を横データで表示する
with product_sale_ranking as (
	select 
		category_name
		, product_id
		, sales
		, row_number() over(partition by category_name order by sales desc) as rank 
	from product_sales
), mst_rank as (
	select distinct 
		rank 
	from product_sale_ranking
)
select
	m.rank
	, r1.product_id as dvd
	, r1.sales as dvd_sales
	, r2.product_id as cd
	, r2.sales as cd_sales
	, r3.product_id as book
	, r3.sales as book_sales
from mst_rank as m
left join
	product_sale_ranking as r1 
	on m.rank = r1.rank
	and r1.category_name = 'dvd'
left join
	product_sale_ranking as r2 
	on m.rank = r2.rank
	and r2.category_name = 'cd'
left join
	product_sale_ranking as r3 
	on m.rank = r3.rank
	and r3.category_name = 'book'
order by m.rank
;


-- 3.4.5 擬似的なテーブルを作成する

-- 3.4.5.1 デバイスのIDと名前のマスタデータを作成するクエリ
with mst_devices as (
	select 1 as device_id, 'PC' as device_name
	union all select 2 as device_id, 'SP' as device_name
	union all select 3 as device_id, 'アプリ' as device_name
)
select * from mst_devices;

-- 3.4.5.2 擬似的なテーブルを用いてコードをラベルに置き換える
with mst_devices as (
	select 1 as device_id, 'PC' as device_name
	union all select 2 as device_id, 'SP' as device_name
	union all select 3 as device_id, 'アプリ' as device_name
)
select 
	u.user_id
	, d.device_name
from mst_users u 
left join
	mst_devices as d 
	on u.register_device  = d.device_id
;


-- 3.4.5.3 VALUES句を用いた疑似テーブルの作成
with
mst_devices(device_id, device_name) as (
	values
		(1, 'PC')
		,(2, 'SC')
		,(3, 'アプリ')
)
select * from mst_devices;


-- 3.4.5.6 連番を持つ疑似テーブルを作成するクエリ
with
series as (
	-- 1から5までの連番を作成する
	select generate_series(1,5) as idx
)
select * from series;

