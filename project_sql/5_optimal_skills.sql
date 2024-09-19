/*What are the most optimal skills to learn(high demand and high paying)?
I will use result from query 3 and 4 to further deep dive and
provide an answer to the above question.

*/

WITH top_demand AS (
    SELECT 
        sk.skill_id,
        sk.skills, 
        COUNT(s.job_id) as skill_count
    FROM skills_job_dim s
    LEFT JOIN skills_dim sk on sk.skill_id=s.skill_id
    WHERE s.job_id IN 
        (SELECT job_id
        FROM job_postings_fact
        WHERE job_title_short = 'Data Analyst'AND
        salary_year_avg IS NOT NULL    
        )
    GROUP BY 
        sk.skill_id
    ORDER BY 
        skill_count DESC
),
top_paid AS (
        SELECT 
        sk.skill_id,
        sk.skills, 
        FLOOR(AVG(j.salary_year_avg)) as average_salary
    FROM skills_job_dim s
    INNER JOIN skills_dim sk on sk.skill_id=s.skill_id
    INNER JOIN job_postings_fact j on j.job_id=s.job_id
    WHERE 
        j.job_title_short = 'Data Analyst' AND
        j.salary_year_avg IS NOT NULL    
    GROUP BY sk.skill_id
    ORDER BY average_salary DESC
)

/*combining both CTE below, giving salary the priority,
but only for skills demanded more than 15 times */

SELECT DISTINCT
    p.skills,
    skill_count,
    average_salary
FROM top_demand d 
INNER JOIN top_paid p on p.skill_id=d.skill_id
WHERE skill_count>15
ORDER BY
    average_salary DESC,
    skill_count DESC
LIMIT 20    