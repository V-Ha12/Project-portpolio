--1. Lấy danh sách các game phổ biến nhất dựa trên số lượng đánh giá
SELECT g.title, COUNT(r.review_id) AS total_reviews
FROM GAMES g
JOIN RECOMMENDATIONS r ON g.app_id = r.app_id
GROUP BY g.title
ORDER BY total_reviews DESC
LIMIT 10;

--2. So sánh giá giảm và giá gốc để tìm game có mức giảm giá lớn nhất
SELECT title, price_original, price_final, discount
FROM GAMES
ORDER BY discount DESC
LIMIT 10;

--3. Tìm game hỗ trợ nhiều hệ điều hành nhất
SELECT title, (win + mac + linux) AS total_platforms
FROM GAMES
ORDER BY total_platforms DESC
LIMIT 10;

--4. Tìm game mới phát hành nhưng đã có nhiều đánh giá tích cực
SELECT g.title, g.date_release, COUNT(r.review_id) AS total_reviews, g.positive_ratio
FROM GAMES g
JOIN RECOMMENDATIONS r ON g.app_id = r.app_id
WHERE g.date_release > DATEADD(YEAR, -1, GETDATE())  -- Game phát hành trong 1 năm qua
GROUP BY g.title, g.date_release, g.positive_ratio
HAVING COUNT(r.review_id) > 100  -- Chỉ lấy game có hơn 100 đánh giá
ORDER BY g.positive_ratio DESC, total_reviews DESC
LIMIT 10;

--5. Tìm game có số lượng người chơi cao nhưng vẫn bị đánh giá thấp
SELECT g.title, g.positive_ratio, COUNT(r.review_id) AS total_reviews
FROM GAMES g
JOIN RECOMMENDATIONS r ON g.app_id = r.app_id
WHERE g.positive_ratio < 50  -- Chỉ lấy game có đánh giá dưới 50%
GROUP BY g.title, g.positive_ratio
HAVING COUNT(r.review_id) > 500  -- Phải có ít nhất 500 lượt đánh giá
ORDER BY total_reviews DESC
LIMIT 10;

--6. Phân tích xu hướng đánh giá game theo thời gian
WITH MonthlyReviews AS (
    SELECT 
        DATEPART(YEAR, date) AS review_year,
        DATEPART(MONTH, date) AS review_month,
        COUNT(review_id) AS total_reviews
    FROM RECOMMENDATIONS
    GROUP BY DATEPART(YEAR, date), DATEPART(MONTH, date)
), 
Growth AS (
    SELECT 
        review_year, 
        review_month, 
        total_reviews,
        LAG(total_reviews) OVER (ORDER BY review_year, review_month) AS previous_month_reviews,
        (total_reviews - LAG(total_reviews) OVER (ORDER BY review_year, review_month)) * 100.0 / 
        NULLIF(LAG(total_reviews) OVER (ORDER BY review_year, review_month), 0) AS growth_rate
    FROM MonthlyReviews
)
SELECT * FROM Growth ORDER BY review_year DESC, review_month DESC;
