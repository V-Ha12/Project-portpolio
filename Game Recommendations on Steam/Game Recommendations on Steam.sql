--I. DATA PREPARATION
--1. Check the number of rows and columns in each table.
SELECT 'GAMES' AS table_name, COUNT(*) AS total_rows FROM GAMES
UNION ALL
SELECT 'RECOMMENDATIONS', COUNT(*) FROM RECOMMENDATIONS
UNION ALL
SELECT 'USERS', COUNT(*) FROM USERS;

--2. Check for NULL values in the tables.
SELECT 
    SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS null_titles,
    SUM(CASE WHEN date_release IS NULL THEN 1 ELSE 0 END) AS null_dates
FROM GAMES;

--3. Handle excessive whitespace.
UPDATE GAMES SET title = TRIM(title);

--4. Create a column for the total number of reviews per user.
ALTER TABLE USERS ADD COLUMN total_reviews INT;
UPDATE USERS 
SET total_reviews = (SELECT COUNT(*) FROM RECOMMENDATIONS WHERE USERS.user_id = RECOMMENDATIONS.user_id);

--5. Identify users who submitted duplicate reviews for the same game and remove the older review.
SELECT user_id, app_id, COUNT(*) 
FROM RECOMMENDATIONS 
GROUP BY user_id, app_id 
HAVING COUNT(*) > 1;

DELETE R1 
FROM RECOMMENDATIONS R1
JOIN RECOMMENDATIONS R2 
ON R1.user_id = R2.user_id AND R1.app_id = R2.app_id
WHERE R1.date < R2.date;

--II. DATA ANALYSIS
--1. Aggregate the number of games by platform.
SELECT 
    SUM(CASE WHEN win = 1 THEN 1 ELSE 0 END) AS Windows_Games,
    SUM(CASE WHEN mac = 1 THEN 1 ELSE 0 END) AS Mac_Games,
    SUM(CASE WHEN linux = 1 THEN 1 ELSE 0 END) AS Linux_Games
FROM GAMES;

--2. Calculate the average game price.
SELECT 
    AVG(price_final) AS avg_final_price, 
    AVG(price_original) AS avg_original_price
FROM GAMES;

--3. Top 10 games with the highest total playtime before review.
SELECT TOP 10 G.title, SUM(R.hours) AS total_hours
FROM RECOMMENDATIONS R
JOIN GAMES G ON R.app_id = G.app_id
GROUP BY G.title
ORDER BY total_hours DESC;

--4. Identify the users with the most "Helpful" reviews.
SELECT TOP 10 user_id, SUM(helpful) AS total_helpful_votes
FROM RECOMMENDATIONS
GROUP BY user_id
ORDER BY total_helpful_votes DESC;

--5. Calculate the average number of games reviewed per user.
SELECT 
    AVG(reviews) AS avg_reviews_per_user
FROM USERS;

--6. Analyze the recommendation rate of games.
SELECT 
    is_recommended, 
    COUNT(*) AS total_reviews
FROM RECOMMENDATIONS
GROUP BY is_recommended;

--7. Analyze the relationship between playtime and review ratings.
SELECT 
    is_recommended, 
    AVG(hours) AS avg_hours_played
FROM RECOMMENDATIONS
GROUP BY is_recommended;



