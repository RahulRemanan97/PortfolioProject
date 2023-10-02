--Data Cleaning Using SQL

select * 
from NashvilleHousing


--Standardise the date format

select SaleDate,CONVERT(date,SaleDate)
from NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate) --This is not working properly;
									  --So tried, Altering the table.

ALTER TABLE NashvilleHousing
add SaleDateOnly Date

Update NashvilleHousing
SET SaleDateOnly = CONVERT(date,SaleDate)

select SaleDateOnly,SaleDate
from NashvilleHousing


--Populate the property address data

select N1.ParcelID, N1.PropertyAddress,N2.ParcelID,N2.PropertyAddress,ISNULL(N1.PropertyAddress,N2.PropertyAddress)
from NashvilleHousing N1
JOIN NashvilleHousing N2
	ON N1.ParcelID = N2.ParcelID
	AND N1.[UniqueID ] <> N2.[UniqueID ]
WHERE N1.PropertyAddress IS NULL

Update N1
SET PropertyAddress = ISNULL(N1.PropertyAddress,N2.PropertyAddress)
FROM NashvilleHousing N1
JOIN NashvilleHousing N2
	ON N1.ParcelID = N2.ParcelID
	AND N1.[UniqueID ] <> N2.[UniqueID ]
WHERE N1.PropertyAddress IS NULL


--Breaking out the addresses into individual columns like Address, City, State

select PropertyAddress		--First PropertyAddress
from NashvilleHousing

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as City
from NashvilleHousing

Alter Table NashvilleHousing		--Creating column for address of the property
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing				--Addign address to new column
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

Alter Table NashvilleHousing		--Creating column for City name of the property
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing				--Adding City to new column
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

Select *
From NashvilleHousing


Select OwnerAddress			--Second OwnerAddress
From NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

Select * 
From NashvilleHousing


--Change Y and N to Yes and No in the 'SoldAsVacant' column

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
						End


--To Remove duplicates
With RowNumCTE AS(
Select *,
	ROW_NUMBER() Over(
		Partition By ParcelID,
					PropertyAddress,
					SaleDate,
					SalePrice,
					LegalReference
					Order By UniqueID
					) row_num
From NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1


--Delete Unused Columns

Select *
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column PropertyAddress,SaleDate,OwnerADdress





















































































































































