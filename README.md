# World-Layoff-2020-2023

**Project Overview:**

This project explores global layoff data from March 2020 to March 2023 using SQL for data cleaning, transformation, and exploratory data analysis. The goal is to uncover patterns, trends, and insights into layoff behaviours across industries, companies, and countries - especially in the context of funding and business stages.

**PROJECT GOALS**

**Data Cleaning & Transformation**

  • Create a staging table for safe manipulation of the original data.
    
  • Remove duplicates using ROW_NUMBER().
    
  • Standardise text fields by trimming whitespace and correcting inconsistent entries (e.g., “crypto” vs “Crypto”).
    
  • Handle NULLs and malformed entries, replacing strings like 'NULL' with real NULL values.
    
  • Enforce consistent data types for key columns such as date, total_laid_off, percentage_laid_off, and funds_raised_millions.

**Transformation for Analytics**

  • Analysed layoffs by company, industry, country, and location.

  • Assessed correlation between funding levels and layoffs, showing that even high-funded companies had 100% layoffs.

  • Explored layoff trends by business stage and across time.

  • Visualised monthly trends and cumulative job losses using rolling aggregates.

**Reporting & Insights**

  • Highlighted top-affected industries and locations.

  • Identified companies with complete workforce layoffs.

  • Flagged countries like Nigeria with specific high-impact layoff events.

  • Provided SQL-ready outputs suitable for import into BI tools (Power BI, Tableau).

**EXECUTION STEPS**

1. Data Import & Staging
   
    • Imported raw data into SQL using SELECT INTO.
   
    • Created layoffs_staging for cleaning operations.

2. Data Cleaning & Standardisation
   
    • Removed duplicates using ROW_NUMBER().
   
    • Trimmed whitespaces and removed invalid characters (e.g., trailing periods).
   
    • Replaced string 'NULL' with real NULLs and corrected inconsistent values in columns like industry and country.
   
3. Schema Fixes & Type Enforcement
   
    • Converted string dates to DATE format.
   
    • Cast percentage_laid_off and funds_raised_millions into appropriate numeric types.
   
4. Derived Fields & Analytical Transforms

    • Added YearMonth using CONVERT(VARCHAR(7), date, 23).
   
    • Created rolling totals with SUM(...) OVER(...) for trend progression.
   
    • Used CTEs and ranking functions to show top companies and stages annually.
   
5. Exploratory Queries
   
    • Top 100 companies and top 50 industries by layoffs.
   
    • Year-over-year analysis of layoffs in the United States and Nigeria.
   
    • Identification of locations with the highest layoff counts.
   
    • Analysis of complete layoffs (100%) with reference to funding.
   
    • Monthly and cumulative trends via rolling totals.
   
    • Business stages most impacted by layoffs (Seed, Series A, IPO, etc).

**ANALYSIS RESULT**

  • Peak layoffs occurred in January, 2023, with 84714 employees laid off globally.
    
  • United States had the highest volume of layoffs overall (256059), followed by India with overall layoff of 35993.
    
  • The Consumer and Retail industries were among the top sectors affected.
    
  • A subset of highly funded companies (e.g., $500M+) still laid off 100% of their staff.
    
  • Seed and Series A stage companies showed a disproportionately high number of layoffs.
    
  • Rolling totals indicate a sharp upward trend in early 2020 and late 2022.
    
**CONCLUSION**

This project demonstrates a comprehensive pipeline from raw data to analysis-ready insights using SQL. Key takeaways include:

  • Layoffs were not limited to early-stage or low-funded companies—well-capitalised firms were also heavily impacted.
    
  • Certain industries (like Crypto and Tech) were disproportionately affected.
    
  • Layoffs intensified in waves, often coinciding with global events or economic downturns.

**FUTURE IMPROVEMENTS**

  • Integrate external datasets (e.g., stock prices, funding rounds, news sentiment).
    
  • Build a Power BI dashboard using YearMonth trends and rankings.
    
  • Create a scheduled pipeline to update this data periodically using Python or Airflow.
