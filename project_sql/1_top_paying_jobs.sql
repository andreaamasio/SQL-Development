/* I want to find out the 10 top paying jobs with available salaries (removing nulls)
 for Data Analysts available remotely, to help my job junt. Company name is inside company_dim table.*/

SELECT 
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
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

