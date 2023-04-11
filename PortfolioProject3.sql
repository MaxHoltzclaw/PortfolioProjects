--Cleaning Data In SQL Queries

SELECT * FROM dbo.NashvilleHousing

--Standardize Data Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address Data

SELECT * FROM dbo.NashvilleHousing
--WHERE PropertyAddress is Null
Order BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking out Address Into Individual Columns (Address, City, State)

SELECT PropertyAddress 
FROM dbo.NashvilleHousing
--WHERE PropertyAddress is Null
--Order BY ParcelID


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

FROM dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NvarChar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From NashvilleHousing



Select OwnerAddress
From NashvilleHousing

Select PARSENAME(Replace(OwnerAddress,',','.') , 3)
,PARSENAME(Replace(OwnerAddress,',','.') , 2)
,PARSENAME(Replace(OwnerAddress,',','.') , 1)
From NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NvarChar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
SET  OwnerSplitCity  = PARSENAME(Replace(OwnerAddress,',','.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NvarChar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.') , 1)

Select * 
From NashvilleHousing




--Change Y and N to Yes and No In "Sold as Vacant" Field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END



	--Remove Duplicates


	WITH RowNumCTE AS(
	SELECT *, 
	ROW_NUMBER() Over (
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) row_num


	FROM NashvilleHousing
	--Order by ParcelID
	)

	Select *
	From RowNumCTE
	Where row_num > 1
	--Order by PropertyAddress



--Delete Unused Columns

SELECT *
FROM NashvilleHousing


Alter Table Nashvillehousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table Nashvillehousing
Drop Column SaleDate