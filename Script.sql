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















