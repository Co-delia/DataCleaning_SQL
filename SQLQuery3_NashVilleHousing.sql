/*
	KC Mahlabe 
	SQL Data CLeaning project
	Nashvillehousing data used for cleaning
	9 May 2022
*/
select *
from SqlDataCleaning.dbo.Sheet1$

-----------------------------	Standardize date format	----------------------------------

--- --- --- Altering the data sheet column*** to output the "date" date format --- --- ---
Alter table Sheet1$
Alter column SaleDate date


-----------------------------	POPULATE PROPERTY ADDRESS DATA	--------------------------

--- --- --- --- --- Populating addresses(A by B) by doing a self join on the data  --- ---
select A.ParcelID, A.PropertyAddress,B.ParcelID, B.PropertyAddress ,ISNULL(A.PropertyAddress,B.PropertyAddress)
from SqlDataCleaning.dbo.Sheet1$ A
join SqlDataCleaning.dbo.Sheet1$ B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ]<> B.[UniqueID ]
where A.PropertyAddress is null

--- --- --- Updating the column that was empty to reflect the population --- --- ---
Update A
set PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
from SqlDataCleaning.dbo.Sheet1$ A
join SqlDataCleaning.dbo.Sheet1$ B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ]<> B.[UniqueID ]
where A.PropertyAddress is null



-----------------------------	BREAKING UP ADDRESS INTO INDIVIDUAL COLUMNS	--------------------------

select PropertyAddress
from SqlDataCleaning..Sheet1$

--- --- --- --- --- --- --- Separating data separated by "," character and removing it --- --- --- ---

select  SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress)-1) as Address --- first part before the separated char
	   ,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN (PropertyAddress)) as Address
from SqlDataCleaning.dbo.Sheet1$ 

--- --- --- --- --- --- Adding new columns to represent the the two separated columns  --- --- --- ---
Alter table Sheet1$
Add Property_Address nvarchar(255)

Update Sheet1$
Set Property_Address = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress)-1) 


Alter table Sheet1$
Add Property_City nvarchar(255)

Update Sheet1$
Set Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN (PropertyAddress))

select *
from SqlDataCleaning..Sheet1$

--- --- --- --- --- --- ---		USING PARSENAME --- --- --- --- --- --- --- --- --- --- ---
select OwnerAddress
from SqlDataCleaning.dbo.Sheet1$

select
PARSENAME(replace(OwnerAddress,',' , '.'),3) as Address,
PARSENAME(replace(OwnerAddress,',' , '.'),2) as City,
PARSENAME(replace(OwnerAddress,',' , '.'),1) as State
from SqlDataCleaning.dbo.Sheet1$

--- --- --- --- --- --- Adding new columns to represent the the newly separated 3 separated columns  --- --- --- ---

--- --- --- one
Alter table Sheet1$
Add Owner_Address nvarchar(255)

Update Sheet1$
Set Owner_Address =  PARSENAME(replace(OwnerAddress,',' , '.'),3)

--- --- --- two
Alter table Sheet1$
Add Owner_City nvarchar(255)

Update Sheet1$
Set Owner_City =  PARSENAME(replace(OwnerAddress,',' , '.'),2)

--- --- --- three
Alter table Sheet1$
Add Owner_State nvarchar(255)

Update Sheet1$
Set Owner_State =  PARSENAME(replace(OwnerAddress,',' , '.'),1)

select *
from SqlDataCleaning.dbo.Sheet1$


-----------------------------	CHANGE CHARACTERS (FROM Y AND N TO YES AND NO) 	-----------------------------

--- --- --- count for update checking --- --- ---
select Distinct (SoldAsVacant),COUNT(SoldAsVacant)
from SqlDataCleaning.dbo.Sheet1$
group by SoldAsVacant
order by 2

--- --- --- change characters by using a switch statement --- --- ---
select SoldAsVacant, CASE When SoldAsVacant = 'Y' THEN 'Yes'
						  When SoldAsVacant = 'N' THEN 'No'
						  Else SoldAsVacant
						  END
From SqlDataCleaning.dbo.Sheet1$

--- --- --- Updating tables
Update Sheet1$
Set SoldAsVacant = CASE   When SoldAsVacant = 'Y' THEN 'Yes'
						  When SoldAsVacant = 'N' THEN 'No'
						  Else SoldAsVacant
						  END
from SqlDataCleaning.dbo.Sheet1$

-----------------------------	REMOVING DUPLICATES FROM THE DATA SHEETS 	-----------------------------

--- --- --- Show or select duplicates on the data
With RowNumCTE AS(
	select*, ROW_NUMBER() Over
	(
		Partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
			Order by UniqueID
	)rowNum 
	from SqlDataCleaning.dbo.Sheet1$
)
select *
from RowNumCTE
where rowNum > 1
--order by PropertyAddress

--- --- --- delete duplicates on the data
With RowNumCTE AS(
	select*, ROW_NUMBER() Over
	(
		Partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
			Order by UniqueID
	)rowNum 
	from SqlDataCleaning.dbo.Sheet1$
)
delete
from RowNumCTE
where rowNum > 1


-----------------------------	DELETE UNUSED COLUMNS FROM THE DATA SHEET 	-----------------------------

select * 
from SqlDataCleaning..Sheet1$

Alter table SqlDataCleaning..Sheet1$
drop column OwnerAddress,Sale_Date,PropertyAddress