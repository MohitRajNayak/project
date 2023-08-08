/* 
Cleaning Data
*/

Select *
From Housing
--------------------------------------------------------------------------------------
-- Date Formate

Select SaleDate
From Housing

Select SaleDate,CONVERT(date,SaleDate)
From Housing

Alter table housing
add SalesDateCon date;

update Housing
set SalesDateCon = CONVERT(date,SaleDate)

Select SaleDate,SalesDateCon
From Housing

--------------------------------------------------------------------------------------

--proprerty add date

Select *
From Housing
where PropertyAddress is null

Select *
From Housing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
From Housing a
join Housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
From Housing a
join Housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
From Housing a
join Housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,'No Address')
--From Housing a
--join Housing b
--on a.ParcelID = b.ParcelID
--and a.[UniqueID ] <> b.[UniqueID ]

--------------------------------------------------------------------------------------

--Spilting a columns into multiple columns

select PropertyAddress
from Housing

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) as address
from Housing

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) as address
,CHARINDEX(',',PropertyAddress)
from Housing

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address
from Housing

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as address2
from Housing

Alter table housing
add address varchar(255);

update Housing
set address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter table housing
add city varchar(255);

update Housing
set city = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select address,city
from Housing

select OwnerAddress
from Housing

select
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from Housing

Alter table housing
add owner_address varchar(255);

update Housing
set owner_address = PARSENAME(replace(OwnerAddress,',','.'),3)

Alter table housing
add owner_city varchar(255);

update Housing
set owner_city = PARSENAME(replace(OwnerAddress,',','.'),2)

Alter table housing
add owner_state varchar(255);

update Housing
set owner_state = PARSENAME(replace(OwnerAddress,',','.'),1)

select OwnerAddress,owner_address,owner_city,owner_state
from Housing

--------------------------------------------------------------------------------------

--replace string value in columns

select distinct SoldAsVacant
from Housing

select SoldAsVacant,
case when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	else SoldAsVacant
	end
from Housing

update Housing
set SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	else SoldAsVacant
	end

select distinct SoldAsVacant, COUNT(SoldAsVacant)
from Housing
group by SoldAsVacant;

--------------------------------------------------------------------------------------

-- remove duplicate

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Housing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- to delete

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Housing
--order by ParcelID
)
delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--------------------------------------------------------------------------------------

-- delete rows

select *
from Housing

Alter table Housing
drop column PropertyAddress,OwnerAddress,SaleDate
