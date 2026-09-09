# HR Analytics SQL Project

# About Project

This project is based on an HR Analytics database.

I used SQL to analyze employee data and find useful information related to employees, salary, performance, attendance and attrition.

# Database

Database Name: `hr_analytics_db`

# Tables Used

- departments
- employees
- attendance
- performance

# SQL Skills Used

- SELECT
- WHERE
- DISTINCT
- ORDER BY
- GROUP BY
- HAVING
- Aggregate Functions
- JOINS
- Subqueries
- CASE
- Date Functions

# Analysis Questions

1. Total Employees
2. Active Employees
3. Employee Attrition Rate
4. Average Employee Salary
5. Salary by Department
6. Salary by Designation
7. Average Performance Rating
8. Top Performers
9. Bonus Distribution
10. Department-wise Headcount
11. Gender Diversity Ratio
12. Age Distribution
13. Average Employee Tenure
14. New Hires by Month
15. Employee Attendance Rate
16. Leave Utilization
17. Absenteeism Rate
18. Highest Paying Department
19. Highest Paying Job Role
20. Promotion Eligibility
21. Performance Rating Distribution
22. Employee Growth Trend
23. Employees by City
24. Department-wise Attrition
25. Workforce Dashboard Metrics

# Files

- `hr_analytics_db.sql` - Database and tables
- `hr_analysis_queries.sql` - SQL analysis queries
- `README.md` - Project information

# Tools

- MySQL
- SQL

# Project Goal

The main goal of this project is to practice SQL and analyze HR data to get useful business insights.
 

 use  hr_analytics_db;

 

-- 1) Total Employees
 
SELECT 
    COUNT(*) AS total_employees
FROM
    employees;
    
-- 2)  Active Employees

SELECT 
    COUNT(*) AS active_emp
FROM
    employees
WHERE
    employment_status = 'active';
    
-- 3) Employee Attrition Rate

SELECT 
    SUM(CASE
        WHEN employment_status IN ('resigned' , 'terminated') THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*) AS attribution_rate_percent
FROM
    employees;
    
-- 4) Average Employee Salary

SELECT 
    ROUND(AVG(salary), 2) AS avg_salary
FROM
    employees;
    
-- 5) Salary by Department

SELECT 
    d.department_name, ROUND(AVG(e.salary), 2) AS avg_salary
FROM
    employees e
        INNER JOIN
    departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY avg_salary DESC;

-- 6) Salary by Designation

SELECT 
    designation, ROUND(AVG(salary), 2) AS avg_salary
FROM
    employees
GROUP BY designation
ORDER BY avg_salary DESC;

-- 7) Average Performance Rating

SELECT 
    ROUND(AVG(performance_rating), 2) AS emp_perfeormane_rating
FROM
    performance;
    
-- 8) Top Performers

SELECT 
    e.employee_name, e.employee_id, p.performance_rating
FROM
    employees e
        JOIN
    performance p ON e.employee_id = p.employee_id
ORDER BY p.performance_rating DESC
LIMIT 10;

-- 9) Bonus Distribution

SELECT 
    CASE
        WHEN bonus < 10000 THEN '0-10000'
        WHEN bonus < 20000 THEN '10000-20000'
        WHEN bonus < 30000 THEN '20000-30000'
        WHEN bonus < 40000 THEN '30000-40000'
        ELSE '40000-50000'
    END AS bonus_range,
    COUNT(*) AS emp_count
FROM
    performance
GROUP BY bonus_range
ORDER BY bonus_range;

-- 10) Department-wise Headcount

SELECT 
    d.department_name, COUNT(e.employee_id) AS total_emp
FROM
    departments d
        JOIN
    employees e ON d.department_id = e.department_id
GROUP BY department_name
ORDER BY total_emp DESC;

-- 11. Gender Diversity Ratio

SELECT 
    gender,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100 / (SELECT 
                    COUNT(*)
                FROM
                    employees),
            2) AS percentage
FROM
    employees
GROUP BY gender;

-- 12) Age Distribution

SELECT 
    CASE
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50-59'
    END AS age_group,
    COUNT(*) AS emp_count
FROM
    employees
GROUP BY age_group
ORDER BY age_group;

-- 13) Average Employee Tenure

SELECT 
    ROUND(AVG(DATEDIFF(CURDATE(), hire_date)) / 365,
            2) AS avg_tenure_year
FROM
    employees;

-- 14) New Hires by Month

SELECT 
    DATE_FORMAT(hire_date, '%y-%m') AS hire_month,
    COUNT(*) AS new_hire
FROM
    employees
GROUP BY hire_month
ORDER BY hire_month;

-- 15) Employee Attendance Rate

SELECT 
    ROUND(SUM(CASE
                WHEN status = 'present' THEN 1
                ELSE 0
            END) * 100 / COUNT(*),
            2) AS attendance_rate_percentage
FROM
    attendance;
    
-- 16) Leave Utilization

SELECT 
    COUNT(*) AS leave_days
FROM
    attendance
WHERE
    status = 'leave';
    
-- 17) Absenteeism Rate

SELECT 
    ROUND(SUM(CASE
                WHEN status = 'absent' THEN 1
                ELSE 0
            END) * 100 / COUNT(*),
            2) AS absent_rate_percentage
FROM
    attendance;
    
-- 18) Highest Paying Department

SELECT 
    d.department_name, ROUND(AVG(e.salary), 2) AS avg_salary
FROM
    employees e
        JOIN
    departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY avg_salary DESC
LIMIT 1;

-- 19) Highest Paying Job Role

SELECT 
    designation, ROUND(AVG(salary), 2) AS avg_salary
FROM
    employees
GROUP BY designation
ORDER BY avg_salary DESC
LIMIT 1;

-- 20. Promotion Eligibility List

SELECT 
    e.employee_id, e.employee_name, p.performance_rating
FROM
    employees e
        JOIN
    performance p ON e.employee_id = p.employee_id
WHERE
    performance_rating > 4.5
ORDER BY performance_rating DESC;

-- 21) Performance Rating Distribution

SELECT 
    CASE
        WHEN performance_rating < 2 THEN '1.00 - 1.99'
        WHEN performance_rating < 3 THEN '2.00 - 2.99'
        WHEN performance_rating < 2 THEN '3.00 - 3.99'
        ELSE '4.00-5.00'
    END AS rating_range,
    COUNT(*) AS emp_count
FROM
    performance
GROUP BY rating_range
ORDER BY rating_range;

-- 22) Employee Growth Trend

SELECT 
    YEAR(hire_date) AS hire_year, COUNT(*) AS emp_hire
FROM
    employees
GROUP BY hire_year
ORDER BY hire_year;

-- 23) Employees by City

SELECT 
    city, COUNT(*) AS emp_count
FROM
    employees
GROUP BY city
ORDER BY emp_count DESC;

-- 24. Department-wise Attrition

SELECT 
    d.department_name,
    ROUND(SUM(CASE
                WHEN e.employment_status IN ('resigned' , 'terminated') THEN 1
                ELSE 0
            END) * 100 / COUNT(*),
            2) AS attribution_rate_percentage
FROM
    employees e
        JOIN
    departments d ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY attribution_rate_percentage DESC;

-- 25) Workforce Dashboard Metrics

SELECT 
    (SELECT 
            COUNT(*)
        FROM
            employees) AS total_emp,
    (SELECT 
            COUNT(*)
        FROM
            employees
        WHERE
            employment_status = 'active') AS active_emp,
    (SELECT 
            ROUND(SUM(CASE
                            WHEN employment_status IN ('resigned' , 'terminated') THEN 1
                            ELSE 0
                        END) * 100 / COUNT(*),
                        2)
        FROM
            employees) AS attribution_rate_percentage,
    (SELECT 
            ROUND(AVG(salary), 2)
        FROM
            employees) AS avg_salary,
    (SELECT 
            ROUND(AVG(performance_rating), 2)
        FROM
            performance) AS avg_performance_rate
