Use steamanalytics;
SELECT * FROM steam_games;

SELECT COUNT(*) AS total_games
FROM steam_games;

SELECT 
    COUNT(*) AS total_games,
    ROUND(AVG(price_value), 2) AS avg_price,
    SUM(positive) AS total_positive_reviews,
    SUM(negative) AS total_negative_reviews,
    SUM(total_reviews) AS total_reviews,
    ROUND(AVG(positive_review_rate) * 100, 2) AS avg_positive_rate,
    ROUND(AVG(owners_avg), 0) AS avg_estimated_owners,
    ROUND(AVG(ccu), 0) AS avg_current_players
FROM steam_games;

#TOP 10 giochi per owners
SELECT 
    name,
    developer,
    publisher,
    owners,
    owners_avg,
    price_value,
    total_reviews,
    ROUND(positive_review_rate * 100, 2) AS positive_rate_percent
FROM steam_games
ORDER BY owners_avg DESC
LIMIT 10;

#TOP10 giochi con più recensioni

SELECT 
    name,
    developer,
    publisher,
    positive,
    negative,
    total_reviews,
    ROUND(positive_review_rate * 100, 2) AS positive_rate_percent,
    owners_avg
FROM steam_games
ORDER BY total_reviews DESC
LIMIT 10;

#Giochi con miglior % di recensioni positive
SELECT 
    name,
    developer,
    publisher,
    total_reviews,
    ROUND(positive_review_rate * 100, 2) AS positive_rate_percent,
    price_value,
    owners_avg
FROM steam_games
WHERE total_reviews >= 5000
ORDER BY positive_review_rate DESC
LIMIT 10;

# Giochi a pagamento vs freetoplay
SELECT
    CASE 
        WHEN LOWER(CAST(is_free AS CHAR)) IN ('true', '1') THEN 'Free to Play'
        ELSE 'Paid'
    END AS game_type,
    COUNT(*) AS total_games,
    ROUND(AVG(price_value), 2) AS avg_price,
    ROUND(AVG(total_reviews), 0) AS avg_total_reviews,
    ROUND(AVG(positive_review_rate) * 100, 2) AS avg_positive_rate,
    ROUND(AVG(owners_avg), 0) AS avg_estimated_owners,
    ROUND(AVG(ccu), 0) AS avg_current_players
FROM steam_games
GROUP BY game_type;

#Numero giochi per fascia di prezzo
SELECT
    price_band,
    COUNT(*) AS total_games
FROM steam_games
GROUP BY price_band
ORDER BY total_games DESC;

#Giochi per fascia di prezzo
SELECT
    price_band,
    COUNT(*) AS total_games,
    ROUND(AVG(price_value), 2) AS avg_price,
    ROUND(AVG(total_reviews), 0) AS avg_reviews,
    ROUND(AVG(positive_review_rate) * 100, 2) AS avg_positive_rate,
    ROUND(AVG(owners_avg), 0) AS avg_estimated_owners,
    ROUND(AVG(ccu), 0) AS avg_current_players
FROM steam_games
GROUP BY price_band
ORDER BY avg_estimated_owners DESC;


#Developer con più giochi
SELECT 
    developer,
    COUNT(*) AS total_games,
    ROUND(AVG(owners_avg), 0) AS avg_estimated_owners,
    ROUND(AVG(positive_review_rate) * 100, 2) AS avg_positive_rate
FROM steam_games
WHERE developer IS NOT NULL
  AND developer <> ''
GROUP BY developer
ORDER BY total_games DESC
LIMIT 10;


#Publisher con più giochi
SELECT 
    publisher,
    COUNT(*) AS total_games,
    ROUND(AVG(owners_avg), 0) AS avg_estimated_owners,
    SUM(total_reviews) AS total_reviews,
    ROUND(AVG(positive_review_rate) * 100, 2) AS avg_positive_rate
FROM steam_games
WHERE publisher IS NOT NULL
  AND publisher <> ''
GROUP BY publisher
ORDER BY total_games DESC
LIMIT 10;

#Publisher con più owners stimati
SELECT 
    publisher,
    COUNT(*) AS total_games,
    ROUND(SUM(owners_avg), 0) AS total_estimated_owners,
    SUM(total_reviews) AS total_reviews,
    ROUND(AVG(positive_review_rate) * 100, 2) AS avg_positive_rate
FROM steam_games
WHERE publisher IS NOT NULL
  AND publisher <> ''
GROUP BY publisher
HAVING COUNT(*) >= 2
ORDER BY total_estimated_owners DESC
LIMIT 10;


#Giochi con più utenti attivi contemporaneamente
SELECT 
    name,
    developer,
    publisher,
    ccu,
    owners_avg,
    total_reviews,
    ROUND(positive_review_rate * 100, 2) AS positive_rate_percent,
    price_value
FROM steam_games
ORDER BY ccu DESC
LIMIT 10;

#Giochi gratuiti più popolari
SELECT 
    name,
    developer,
    publisher,
    owners_avg,
    total_reviews,
    ccu,
    ROUND(positive_review_rate * 100, 2) AS positive_rate_percent
FROM steam_games
WHERE LOWER(CAST(is_free AS CHAR)) IN ('true', '1')
ORDER BY owners_avg DESC
LIMIT 10;

SELECT name, developer, owners
from steam_games
ORDER BY owners_avg DESC
Limit 10;

SELECT 
    developer,
    COUNT(*) AS total_games
FROM steam_games
GROUP BY developer
ORDER BY total_games DESC;

SELECT publisher, 
COUNT(*) as total_games
from steam_games
GROUP BY publisher
ORDER BY total_games DESC
;

SELECT 
    developer, publisher,
    COUNT(*) AS total_games
FROM steam_games
WHERE total_reviews > 5000
GROUP BY publisher, developer
ORDER BY total_games DESC;

SELECT COUNT(DISTINCT name)
FROM steam_games;

SELECT COUNT(*)
FROM steam_games;

SELECT COUNT(*)
FROM steam_games
WHERE name IS NULL;

USE SteamAnalytics;

SELECT 
    ROUND(SUM(price_value * owners_avg), 2) AS estimated_total_revenue,
    ROUND(SUM(owners_avg), 0) AS total_estimated_owners,
    ROUND(
        SUM(price_value * owners_avg) / NULLIF(SUM(owners_avg), 0), 
        2
    ) AS avg_spending_per_owner
FROM steam_games
WHERE price_value > 0;

USE SteamAnalytics;

SELECT
    price_band,
    COUNT(*) AS total_games,
    ROUND(AVG(price_value), 2) AS avg_price,
    ROUND(SUM(owners_avg), 0) AS total_estimated_owners,
    ROUND(AVG(owners_avg), 0) AS avg_estimated_owners,
    ROUND(AVG(positive_review_rate) * 100, 2) AS avg_positive_rate
FROM steam_games
GROUP BY price_band
ORDER BY total_estimated_owners DESC;


USE SteamAnalytics;


#Quel 48.14 è ugauel alla media mondiale di spesa
SELECT
    price_band,
    COUNT(*) AS total_games,
    ROUND(AVG(price_value), 2) AS avg_price,
    ROUND(SUM(owners_avg), 0) AS total_estimated_owners,
    ROUND(AVG(owners_avg), 0) AS avg_estimated_owners,
    ROUND(AVG(total_reviews), 0) AS avg_total_reviews
FROM steam_games
GROUP BY price_band
ORDER BY avg_estimated_owners DESC;

USE SteamAnalytics;

#quale fascia di prezzo ha maggiori recensioni positive?
SELECT
    price_band,
    COUNT(*) AS total_games,
    ROUND(AVG(price_value), 2) AS avg_price,
    ROUND(AVG(total_reviews), 0) AS avg_total_reviews,
    ROUND(AVG(positive_review_rate) * 100, 2) AS avg_positive_rate_percent,
    ROUND(SUM(positive), 0) AS total_positive_reviews,
    ROUND(SUM(negative), 0) AS total_negative_reviews
FROM steam_games
WHERE total_reviews >= 1000
GROUP BY price_band
ORDER BY avg_positive_rate_percent DESC;