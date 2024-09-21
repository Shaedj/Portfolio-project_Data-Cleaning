Select*
FROM portfolioproject.layoffs;

-- Objectives of Data Cleaning --------------------------------------------------
-- 1) Removing duplicates: Unessessary data.
-- 2) Standardize the Data: If theres any issues, like spelling, standardize it.
-- 3) Fix Null Values or Blank values: see if they can be populated or not.
-- 4) Remove Unnessary rows and columns. 

-- -------------------------------------------------------------------------------
-- Creating a Table duplicate to edit and stuff, a place where a mistake is not the end of the world!
CREATE TABLE layoffs_staging
LIKE layoffs;

Select*
FROM portfolioproject.layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM portfolioproject.layoffs;

-- ------------------------------------------------------------------------
-- Identifying Duplicates:
Select*, row_number() OVER(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM portfolioproject.layoffs_staging;

WITH duplicate_cte AS
	(
   Select*, row_number() OVER(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
   FROM portfolioproject.layoffs_staging
    )
    Select *
    FROM duplicate_cte
    Where row_num > 1;
    
Select*
FROM portfolioproject.layoffs_staging
Where company = 'Casper';


WITH duplicate_cte AS
	(
   Select*, row_number() OVER(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
   FROM portfolioproject.layoffs_staging
    )
    Delete
    FROM duplicate_cte
    Where row_num > 1;
-- Unfortunately can't delete with this query, so instead, it's time to create another table.



CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



Select*
FROM portfolioproject.layoffs_staging2;

INSERT INTO layoffs_staging2
Select*, row_number() OVER(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
   FROM portfolioproject.layoffs_staging;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT*
FROM layoffs_staging2;
-- With this all the duplicates have been erased!!

-- -----------------------------------------------------------------
-- Standardizing data (Finding Issues in the data and fixing it)

SELECT company, TRIM(Company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(Company);

SELECT Distinct industry
FROM layoffs_staging2
order by 1;
-- Found 'crypto', 'crypto curency' and 'CryptoCurency', which is most likely the same thing...

SELECT *
FROM layoffs_staging2
Where industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT Distinct country
FROM layoffs_staging2
order by 1;
-- FOUND both 'United States' and 'United States.'

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country like 'United States%';

SELECT `date`
FROM layoffs_staging2;
-- Date is found to be in a text format

SELECT `date`,
STR_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY column `date` DATE;

-- ------------------------------------------------------------
-- TIME TO search for NULL VALUES AND BLANKS AND DELEte useless ROWS
SELECT*
FROM layoffs_staging2
WHERE total_laid_off is NULL
and percentage_laid_off is NULL;

UPDATE layoffs_staging2
SET industry = null
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE industry is NULL
or industry = '';

SELECT *
FROM layoffs_staging2
WHERE company like 'Bally%';

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	On t1.company = t2.company
    and t1.location = t2.location
Where (t1.industry is NULL or t1.industry = '')
AND t2.industry is not NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	On t1.company = t2.company
SET t1.industry = t2.industry
Where t1.industry is NULL
AND t2.industry is not NULL;

SELECT*
FROM layoffs_staging2
WHERE total_laid_off is NULL
and percentage_laid_off is NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off is NULL
and percentage_laid_off is NULL;

SELECT*
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;




