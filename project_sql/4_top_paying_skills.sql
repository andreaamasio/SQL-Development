/*What are the top skills based on salary for the data analyst role?
To answer this questions I will look at the average salary for each skills
required in Data Analysts roles (only the ones with salary included). 
It helps job seekers to identify what are the most rewarding skills
to focus on.
*/

SELECT 
    sk.skills, 
    FLOOR(AVG(j.salary_year_avg)) as average_salary
FROM skills_job_dim s
INNER JOIN skills_dim sk on sk.skill_id=s.skill_id
INNER JOIN job_postings_fact j on j.job_id=s.job_id
WHERE 
    J.job_title_short = 'Data Analyst' AND
    J.salary_year_avg IS NOT NULL    
GROUP BY sk.skills
ORDER BY average_salary DESC
LIMIT 50

/*Analyzing results with help of AI:
- **Specialized and emerging tech skills** like `svn`, `solidity`, 
and AI-related tools (e.g., **Keras**, **PyTorch**, **DataRobot**) 
command higher salaries due to their growing demand and limited supply.
- **Big data and cloud technologies** (e.g., **Kafka**, **Couchbase**, 
**Terraform**, **Snowflake**) offer strong salaries, highlighting 
the importance of handling large-scale data systems and cloud infrastructure.
- **Foundational tools and older technologies** 
(e.g., **Perl**, **PHP**, **Unix**) remain relevant, offering competitive pay,
but specialization in modern frameworks leads to the highest earnings.
*/