/* 180. Consecutive Numbers

Table: Logs
+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| id          | int     |
| num         | varchar |
+-------------+---------+
In SQL, id is the primary key for this table.
id is an autoincrement column.

Find all numbers that appear at least three times consecutively.
Return the result table in any order.
The result format is in the following example.

Example 1:
Input: 
Logs table:
+----+-----+
| id | num |
+----+-----+
| 1  | 1   |
| 2  | 1   |
| 3  | 1   |
| 4  | 2   |
| 5  | 1   |
| 6  | 2   |
| 7  | 2   |
+----+-----+
Output: 
+-----------------+
| ConsecutiveNums |
+-----------------+
| 1               |
+-----------------+
Explanation: 1 is the only number that appears consecutively for at least three times.

----------------------------------------------------------------------------------------------------------------------------------------------
# Solution */

WITH cte AS (SELECT
       LEAD(num,1) OVER(ORDER BY id) AS next_num1,
       LEAD(num,2) OVER(ORDER BY id) AS next_num2
       FROM logs)

SELECT DISTINCT num AS ConsecutiveNums
FROM cte
WHERE num = next_num1 AND num = next_num2;

Alternatively,

SELECT DISTINCT l1.num AS ConsecutiveNums
FROM logs l1, logs l2, logs l3
WHERE l1.id = l2.id - 1 AND l2.id = l3.id -1 AND
      l1.num = l2.num AND l2.num = l3.num

