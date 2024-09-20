# Introduction
I will use a dataset provided by 
Luke Barousse with real world data about Data Jobs. I will 
explore what are the top paying jobs, which are the most demanded skills for Data Analysts and the most rewarding skills. Finally I will analyze which skill are both in high demand and high paying.

SQL queries are visible here: [project_sql folder](/project_sql/).

# Background
Driven by desire of better understaind the job market of Data jobs and which skills to focus on.
### Questions to answer (one for each SQL query):
1. What are the top-paying jobs for the data analyst roles?
2. What are the skills required for these top-paying roles?
3. What are the most in-demand skills for the data analyst role?
4. What are the top skills based on salary for the data analyst role?
5. What are the most optimal skills to learn (high demand and high paying)?
# Tools I used
- **SQL**: main programming language used to query the database.
- **PostgreSQL**: the chosen database management system.
- **Visual Studio Code**: my choiche for database management and executing SQL queries.
- **Github and Git**: allow me to share my SQL script and analysis, ensuring collaboration and project tracking.  
# The analysis
My approach to each question:
### 1.What are the top-paying jobs for the data analyst roles?
I want to find out the 10 top paying jobs with available salaries (removing nulls)
 for Data Analysts available remotely, to help my job junt. Company name is inside company_dim table, therefore I had to join the tables and filter for remote jobs, only Data Analysts roles and where salary is present. I ordered from highest paying to lowest and showed only top 10 results ([link](/project_sql/1_top_paying_jobs.sql)):
```sql
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
```
#### Insights:
- Top 3 paying companies are Mantys, Meta and At&T.
- The top job has roughly almost double the salary of the second result
- These top results have salary range between 184k and 650k annually, indicating high variability in the job market.

![Top Paying Jobs](assets\1.png)
*Bar graph visualizing the top 10 Paying Jobs of the dataset; ChatGPT generated this graph based on my query result.*

### 2.What are the skills required for these top-paying roles?
I want to find out the required skills for the 10 top paying jobs from first query. 
It will help understand which skill to develop.
In table skills_job_dim there are information for the skill_id
and in skills_dim the actual name of the skill ([link](/project_sql/2_top_paying_jobs_skills.sql)). 

```sql
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
```
#### Insights:
From a quick analysis on pivot table we can see for our analysis what are the top 3 skills for the top 10 paying jobs:

```markdown
| Skills   | Count of skills |
|----------|-----------------|
| SQL      | 8               |
| Python   | 7               |
| Tableau  | 6               |
```
### 3.What are the most in-demand skills for the data analyst role?
I will select the top 5 skills for Data Analyst roles. I used a subquery to filter the main table. Then I used aggregate function COUNT to count the jobs grouped by each skill. Skill names are on the skill_dim table, so I had to use JOIN.
It can help job seekers to choose what skills to focus on. ([link](/project_sql/3_top_demanded_skills.sql))

```sql
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
```
#### Insights:
Below are the top 5 skills for Data Analyst roles:

```markdown
| Skills    | Skill Count |
|-----------|-------------|
| SQL       | 92,628      |
| Excel     | 67,031      |
| Python    | 57,326      |
| Tableau   | 46,554      |
| Power BI  | 39,468      |
```
### 4.What are the top skills based on salary for the data analyst role?
To answer this questions I will look at the average salary for each skills
required in Data Analysts roles (only the ones with salary included). 
It helps job seekers to identify what are the most rewarding skills
to focus on.([link](/project_sql/4_top_paying_skills.sql))

```sql
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
```
### Insights:
Analyzing results with help of AI:
- **Specialized and emerging tech skills** like `svn`, `solidity`, 
and AI-related tools (e.g., **Keras**, **PyTorch**, **DataRobot**) 
command higher salaries due to their growing demand and limited supply.
- **Big data and cloud technologies** (e.g., **Kafka**, **Couchbase**, 
**Terraform**, **Snowflake**) offer strong salaries, highlighting 
the importance of handling large-scale data systems and cloud infrastructure.
- **Foundational tools and older technologies** 
(e.g., **Perl**, **PHP**, **Unix**) remain relevant, offering competitive pay,
but specialization in modern frameworks leads to the highest earnings.

### 5.What are the most optimal skills to learn(high demand and high paying)?
I will use result from query 3 and 4 to further deep dive and
provide an answer to the above question. ([link](/project_sql/5_optimal_skills.sql))

