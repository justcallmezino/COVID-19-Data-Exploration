/*

CLEANING DATA IN SQL QUERIES

*/

select *
from portfolio_project..[Nashville Housing]

--------------------------------------------------------------------------------------------------------------------------


-- 1. STANDARDIZING THE SaleDate FORMAT (BEING DATETIME FORMAT)

select SaleDate, CONVERT(date, SaleDate)
from portfolio_project..[Nashville Housing]


-- Create a new column


alter table portfolio_project..[Nashville Housing]
add SaleDateConverted date


update portfolio_project..[Nashville Housing]
set SaleDateConverted = CONVERT(date, SaleDate)

--------------------------------------------------------------------------------------------------------------------------


-- 2. POPULATE PropertyAddress DATA

select *
from portfolio_project..[Nashville Housing]
order by ParcelID


-- SELF-JOINING the table


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolio_project..[Nashville Housing] as a
join portfolio_project..[Nashville Housing] as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolio_project..[Nashville Housing] as a
join portfolio_project..[Nashville Housing] as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------


-- 3. BREAKING OUT PropertyAddress INTO INDIVIDUAL COLUMNS (ADDRESS, CITY)

select PropertyAddress
from portfolio_project..[Nashville Housing]


-- First, Get rid of the delimiter(,)


select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City

from portfolio_project..[Nashville Housing]


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

select OwnerAddress
from portfolio_project..[Nashville Housing]


select
PARSENAME(Replace(OwnerAddress, ',', '.') ,3)
, PARSENAME(Replace(OwnerAddress, ',', '.') ,2)
, PARSENAME(Replace(OwnerAddress, ',', '.') ,1)
from portfolio_project..[Nashville Housing]


-- Create 3 Columns to insert the Splitted OwnerAddress


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
)
delete
from RowNumCTE
where RowNum > 1

---------------------------------------------------------------------------------------------------------------------------------------------------


-- 7. DELETE UNUSED 


select *
from portfolio_project..[Nashville Housing]


-- To delete columns


alter table portfolio_project..[Nashville Housing]
drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict