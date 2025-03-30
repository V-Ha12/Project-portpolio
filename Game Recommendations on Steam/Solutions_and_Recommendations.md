# Business questions and Answers:

**1. Which games are the most popular based on the number of reviews?**
````sql
SELECT TOP 10 
    g.title, 
    COUNT(r.review_id) AS total_reviews, 
    g.price_final
FROM GAMES g
JOIN RECOMMENDATIONS r ON g.app_id = r.app_id
GROUP BY g.title, g.price_final
ORDER BY total_reviews DESC;
````
**Results Table 1**
|title|total_reviews|price_final|
|---|---|---|
|Orwell: Keeping an Eye On You|11225|9.99|
|Noitu Love 2: Devolution|297|4.99|
|????|93|0.00|
|Imp of the Sun|34|19.99|
|Them - The Summoning|32|2.99|
|Freddy Spaghetti|27|4.99|
|Bob Help Them|23|1.19|
|Ossuary|17|9.99|
|Grimtale Island|16|2.99|
|Battle Bruise 2|14|4.99|

- Key Questions to Address:
    Does the number of reviews truly reflect a game's popularity?

    Do games with more reviews generate higher revenue?


**2. Which game is supported on the most operating systems?**
````sql
SELECT TOP 10 title,
       (CASE WHEN win = 1 THEN 1 ELSE 0 END +
        CASE WHEN mac = 1 THEN 1 ELSE 0 END +
        CASE WHEN linux = 1 THEN 1 ELSE 0 END) AS total_platforms
FROM GAMES
ORDER BY total_platforms DESC;
````
**Results Table 2**
|title|total_platforms|positive_ratio|
|---|---|---|
|Orwell: Keeping an Eye On You|3|91|
|Singularity: Tactics Arena|2|89|
|Talisman - The Reaper Expansion|2|84|
|Trainz Plus|2|70|
|Field of Glory II: Legions Triumphant|1|100|
|Bob Help Them|1|100|
|Partum Artifex|1|97|
|LOUD: My Road to Fame|1|94|
|Noitu Love 2: Devolution|1|93|
|Freddy Spaghetti|1|90|

- Key Questions to Address:
    Do games that support multiple platforms sell better?




**3. Which games have a high player count but a low positive review rate? What factors (e.g., playtime) influence game review quality?**
````sql
SELECT TOP 10 
       g.title,
       g.positive_ratio,
       COUNT(r.review_id) AS total_reviews,
       AVG(r.hours) AS avg_play_hours
FROM GAMES g
JOIN RECOMMENDATIONS r ON g.app_id = r.app_id
WHERE g.positive_ratio < 50 -- Games with a positive rating below 50%
GROUP BY g.title, g.positive_ratio
HAVING COUNT(r.review_id) > 30 -- Games with at least 30 reviews
ORDER BY total_reviews DESC;
````
**Results Table 3**
|title|total_platforms|positive_ratio|
|---|---|---|
|Orwell: Keeping an Eye On You|3|91|
|Singularity: Tactics Arena|2|89|
|Talisman - The Reaper Expansion|2|84|
|Trainz Plus|2|70|
|Field of Glory II: Legions Triumphant|1|100|
|Bob Help Them|1|100|
|Partum Artifex|1|97|
|LOUD: My Road to Fame|1|94|
|Noitu Love 2: Devolution|1|93|
|Freddy Spaghetti|1|90|

- Slutions
Identify games in the database with a high number of reviews but low ratings, then analyze potential factors such as playtime to understand the underlying reasons.
--> 

