/*

CLEANING DATA IN SQL QUERIES

*/

select *
from portfolio_project..[Nashville Housing]
--------------------------------------------------------------------------------------------------------------------------


-- 1. STANDARDIZE THE SaleDate FORMAT (BEING DATETIME FORMAT)

select SaleDate, CONVERT(date, SaleDate)
from portfolio_project..[Nashville Housing]

update portfolio_project..[Nashville Housing]
set SaleDate = CONVERT(date, SaleDate)

-- No update effected, 
-- Create a new column

alter table portfolio_project..[Nashville Housing]
add SaleDateConverted date


update portfolio_project..[Nashville Housing]
set SaleDateConverted = CONVERT(date, SaleDate)


-- Update is applied to set the date to be the converted date.
-- To check, Execute

select SaleDateConverted, CONVERT(date, SaleDate)
from portfolio_project..[Nashville Housing]

	-- NOTE: If both date format look thesame, Update successful...
--------------------------------------------------------------------------------------------------------------------------


-- 2. POPULATE PropertyAddress DATA

select *
from portfolio_project..[Nashville Housing]
--where PropertyAddress is null
order by ParcelID

-- [Ordering by ParcelID helps to locate Properties with different UniqueID but have same ParcelID. 
-- The Address found will then be used to populate other UniqueID with thesame ParcelID]


-- This can be done by SELF-JOINING the table to itself.

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolio_project..[Nashville Housing] as a
join portfolio_project..[Nashville Housing] as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- The query above means that if ParcelIDs are thesame but UniqueIDs aren't, populate the PropertyAddress of the UniqueID that is NULL with the PropertyAddress
-- of the UniqueID that isn't NULL...

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolio_project..[Nashville Housing] as a
join portfolio_project..[Nashville Housing] as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Update is applied to make all NULL PropertyAddress populated.
-- To check, Execute the initial query again
	-- NOTE: If only the Column Headers return, Update successful...
--------------------------------------------------------------------------------------------------------------------------


-- 3. BREAKING OUT PropertyAddress INTO INDIVIDUAL COLUMNS (ADDRESS, CITY)

select PropertyAddress
from portfolio_project..[Nashville Housing]
-- where PropertyAddress is null

-- The PropertyAddress comes with a delimiter(,) between Address and City. Hence my reason for separation using SUBSTRING...
-- First, Get rid of the delimiter(,)

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City

from portfolio_project..[Nashville Housing]

-- The first SUBSTRING starting with the (PropertyAddress, 1,) means that the string starts at the first string/alphabet.
	-- The CHARINDEX() means starting from the delimiter(',') in PropertyAddress and the -1 indicates how many strings to be removed,
	-- and in this case 1, going backwards from the delimiter(,)....

-- The second SUBSTRING starting with the (PropertyAddress) means that the string/alphabet starts anywhere while the CHARINDEX() states that 
-- its starting from the delimiter(','), going forward.

-- Create 2 Columns to insert the Splitted PropertyAddress

alter table portfolio_project..[Nashville Housing]
add PropertyLocation nvarchar(255)

update portfolio_project..[Nashville Housing]
set PropertyLocation = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


alter table portfolio_project..[Nashville Housing]
add PropertyCity nvarchar(255)

update portfolio_project..[Nashville Housing]
set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- To check: Execute
select *
from portfolio_project..[Nashville Housing]

-- NOTE: New Columns are at the right end of the table - Scroll Right
--------------------------------------------------------------------------------------------------------------------------


-- 4. BREAKING OUT OwnerAddress INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE) 
-- Using PARSENAME for the OwnerAddress Split (Simpler Split)

select OwnerAddress
from portfolio_project..[Nashville Housing]

-- The OwnerAddress comes with a delimiter(,) between Address, City and State. Hence my reason for separation using SUBSTRING...
-- First, Get rid of the delimiter(,)

-- PARSENAME looks for only periods(.) and not comma(,) and does things backwards.
-- Replace the (,) with (.)

select
PARSENAME(Replace(OwnerAddress, ',', '.') ,3)
, PARSENAME(Replace(OwnerAddress, ',', '.') ,2)
, PARSENAME(Replace(OwnerAddress, ',', '.') ,1)
from portfolio_project..[Nashville Housing]


-- Create 3 Columns to insert the Splitted PropertyAddress

alter table portfolio_project..[Nashville Housing]
add OwnerLocation nvarchar(255)

update portfolio_project..[Nashville Housing]
set OwnerLocation = PARSENAME(Replace(OwnerAddress, ',', '.') ,3)


alter table portfolio_project..[Nashville Housing]
add OwnerCity nvarchar(255)

update portfolio_project..[Nashville Housing]
set OwnerCity = PARSENAME(Replace(OwnerAddress, ',', '.') ,2)


alter table portfolio_project..[Nashville Housing]
add OwnerState nvarchar(255)

update portfolio_project..[Nashville Housing]
set OwnerState = PARSENAME(Replace(OwnerAddress, ',', '.') ,1)


-- To check: Execute
select *
from portfolio_project..[Nashville Housing]

-- NOTE: New Columns are at the right end of the table - Scroll Right
--------------------------------------------------------------------------------------------------------------------------


-- 5. CHANGE Y AND N TO YES AND NO IN "SoldAsVacant" FIELD

select SoldAsVacant
from portfolio_project..[Nashville Housing]


select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
from portfolio_project..[Nashville Housing]
group by SoldAsVacant
Order by 2

-- Using CASE

select SoldAsVacant
, case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from portfolio_project..[Nashville Housing]


update portfolio_project..[Nashville Housing]
set SoldAsVacant = case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- 6. REMOVE DUPLICATES 
-- Only delete within the CTE or TempTables

with RowNumCTE as (
select *, 
	ROW_NUMBER() over (
	partition by ParcelID,
				 Propertyaddress,
				 SaleDate,
				 SalePrice,
				 Legalreference
				 order by 
						UniqueID
						) as RowNum
from portfolio_project..[Nashville Housing]
-- order by ParcelID
)
delete
from RowNumCTE
where RowNum > 1
-- order by PropertyAddress

-- I needed a way to Identify the rows with duplicate, hence Row_Number
-- I partioned by things that should be Unique to each row.
---------------------------------------------------------------------------------------------------------------------------------------------------


-- 7. DELETE UNUSED 

-- Talk to someone before deleting any columns

select *
from portfolio_project..[Nashville Housing]

-- To delete columns

alter table portfolio_project..[Nashville Housing]
drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict