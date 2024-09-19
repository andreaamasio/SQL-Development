/* I want to find out the required skills for the 10 top paying jobs from first query. 
It will help understand which skill to develop.
In table skills_job_dim there are information for the skill_id
and in skills_dim the actual name of the skill. Inner join 
is used to include only jobs with skills listed.*/

WITH top_paying_jobs AS (
    SELECT 
        job_id,
        job_title,
        salary_year_avg,
        c.name as Company_Name
    FROM 
        job_postings_fact j
    LEFT JOIN
        company_dim c on c.company_id=j.company_id
    WHERE 
        salary_year_avg IS NOT NULL AND 
        job_location='Anywhere' AND
        job_title_short='Data Analyst'
    ORDER BY 
        salary_year_avg DESC
    LIMIT 10
)
SELECT 
    t.*,
    sk.skills
FROM top_paying_jobs t
INNER JOIN skills_job_dim s ON s.job_id=t.job_id
INNER JOIN skills_dim sk ON sk.skill_id=s.skill_id
ORDER BY salary_year_avg DESC

/* from a quick analysis on pivot table we can see for our analysis:
Skills	Count of skills
SQL	        8
python	    7
tableau	    6
*/