**4. What is the trend of game reviews over time?**
````sql
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
````
**Results Table 4**
|review_year|review_month|total_reviews|previous_month_reviews|growth_rate|
|---|---|---|---|---|
|2022|12|51|51|0.000000000000|
|2022|11|51|35|45.714285714285|
|2022|10|35|46|-23.913043478260|
|2022|9|46|44|4.545454545454|
|2022|8|44|66|-33.333333333333|
|2022|7|66|58|13.793103448275|
|2022|6|58|66|-12.121212121212|
|2022|5|66|50|32.000000000000|
|2022|4|50|91|-45.054945054945|
|2022|3|91|101|-9.900990099009|
|2022|2|101|63|60.317460317460|
|2022|1|63|79|-20.253164556962|
|2021|12|79|103|-23.300970873786|
|2021|11|103|65|58.461538461538|
|2021|10|65|122|-46.721311475409|
|2021|9|122|72|69.444444444444|
|2021|8|72|126|-42.857142857142|
|2021|7|126|95|32.631578947368|
|2021|6|95|85|11.764705882352|
|2021|5|85|84|1.190476190476|
|2021|4|84|83|1.204819277108|
|2021|3|83|93|-10.752688172043|
|2021|2|93|134|-30.597014925373|
|2021|1|134|134|0.000000000000|
|2020|12|134|116|15.517241379310|
|2020|11|116|115|0.869565217391|
|2020|10|115|91|26.373626373626|
|2020|9|91|155|-41.290322580645|
|2020|8|155|192|-19.270833333333|
|2020|7|192|229|-16.157205240174|
|2020|6|229|348|-34.195402298850|
|2020|5|348|193|80.310880829015|
|2020|4|193|153|26.143790849673|
|2020|3|153|190|-19.473684210526|
|2020|2|190|174|9.195402298850|
|2020|1|174|206|-15.533980582524|
|2019|12|206|187|10.160427807486|
|2019|11|187|412|-54.611650485436|
|2019|10|412|98|320.408163265306|
|2019|9|98|84|16.666666666666|
|2019|8|84|176|-52.272727272727|
|2019|7|176|214|-17.757009345794|
|2019|6|214|101|111.881188118811|
|2019|5|101|78|29.487179487179|
|2019|4|78|101|-22.772277227722|
|2019|3|101|122|-17.213114754098|
|2019|2|122|130|-6.153846153846|
|2019|1|130|181|-28.176795580110|
|2018|12|181|508|-64.370078740157|
|2018|11|508|370|37.297297297297|
|2018|10|370|219|68.949771689497|
|2018|9|219|788|-72.208121827411|
|2018|8|788|104|657.692307692307|
|2018|7|104|66|57.575757575757|
|2018|6|66|86|-23.255813953488|
|2018|5|86|113|-23.893805309734|
|2018|4|113|187|-39.572192513368|
|2018|3|187|218|-14.220183486238|
|2018|2|218|95|129.473684210526|
|2018|1|95|108|-12.037037037037|
|2017|12|108|330|-67.272727272727|
|2017|11|330|289|14.186851211072|
|2017|10|289|67|331.343283582089|
|2017|9|67|121|-44.628099173553|
|2017|8|121|212|-42.924528301886|
|2017|7|212|311|-31.832797427652|
|2017|6|311|66|371.212121212121|
|2017|5|66|118|-44.067796610169|
|2017|4|118|151|-21.854304635761|
|2017|3|151|109|38.532110091743|
|2017|2|109|219|-50.228310502283|
|2017|1|219|263|-16.730038022813|
|2016|12|263|329|-20.060790273556|
|2016|11|329|112|193.750000000000|
|2016|10|112|1|11100.000000000000|
|2016|9|1|1|0.000000000000|
|2016|8|1|3|-66.666666666666|
|2016|7|3|1|200.000000000000|
|2016|6|1|1|0.000000000000|
|2016|5|1|5|-80.000000000000|
|2016|4|5|1|400.000000000000|
|2016|3|1|1|0.000000000000|
|2016|2|1|5|-80.000000000000|
|2016|1|5|7|-28.571428571428|
|2015|12|7|4|75.000000000000|
|2015|11|4|4|0.000000000000|
|2015|10|4|3|33.333333333333|
|2015|9|3|2|50.000000000000|
|2015|8|2|3|-33.333333333333|
|2015|7|3|2|50.000000000000|
|2015|6|2|3|-33.333333333333|
|2015|5|3|2|50.000000000000|
|2015|4|2|5|-60.000000000000|
|2015|3|5|3|66.666666666666|
|2015|2|3|8|-62.500000000000|
|2015|1|8|6|33.333333333333|
|2014|12|6|3|100.000000000000|
|2014|11|3|5|-40.000000000000|
|2014|10|5|4|25.000000000000|
|2014|9|4|3|33.333333333333|
|2014|8|3|1|200.000000000000|
|2014|7|1|10|-90.000000000000|
|2014|6|10|1|900.000000000000|
|2014|5|1|2|-50.000000000000|
|2014|4|2|1|100.000000000000|
|2014|3|1|5|-80.000000000000|
|2014|2|5|8|-37.500000000000|
|2014|1|8|7|14.285714285714|
|2013|12|7|5|40.000000000000|
|2013|11|5|1|400.000000000000|
|2013|10|1|2|-50.000000000000|
|2013|9|2|7|-71.428571428571|
|2013|8|7|9|-22.222222222222|
|2013|7|9|1|800.000000000000|
|2013|6|1|1|0.000000000000|
|2013|5|1|2|-50.000000000000|
|2013|4|2|5|-60.000000000000|
|2013|3|5|1|400.000000000000|
|2013|2|1|2|-50.000000000000|
|2013|1|2|5|-60.000000000000|
|2012|12|5|3|66.666666666666|
|2012|11|3|3|0.000000000000|
|2012|10|3|2|50.000000000000|
|2012|9|2|3|-33.333333333333|
|2012|8|3|11|-72.727272727272|
|2012|7|11|7|57.142857142857|
|2012|6|7|2|250.000000000000|
|2012|5|2|13|-84.615384615384|
|2012|4|13|NULL|NULL|

- Key Questions to Address:
    Is the review trend related to the release of additional content (DLCs or updates)?

**5. Which user has the longest playtime but the fewest reviews (a "silent" gamer)?**
````sql
SELECT r.user_id, SUM(r.hours) AS total_hours_played, COUNT(r.review_id) AS total_reviews
FROM RECOMMENDATIONS r
GROUP BY r.user_id
HAVING COUNT(r.review_id) < 5  -- Ít hơn 5 đánh giá
ORDER BY total_hours_played DESC
LIMIT 10;
````
**Results Table 5**
|user_id|total_hours_played|total_reviews|
|---|---|---|
|7891567|891.8|1|
|13143741|784.0|1|
|10177840|774.5|1|
|7722080|773.8|1|
|12633337|744.2|1|
|12922824|636.3|1|
|1954717|572.2|1|
|10687032|508.7|1|
|13097370|453.6|1|
|1039273|415.4|1|

- Key Questions to Address:
    Why do some players spend a lot of time in a game but leave no reviews?
    Could these players be loyal but less engaged in community interactions?


**6. Is there any notable relationship between game price and average playtime?**
````sql
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
````
**Results Table 6**
|price_category|avg_playtime|
|---|---|
|Cheap ($0.01 - $10)|8.173152|
|Mid-range ($10.01 - $30)|6.705882|
|Free|6.425806|

- Key Questions to Address:
    Do higher-priced games have a higher average playtime?

