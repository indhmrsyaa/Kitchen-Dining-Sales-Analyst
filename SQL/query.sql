--- KPI 

SELECT SUM(total_sales) AS Total_revenue
    FROM `toko_peralatan_dapur.orders` 
    WHERE status_clean = 'complete';

SELECT COUNT(order_id) AS total_order
    FROM `toko_peralatan_dapur.orders` 
    WHERE status_clean = 'complete';

SELECT AVG(total_sales) AS Average_revenue
    FROM `toko_peralatan_dapur.orders` 
    WHERE status_clean = 'complete';

-- ONGKIR TERMAHAL DAN TERMURAH BERDASRAKAN KOTA

WITH  perkota AS (SELECT city_clean, avg(shipping_fee) as ratarata_ongkir FROM `toko_peralatan_dapur.orders` GROUP BY city_clean)

SELECT 
(SELECT city_clean FROM perkota ORDER BY ratarata_ongkir DESC LIMIT 1) AS kota_ongkirmahal,
(SELECT MAX(ratarata_ongkir) FROM perkota) AS ongkir_mahal,
(SELECT city_clean FROM perkota ORDER BY ratarata_ongkir ASC LIMIT 1) AS kota_ongkirmurah,
(SELECT MIN(ratarata_ongkir) FROM perkota) as ongkir_murah,
(SELECT MAX(ratarata_ongkir) - MIN(ratarata_ongkir) FROM perkota) as selisih_ongkir;

-- TOTAL TRANSAKSI COMPLETE
SELECT COUNT(*) AS jml from `toko_peralatan_dapur.orders` WHERE status ='completed';

-- TOTAL TRANSAKSI DAN SALES UNTUK STATUS REFUND
SELECT status, sum(total) as total_rupiah_refund from `toko_peralatan_dapur.orders` where status = 'refund' GROUP BY status;


SELECT sum(total_sales) as gross_sales_setahun, SUM(case when status = 'refund' THEN total_sales ELSE 0 END) AS totalsales_refund, SUM(case when status = 'refund' THEN total_sales ELSE 0 END)/sum(total_sales) * 100 AS persentase FROM `toko_peralatan_dapur.orders`;

-- 5 PRODUK TERLARIS BERDASARKAN TOTAL ORDER ---
SELECT product_name, ROUND (avg (quantity), 2)  as avg_perpesanan, COUNT(*) AS total_pesanan_complete  FROM `toko_peralatan_dapur.orders` WHERE  status = 'completed' GROUP BY product_name HAVING COUNT(*) >= 50 ORDER BY avg_perpesanan DESC LIMIT 5;

with monthly_sales as (
  SELECT 
  DATE_TRUNC(sales_date, MONTH) as Month,
  sum (total_sales) as total_revenue
  FROM `toko_peralatan_dapur.orders` 
  WHERE status_clean = 'complete' 
  GROUP BY Month
)

-- TOTAL REVENUE AND RANKING BY MONTH
SELECT * from monthly_sales
ORDER BY Month;


with monthly_sales as (
  SELECT 
  DATE_TRUNC(sales_date, MONTH) as Month,
  sum (total_sales) as total_revenue
  FROM `toko_peralatan_dapur.orders` 
  WHERE status_clean = 'complete' 
  GROUP BY Month
),

RN AS (
     SELECT *, ROW_NUMBER() OVER (ORDER BY monthly_sales.total_revenue DESC) AS Rank_sales
     from monthly_sales
)

SELECT * from RN;



-- TOP CATEGORY BY REVENUE

SELECT category, SUM(total_sales) AS revenue 
FROM `toko_peralatan_dapur.orders`  
WHERE status = 'completed' 
GROUP BY category 
ORDER BY revenue DESC 
LIMIT 1;

-- RANKIMG CATEGORY BY REVENUE

WITH prod AS ( 
SELECT category, product_name, SUM(total_sales) AS revenue 
FROM `toko_peralatan_dapur.orders` 
WHERE status = 'completed' 
GROUP BY category, product_name ) 
SELECT category, product_name, revenue, ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS ranking 
FROM prod 
QUALIFY ranking = 1;

-- JUMLAH NORMAL TRANSAKSI DAN BIG TRANSAKSI

SELECT
  COUNTIF(total_sales <= 1000000) AS Jumlah_transaksi_normal,
  COUNTIF(total_sales > 1000000) AS Jumlah_transaksi_big
FROM `toko_peralatan_dapur.orders`
WHERE status_clean = 'complete';

-- REVENUE PER KOTA

SELECT city_clean, 
      SUM(total_sales) AS revenue
FROM `toko_peralatan_dapur.orders`
GROUP BY city_clean ORDER BY revenue;

