# Business questions and Answers:

**1. Which games are the most popular based on the number of reviews?**
````sql
SELECT g.title, COUNT(r.review_id) AS total_reviews
FROM GAMES g
JOIN RECOMMENDATIONS r ON g.app_id = r.app_id
GROUP BY g.title
ORDER BY total_reviews DESC
LIMIT 10;
````

--2. Which game has the biggest discount?
SELECT title, price_original, price_final, discount
FROM GAMES
ORDER BY discount DESC
LIMIT 10;

--3. Which game is supported on the most operating systems?
SELECT title, (win + mac + linux) AS total_platforms
FROM GAMES
ORDER BY total_platforms DESC
LIMIT 10;

--4. Which newly released game has received the most positive reviews?
SELECT g.title, g.date_release, COUNT(r.review_id) AS total_reviews, g.positive_ratio
FROM GAMES g
JOIN RECOMMENDATIONS r ON g.app_id = r.app_id
WHERE g.date_release > DATEADD(YEAR, -1, GETDATE())  -- Game phát hành trong 1 năm qua
GROUP BY g.title, g.date_release, g.positive_ratio
HAVING COUNT(r.review_id) > 100  -- Chỉ lấy game có hơn 100 đánh giá
ORDER BY g.positive_ratio DESC, total_reviews DESC
LIMIT 10;

--5. Which game has a high number of players but still receives low ratings?
SELECT g.title, g.positive_ratio, COUNT(r.review_id) AS total_reviews
FROM GAMES g
JOIN RECOMMENDATIONS r ON g.app_id = r.app_id
WHERE g.positive_ratio < 50  -- Chỉ lấy game có đánh giá dưới 50%
GROUP BY g.title, g.positive_ratio
HAVING COUNT(r.review_id) > 500  -- Phải có ít nhất 500 lượt đánh giá
ORDER BY total_reviews DESC
LIMIT 10;

--6. What is the trend of game reviews over time?
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

--7. Which user has the longest playtime but the fewest reviews (a "silent" gamer)?
SELECT r.user_id, SUM(r.hours) AS total_hours_played, COUNT(r.review_id) AS total_reviews
FROM RECOMMENDATIONS r
GROUP BY r.user_id
HAVING COUNT(r.review_id) < 5  -- Ít hơn 5 đánh giá
ORDER BY total_hours_played DESC
LIMIT 10;

--8. Is there any notable relationship between game price and average playtime?
SELECT 
    CASE 
        WHEN price_final = 0 THEN 'Free'
        WHEN price_final BETWEEN 0.01 AND 10 THEN 'Cheap ($0.01 - $10)'
        WHEN price_final BETWEEN 10.01 AND 30 THEN 'Mid-range ($10.01 - $30)'
        WHEN price_final > 30 THEN 'Expensive ($30+)'
    END AS price_category,
    AVG(r.hours) AS avg_playtime
FROM GAMES g
JOIN RECOMMENDATIONS r ON g.app_id = r.app_id
GROUP BY 
    CASE 
        WHEN price_final = 0 THEN 'Free'
        WHEN price_final BETWEEN 0.01 AND 10 THEN 'Cheap ($0.01 - $10)'
        WHEN price_final BETWEEN 10.01 AND 30 THEN 'Mid-range ($10.01 - $30)'
        WHEN price_final > 30 THEN 'Expensive ($30+)'
    END
ORDER BY avg_playtime DESC;


