Select *
From project4..nash

--Standardize Date format

Select Saledateconverted, CONVERT(Date,Saledate)
From project4..nash

Update project4..nash
SET saledate = CONVERT(Date,Saledate)

ALTER TABLE project4..nash
Add Saledateconverted Date;

Update project4..nash
SET saledateconverted = CONVERT(Date,Saledate)

Select Saledateconverted
From project4..nash

--Populate Property Address data

Select *
From project4..nash
--Where propertyaddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
From project4..nash a
JOIN project4..nash b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a 
SET propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress)
FROM project4.nash a
JOIN project4..nash b
	on a.ParcelID = b.ParcelID
	AND a.uniqueID <> b.[UniqueID ]
Where a.propertyaddress is null

Update a
SET propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress)
FROM project4..nash a
JOIN project4..nash b
	on a.parcelID = b.ParcelID
	AND  a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null

--Breaking out address into individual columns(Address, City, State)

Select propertyaddress
From project4..nash

--Where Propertyaddress is null
--Order by ParcelID

Select 
SUBSTRING(Propertyaddress, 1 , CHARINDEX(',', Propertyaddress) -1) as Address
, SUBSTRING(Propertyaddress, CHARINDEX(',', Propertyaddress) + 1, LEN(Propertyaddress)) as Address

From project4..Nash

-- Create two new columns

ALTER TABLE project4..nash
Add Propertysplitaddress4 Nvarchar(255);

Update project4..nash
SET Propertysplitaddress4 = SUBSTRING(Propertyaddress, 1, CHARINDEX(',', Propertyaddress) -1)

ALTER TABLE project4..nash
Add Propertysplitcity Nvarchar(255);

Update project4..nash
SET Propertysplitcity = SUBSTRING(Propertyaddress,CHARINDEX(',', Propertyaddress) +1, LEN(Propertyaddress))

Select*
From project4..nash

------ Split the owneraddress table ---- 

Select OwnerAddress
From project4..nash

Select
PARSENAME(REPLACE(Owneraddress,',','.'), 3)
,PARSENAME(REPLACE(Owneraddress,',','.'), 2)
,PARSENAME(REPLACE(Owneraddress,',','.'), 1)
From project4..nash


ALTER TABLE project4..nash
Add Ownersplitaddress Nvarchar(255);

Update project4..nash
SET Ownersplitaddress = PARSENAME(REPLACE(Owneraddress, ',','.'), 3)

ALTER TABLE project4..nash
Add Ownersplitcity Nvarchar(255);

Update project4..nash
SET Ownersplitcity = PARSENAME(REPLACE(Owneraddress, ',', '.'), 2)

ALTER TABLE project4..nash
Add Ownersplitstate Nvarchar(255);

Update project4..nash
SET Ownersplitstate = PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)

Select *
From project4..Nash



--Change Y and N to Yes and No in "Sold as Vacant" field--

Select Distinct(Soldasvacant), COunt(Soldasvacant)
From project4..Nash
Group by Soldasvacant
Order by 2

Select Soldasvacant
, CASE When Soldasvacant = 'Y' THEN 'Yes'
	When Soldasvacant = 'N' THEN 'No'
	ELSE Soldasvacant
	END
From project4..nash

Update project4..nash
SET Soldasvacant = CASE When Soldasvacant = 'Y' THEN 'Yes'
	When Soldasvacant = 'N' THEN 'No'
	ELSE Soldasvacant
	END

Select *
From project4..nash

--Remove duplicates
--Partition our data
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION by ParcelID,
				 Propertyaddress,
				 Saledate,
				 LegalReference
				 ORDER BY
					uniqueID
					) row_num

From project4..nash
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Delete Unused Columns

Select*
From project4..nash

ALTER TABLE project4..nash
DROP COLUMN	Owneraddress, TaxDistrict, Propertyaddress, 

ALTER TABLE project4..nash
DROP COLUMN Saledate