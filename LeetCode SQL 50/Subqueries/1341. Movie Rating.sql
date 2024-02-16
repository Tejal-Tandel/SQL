# 1341. Movie Rating

(SELECT u.name AS results
FROM users u
JOIN movierating mr
    ON u.user_id = mr.user_id
GROUP BY mr.user_id
ORDER BY COUNT(mr.rating) DESC, u.name ASC
LIMIT 1)

UNION ALL

(SELECT m.title AS results
FROM movies m 
JOIN movierating mr
    ON m.movie_id = mr.movie_id
WHERE EXTRACT(YEAR_MONTH FROM mr.created_at) = 202002
GROUP BY m.title
ORDER BY AVG(rating) DESC, m.title ASC
LIMIT 1);


