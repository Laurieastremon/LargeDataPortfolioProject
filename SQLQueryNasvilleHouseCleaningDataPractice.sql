SELECT SaleDate
From NashvilleHouse

-- Standardise Date format / DID NOT WORK
SELECT SaleDate, CONVERT(date, SaleDate) 
From NashvilleHouse

UPDATE NashvilleHouse
SET SaleDate = CONVERT(date, SaleDate) 

ALTER TABLE Nashvillehouse 
ADD SaleDateConverted2 date; 

UPDATE NashvilleHouse
SET SaleDateConverted2 = CONVERT(date, SaleDate); 

SELECT SaleDateCONVERTED, CONVERT(date, SaleDate)
From NashvilleHouse

--populate property address


SELECT PropertyAddress
From NashvilleHouse
--where PropertyAddress is null
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHouse a
join NashvilleHouse b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHouse a
join NashvilleHouse b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 
---checking if everything is updated/ yes 
SELECT PropertyAddress
FROM NashvilleHouse
WHERE PropertyAddress is null

-- breaking out adress into individual columns such as adress, city and state
Select PropertyAddress
from NashvilleHouse

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address

from dbo.NashvilleHouse

ALTER TABLE Nashvillehouse 
ADD PropertySplitAddress nvarchar(250) 

UPDATE NashvilleHouse
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) 

ALTER TABLE Nashvillehouse 
ADD PropertySplitCity nvarchar(250) 

UPDATE NashvilleHouse
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) 

Select *
From NashvilleHouse

-- cleaning owner address with Parsename to separate city and state
Select OwnerAddress
From NashvilleHouse

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From NashvilleHouse

ALTER TABLE Nashvillehouse 
ADD OwnerSplitAddress nvarchar(250) 

UPDATE NashvilleHouse
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE Nashvillehouse 
ADD OwnerSplitCity nvarchar(250) 

UPDATE NashvilleHouse
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE Nashvillehouse 
ADD OwnerSplitState nvarchar(250) 

UPDATE NashvilleHouse
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

Select *
From NashvilleHouse

--- CHANGING FROM A 'NO' COLUMN TO A 'YES' COLUMN
Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHouse
group by SoldAsVacant
order by 2

SELECT SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END
From NashvilleHouse

UPDATE NashvilleHouse
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END

--REMOVE DUPLICATES / do the the select first then do the CTE. 
WITH RowNumCTE	AS( 
SELECT*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order by
		UniqueID
		) row_num

FROM NashvilleHouse
--order by ParcelID 
)
Select *
FROM RowNumCTE
Where row_num >2 -- this to show where the duplicates are
order by PropertyAddress

-- now to delete the duplicates
WITH RowNumCTE	AS( 
SELECT*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order by
		UniqueID
		) row_num

FROM NashvilleHouse
--order by ParcelID 
)
DELETE 
FROM RowNumCTE
Where row_num >2 -- this to show where the duplicates are
--order by PropertyAddress

---checking to see if the duplicates where deleted
WITH RowNumCTE	AS( 
SELECT*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order by
		UniqueID
		) row_num

FROM NashvilleHouse
--order by ParcelID 
)
Select *
FROM RowNumCTE
Where row_num >2 
order by PropertyAddress

-- Deleting Unused Columns we are not using 
SELECT *
FROM NashvilleHouse


ALTER TABLE Nashvillehouse
DROP COLUMN OwnerAddress, PropertyAddress, SaleDateConverted, TaxDistrict 

