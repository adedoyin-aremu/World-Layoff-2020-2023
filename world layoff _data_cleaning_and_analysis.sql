/*
==============================================================
  Project: World Layoff Analysis (2020–2023)
  Author: Adedoyin Aremu
  Description: SQL Script for Data Cleaning, Transformation,
               and Exploratory Data Analysis.
==============================================================
*/

-- 🧹 DATA CLEANING & TRANSFORMATION
--------------------------------------------------------------

-- Create a staging table from raw data
SELECT * INTO layoffs_staging FROM layoffs;

-- Remove duplicate rows using ROW_NUMBER
WITH cte1 AS (
    SELECT 
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry, total_laid_off, 
                         percentage_laid_off, [date], stage, country, funds_raised_millions 
            ORDER BY (SELECT NULL)
        ) AS row_num,
        * 
    FROM layoffs_staging
)
DELETE FROM cte1 WHERE row_num > 1;

-- Trim leading/trailing spaces from company names
UPDATE layoffs_staging
SET company = TRIM(company);

-- Standardise industry values
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%';

-- Handle NULL and 'NULL' values in industry
UPDATE layoffs_staging
SET industry = 'Other'
WHERE industry IS NULL OR industry = 'NULL';

-- Fix country values (e.g., 'United States.')
UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM country);

-- Remove rows with invalid dates and convert to DATE type
DELETE FROM layoffs_staging
WHERE [date] = 'NULL';

UPDATE layoffs_staging
SET [date] = CONVERT(DATE, [date], 101);

ALTER TABLE layoffs_staging
ALTER COLUMN [date] DATE;

-- Replace string 'NULL' with actual NULLs in percentage_laid_off
UPDATE layoffs_staging
SET percentage_laid_off = NULL
WHERE percentage_laid_off = 'NULL';

-- Fill missing industries using self-join by company + location
UPDATE a
SET a.industry = b.industry
FROM layoffs_staging a
JOIN layoffs_staging b
  ON a.company = b.company AND a.location = b.location
WHERE a.industry = ''
  AND b.industry IS NOT NULL AND b.industry != '';

-- Remove rows with both total_laid_off and percentage_laid_off as NULL
DELETE FROM layoffs_staging
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Ensure numeric data types for analytics
ALTER TABLE layoffs_staging
ALTER COLUMN total_laid_off INT;

UPDATE layoffs_staging
SET funds_raised_millions = NULL
WHERE funds_raised_millions = 'NULL' OR funds_raised_millions = '';

ALTER TABLE layoffs_staging
ALTER COLUMN funds_raised_millions DECIMAL(18,2);

ALTER TABLE layoffs_staging
ALTER COLUMN percentage_laid_off DECIMAL(5,2);

-- Final validation
SELECT * FROM layoffs_staging;

-- 📊 EXPLORATORY DATA ANALYSIS
--------------------------------------------------------------

-- Range of layoff counts
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging;

-- Date range of dataset
SELECT MAX([date]) AS LatestDate, MIN([date]) AS EarliestDate
FROM layoffs_staging;

-- Top 100 companies with most layoffs (by year)
SELECT TOP 100 company, YEAR([date]) AS [Year], SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY company, YEAR([date])
ORDER BY total_laid_off DESC;

-- Top 50 industries with most layoffs
SELECT TOP 50 industry, YEAR([date]) AS [Year], SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
WHERE industry != 'Other'
GROUP BY industry, YEAR([date])
ORDER BY total_laid_off DESC;

-- Layoffs by location and country
WITH location_cte AS (
    SELECT country, location, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging
    WHERE total_laid_off IS NOT NULL
    GROUP BY country, location
)
SELECT location, country, total_laid_off
FROM location_cte
ORDER BY total_laid_off DESC;

-- Layoffs by country and date
SELECT [date], country, SUM(total_laid_off) AS total
FROM layoffs_staging
GROUP BY [date], country
ORDER BY total DESC;

-- Layoffs per year in the US
SELECT YEAR([date]) AS year, country, SUM(total_laid_off) AS total
FROM layoffs_staging
WHERE country = 'United States'
GROUP BY YEAR([date]), country
ORDER BY total DESC;

-- Companies with 100% layoff (globally and in Nigeria)
SELECT * FROM layoffs_staging
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT * FROM layoffs_staging
WHERE country = 'Nigeria'
ORDER BY total_laid_off DESC;

-- Top 10 companies with 100% layoffs and high funding
SELECT TOP 10 company, industry, location, country,
       CONVERT(VARCHAR(7), [date], 23) AS [Month],
       percentage_laid_off, funds_raised_millions
FROM layoffs_staging
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Monthly layoffs and rolling total
WITH rolling_total AS (
    SELECT 
        CONVERT(VARCHAR(7), [date], 23) AS YearMonth,
        SUM(total_laid_off) AS monthly_layoffs
    FROM layoffs_staging
    WHERE [date] IS NOT NULL
    GROUP BY CONVERT(VARCHAR(7), [date], 23)
)
SELECT 
    YearMonth, 
    monthly_layoffs,
    SUM(monthly_layoffs) OVER(ORDER BY YearMonth ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingTotal
FROM rolling_total;

-- Company layoff ranking by year
WITH CompanyYear AS (
    SELECT company, industry, country, YEAR([date]) AS years, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging
    GROUP BY company, industry, country, YEAR([date])
),
CompanyRanking AS (
    SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Rank
    FROM CompanyYear
)
SELECT * 
FROM CompanyRanking
WHERE Rank <= 5;

-- Layoffs by stage of business
WITH StageRanking AS (
    SELECT YEAR([date]) AS year, stage, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging
    WHERE stage NOT IN ('NULL', 'Unknown')
    GROUP BY stage, YEAR([date])
),
RankedStages AS (
    SELECT *, DENSE_RANK() OVER(PARTITION BY year ORDER BY total_laid_off DESC) AS StageRank
    FROM StageRanking
)
SELECT * 
FROM RankedStages
WHERE StageRank <= 3;

