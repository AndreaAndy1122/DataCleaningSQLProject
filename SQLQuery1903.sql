-- Cleaning Data Project

select * from PortfolioProjectNashville..Nashvillehousing


-- Standardize Date Format
-- changing data format, adding new column

Select SaleDate,saleDateConverted = CONVERT(Date,SaleDate)
From PortfolioProjectNashville..Nashvillehousing

Update Nashvillehousing
SET SaleDate = CONVERT (Date, SaleDate)

ALTER TABLE Nashvillehousing
Add SaleDateConverted Date

Update Nashvillehousing
SET SaleDateConverted = convert (Date, SaleDate)

-- working with property address data, self-join on the identical ParcelID column, nut not the same row = joining the table to itself

select *
from PortfolioProjectNashville..Nashvillehousing
where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashvillehousing a
JOIN Nashvillehousing b
on a.ParcelID= b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
--where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashvillehousing a
JOIN Nashvillehousing b
on a.ParcelID= b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 

-- changing address column - splitting: city and address using Substring, Charindex
--PropertyAddress

select PropertyAddress
from PortfolioProjectNashville..Nashvillehousing 

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from PortfolioProjectNashville..Nashvillehousing 


ALTER TABLE Nashvillehousing
Add PropertySplitAddress nvarchar(255)

Update Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashvillehousing
Add PropertySplitCity nvarchar(255)

Update Nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select *
from PortfolioProjectNashville..Nashvillehousing 

-- OwnerAddress - working with PARSENAME


select OwnerAddress
from PortfolioProjectNashville..Nashvillehousing 

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
from Nashvillehousing 

ALTER TABLE Nashvillehousing
Add OwnerSplitAddress nvarchar(255)

Update Nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE Nashvillehousing
Add OwnerSplitCity nvarchar(255)

Update Nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE Nashvillehousing
Add OwnerSplitState nvarchar(255)

Update Nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


select *
from PortfolioProjectNashville..Nashvillehousing 

--changing SoldAsVacant column with Case statement

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProjectNashville..Nashvillehousing 
group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
from PortfolioProjectNashville..Nashvillehousing 

Update Nashvillehousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-- removing duplicates


WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) row_num
from PortfolioProjectNashville..Nashvillehousing 
)
select *
from RowNumCTE
where row_num >1
order by PropertyAddress

--to delete duplicates I would use DELETE: 
--DELETE
--from RowNumCTE
--where row_num >1

-- delete unused columns

ALTER TABLE Nashvillehousing
DROP column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

select *
from PortfolioPROJECTNashville..Nashvillehousing