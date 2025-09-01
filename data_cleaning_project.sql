use portfolioproject;

-- Standardize Date Format
ALTER TABLE NashvilleHousing
ADD COLUMN SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = STR_TO_DATE(SaleDate, '%M %e, %Y'); -- Adjust format if needed

-- Populate Missing PropertyAddress from Matching ParcelID
UPDATE NashvilleHousing a
JOIN NashvilleHousing b 
  ON a.ParcelID = b.ParcelID 
 AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress IS NULL;

-- Split PropertyAddress into Address and City
ALTER TABLE NashvilleHousing ADD COLUMN PropertySplitAddress VARCHAR(255);
ALTER TABLE NashvilleHousing ADD COLUMN PropertySplitCity VARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1),
    PropertySplitCity = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1));

-- Split OwnerAddress into Address, City, and State
ALTER TABLE NashvilleHousing ADD COLUMN OwnerSplitAddress VARCHAR(255);
ALTER TABLE NashvilleHousing ADD COLUMN OwnerSplitCity VARCHAR(255);
ALTER TABLE NashvilleHousing ADD COLUMN OwnerSplitState VARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)),
    OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)),
    OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));

-- Normalize 'SoldAsVacant' Values
SELECT DISTINCT SoldAsVacant, COUNT(*) 
FROM NashvilleHousing
GROUP BY SoldAsVacant;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;

-- Remove Duplicates Using CTE (MySQL 8+)
WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDateConverted, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM NashvilleHousing
)
DELETE FROM NashvilleHousing
WHERE UniqueID IN (
    SELECT UniqueID FROM RowNumCTE WHERE row_num > 1
);

-- Drop Unused Columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;