```sql
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
```
### Insights
Here are the query results and 3 highlights with the help of ChatGPT:
```markdown
| Skills      | Skill Count | Average Salary |
|-------------|--------------|----------------|
| Kafka       | 40           | 129,999        |
| PyTorch     | 20           | 125,226        |
| Perl        | 20           | 124,685        |
| TensorFlow  | 24           | 120,646        |
| Airflow     | 71           | 116,387        |
| Scala       | 59           | 115,479        |
| Linux       | 58           | 114,883        |
| Confluence  | 62           | 114,153        |
| PySpark     | 49           | 114,057        |
| MongoDB     | 26           | 113,607        |
| GCP         | 78           | 113,065        |
| Spark       | 187          | 113,001        |
| Databricks  | 102          | 112,880        |
| Git         | 74           | 112,249        |
| Snowflake   | 241          | 111,577        |
| Shell       | 44           | 111,496        |
| Unix        | 37           | 111,123        |
| Hadoop      | 140          | 110,888        |
| Pandas      | 90           | 110,767        |
| Phoenix     | 23           | 109,259        |
```
#### 3 Highlights:
- Snowflake has the highest skill count (241), but the average salary is slightly lower at $111,577.
- Kafka offers the highest average salary of $129,999, despite having only 40 job postings.
- Spark has a high demand with 187 job postings but a moderate average salary of $113,001.

# What I learned

During this project I used advanced SQL queries to solve real word problems enhancing my ability to query databases and my knowledge of the job market, such as which skill to focus on for a person looking for a Data Analyst job. I refined my ability to give actionable insights from a large dataset using SQL.
# Conclusions


#### 1. What are the top-paying jobs for the data analyst roles?:
- Top 3 paying companies are Mantys, Meta and At&T.
- The top job has roughly almost double the salary of the second result
- These top results have salary range between 184k and 650k annually, indicating high variability in the job market.
#### 2. What are the skills required for these top-paying roles?
```markdown
| Skills   | Count of skills |
|----------|-----------------|
| SQL      | 8               |
| Python   | 7               |
| Tableau  | 6               |
```
#### 3. What are the most in-demand skills for the data analyst role?
```markdown
| Skills    | Skill Count |
|-----------|-------------|
| SQL       | 92,628      |
| Excel     | 67,031      |
| Python    | 57,326      |
| Tableau   | 46,554      |
| Power BI  | 39,468      |
```
#### 4. What are the top skills based on salary for the data analyst role?
- **Specialized and emerging tech skills** like `svn`, `solidity`, 
and AI-related tools (e.g., **Keras**, **PyTorch**, **DataRobot**) 
command higher salaries due to their growing demand and limited supply.
- **Big data and cloud technologies** (e.g., **Kafka**, **Couchbase**, 
**Terraform**, **Snowflake**) offer strong salaries, highlighting 
the importance of handling large-scale data systems and cloud infrastructure.
- **Foundational tools and older technologies** 
(e.g., **Perl**, **PHP**, **Unix**) remain relevant, offering competitive pay,
but specialization in modern frameworks leads to the highest earnings.
#### 5. What are the most optimal skills to learn (high demand and high paying)?
Depending on the job seeker strategy, it may be worth specializing in most requested or most rewarded skills:
```markdown
| Skills      | Skill Count | Average Salary |
|-------------|--------------|----------------|
| Kafka       | 40           | 129,999        |
| PyTorch     | 20           | 125,226        |
| Perl        | 20           | 124,685        |
| TensorFlow  | 24           | 120,646        |
| Airflow     | 71           | 116,387        |
| Scala       | 59           | 115,479        |
| Linux       | 58           | 114,883        |
| Confluence  | 62           | 114,153        |
| PySpark     | 49           | 114,057        |
| MongoDB     | 26           | 113,607        |
| GCP         | 78           | 113,065        |
| Spark       | 187          | 113,001        |
| Databricks  | 102          | 112,880        |
| Git         | 74           | 112,249        |
| Snowflake   | 241          | 111,577        |
| Shell       | 44           | 111,496        |
| Unix        | 37           | 111,123        |
| Hadoop      | 140          | 110,888        |
| Pandas      | 90           | 110,767        |
| Phoenix     | 23           | 109,259        |
```
