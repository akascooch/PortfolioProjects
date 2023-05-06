/***************************************************************************************************************************************/
--CLEANING DATA IN SQL
/***************************************************************************************************************************************/
Select *
From   PortfolioProject.dbo.NashvilleHousing ;
/***************************************************************************************************************************************/
-- Standardize Date Format
Select SaleDateConverted
,      convert(date, SaleDate)
From   NashvilleHousing ;

Update NashvilleHousing
Set    SaleDate = convert(date, SaleDate) ;

Alter Table NashvilleHousing Add SaleDateConverted date ;

Update NashvilleHousing
Set    SaleDateConverted = convert(date, SaleDate) ;
/***************************************************************************************************************************************/
-- If it doesn't Update properly
Select   *
From     NashvilleHousing
--Where  PropertyAddress Is Null ;
Order By ParcelID ;

Select N.ParcelID
,      N.PropertyAddress
,      NH.ParcelID
,      NH.PropertyAddress
,      isnull(N.PropertyAddress, NH.PropertyAddress)
From   NashvilleHousing                As N
       Inner Join dbo.NashvilleHousing As NH
             On NH.ParcelID = N.ParcelID
                And N.[UniqueID ] <> NH.[UniqueID ]
Where  N.PropertyAddress Is Null ;

Update N
Set    PropertyAddress = isnull(N.PropertyAddress, NH.PropertyAddress)
From   NashvilleHousing                As N
       Inner Join dbo.NashvilleHousing As NH
             On NH.ParcelID = N.ParcelID
                And N.[UniqueID ] <> NH.[UniqueID ]
Where  N.PropertyAddress Is Null ;
/***************************************************************************************************************************************/
-- Breaking out Address into Individual Columns (Address, City, State)
Select NH.PropertyAddress
,      substring(NH.PropertyAddress, 1, charindex(',', NH.PropertyAddress) - 1)                       As Address
,      substring(NH.PropertyAddress, charindex(',', NH.PropertyAddress) + 1, len(NH.PropertyAddress)) As Address
From   dbo.NashvilleHousing As NH ;

Alter Table NashvilleHousing Add PropertySplitAddress nvarchar(255) ;

Update NashvilleHousing
Set    PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) ;

Alter Table NashvilleHousing Add PropertySplitCity nvarchar(255) ;

Update NashvilleHousing
Set    PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) ;

Select parsename(replace(OwnerAddress, ',', '.'), 3)
,      parsename(replace(OwnerAddress, ',', '.'), 2)
,      parsename(replace(OwnerAddress, ',', '.'), 1)
From   NashvilleHousing ;

Alter Table NashvilleHousing Add OwnerSplitAddress nvarchar(255) ;

Update NashvilleHousing
Set    OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3) ;

Alter Table NashvilleHousing Add OwnerSplitCity nvarchar(255) ;

Update NashvilleHousing
Set    OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2) ;

Alter Table NashvilleHousing Add OwnerSplitState nvarchar(255) ;

Update NashvilleHousing
Set    OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1) ;

Select *
From   dbo.NashvilleHousing As NH ;
/***************************************************************************************************************************************/
-- Change Y and N to Yes and No in "Sold as Vacant" field
Select   Distinct
         ( NH.SoldAsVacant )
,        count(NH.SoldAsVacant)
From     dbo.NashvilleHousing As NH
Group By ( NH.SoldAsVacant )
Order By 2 ;

Select NH.SoldAsVacant
,      Case
             When NH.SoldAsVacant = 'Y' Then
                   'Yes'
             When NH.SoldAsVacant = 'N' Then
                   'No'
             Else
                   NH.SoldAsVacant
       End
From   dbo.NashvilleHousing As NH ;

Update dbo.NashvilleHousing
Set    SoldAsVacant = Case
                            When SoldAsVacant = 'Y' Then
                                  'Yes'
                            When SoldAsVacant = 'N' Then
                                  'No'
                            Else
                                  SoldAsVacant
                      End ;
/***************************************************************************************************************************************/
-- Remove Duplicates
With RowNumCTE
As ( Select *
     ,      row_number() Over ( Partition By NH.ParcelID
                                ,            NH.PropertyAddress
                                ,            NH.SalePrice
                                ,            NH.SaleDate
                                ,            NH.LegalReference
                                Order By NH.[UniqueID ] ) As Row_Num
     From   dbo.NashvilleHousing As NH
--Order By NH.ParcelID
)
Select *
From   RowNumCTE
Where  RowNumCTE.Row_Num > 1 ;
--Order By RowNumCTE.PropertyAddress ;
/***************************************************************************************************************************************/
-- Delete Unused Columns
Select *
From   dbo.NashvilleHousing As NH ;

Alter Table dbo.NashvilleHousing
Drop Column OwnerAddress
,    TaxDistrict
,    PropertyAddress ;

Alter Table dbo.NashvilleHousing Drop Column SaleDate ;
/***************************************************************************************************************************************/
--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO