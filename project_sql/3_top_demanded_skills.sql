/* What are the most in-demand skills for the data analyst role? 
I will select the top 5 skills for Data Analyst roles. 
It can help job seekers to choose what skills to focus on. */

SELECT 
    sk.skills, 
    COUNT(s.job_id) as skill_count
FROM skills_job_dim s
LEFT JOIN skills_dim sk on sk.skill_id=s.skill_id
WHERE s.job_id IN 
    (SELECT job_id
    FROM job_postings_fact
    WHERE job_title_short = 'Data Analyst'
    )
GROUP BY 
    sk.skill_id
ORDER BY 
    skill_count DESC
LIMIT 5

-- Top demanded skills are SQL, Excel and Python 