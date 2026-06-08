@echo off
:: =============================================================================
:: chm_creation.bat
::
:: Generates a Canopy Height Model (CHM) from AHN4 LiDAR-derived DSM and DTM
:: rasters for a single tile (e.g. C_34FN2.LAZ).
::
:: Prerequisites
::   - PDAL installed and on PATH
::   - GDAL installed and on PATH (gdalbuildvrt, gdal_translate, gdalwarp,
::     gdal_calc via osgeo_utils)
::   - PDAL pipeline JSON files present in the same folder as this script:
::       pdal_dsm_max.json   (DSM, chosen approach)
::       pdal_dtm_idw.json   (DTM with IDW interpolation, chosen approach)
::
:: Output location
::   Z:\Herl_s3482170\data\processed\lidar\
::     dsm\dsm_resol.tif            raw DSM (max return, 0.5 m)
::     dtm\dtm_#_inter.tif          DTM tiles (IDW interpolated, 0.5 m)
::     dtm\dtm_interp_merged.tif    merged DTM
::     dtm\dtm_interp_match_dsm.tif DTM aligned to DSM extent
::     chm\chm_0p5.tif              CHM at 0.5 m resolution
::     chm\chm_0p5_clipped.tif      CHM with negative values removed
::     chm\chm_0p25.tif             CHM resampled to 0.25 m (matches RGB)
::
:: Input location
::   Z:\Herl_s3482170\data\raw\lidar_tiles\
::     C_34FN2.LAZ    AHN4 point cloud tile (downloaded from geotiles.citg.tudelft.nl)
::
:: Usage
::   Edit RAW_ROOT and OUT_ROOT below to match your local paths.
::   Edit TILE to match the tile you are processing.
::   Run this script from any directory - all paths are absolute.
:: =============================================================================

set TILE=C_34FN2.LAZ
set RAW_ROOT=Z:\Herl_s3482170\data\raw\lidar_tiles
set OUT_ROOT=Z:\Herl_s3482170\data\processed\lidar

:: Create output sub-directories
mkdir "%OUT_ROOT%\dsm" 2>nul
mkdir "%OUT_ROOT%\dtm" 2>nul
mkdir "%OUT_ROOT%\chm" 2>nul


:: -----------------------------------------------------------------------------
:: Step 1 — Generate DSM (max return, 0.5 m resolution, vegetation class only)
::
:: Classification[1:1] retains only unclassified points which in AHN4 represent
:: vegetation and other above-ground objects. output_type=max takes the highest
:: return within each cell, giving the top-of-canopy surface.
:: -----------------------------------------------------------------------------
echo [1/7] Generating DSM ...
pdal pipeline pdal_dsm_max.json --readers.las.filename="%RAW_ROOT%\%TILE%"
echo DSM written to %OUT_ROOT%\dsm\dsm_resol.tif


:: -----------------------------------------------------------------------------
:: Step 2 — Generate DTM tiles (IDW interpolation, 0.5 m resolution)
::
:: Classification[2:2] keeps only ground points. filters.splitter divides the
:: tile into 1000 m chunks so the IDW writer can process each independently and
:: output numbered sub-tiles (dtm_0_inter.tif, dtm_1_inter.tif, …).
:: filters.outlier removes statistical outliers before interpolation.
:: IDW (radius=2.0, power=2.0) fills gaps that the min-return approach leaves,
:: producing a continuous ground surface without holes under dense vegetation.
:: -----------------------------------------------------------------------------
echo [2/7] Generating DTM tiles (IDW) ...
pdal pipeline pdal_dtm_idw.json --readers.las.filename="%RAW_ROOT%\%TILE%"
echo DTM tiles written to %OUT_ROOT%\dtm\


:: -----------------------------------------------------------------------------
:: Step 3 — Merge DTM tiles into a single GeoTIFF
::
:: gdalbuildvrt creates a virtual mosaic of all numbered sub-tiles, then
:: gdal_translate writes it as a compressed, tiled GeoTIFF.
:: -----------------------------------------------------------------------------
echo [3/7] Merging DTM tiles ...
gdalbuildvrt ^
    -srcnodata -9999 ^
    -vrtnodata -9999 ^
    "%OUT_ROOT%\dtm\dtm_interp.vrt" ^
    "%OUT_ROOT%\dtm\dtm_*.tif"

gdal_translate ^
    "%OUT_ROOT%\dtm\dtm_interp.vrt" ^
    "%OUT_ROOT%\dtm\dtm_interp_merged.tif" ^
    -a_nodata -9999 ^
    -co COMPRESS=LZW ^
    -co TILED=YES
echo Merged DTM written to %OUT_ROOT%\dtm\dtm_interp_merged.tif


:: -----------------------------------------------------------------------------
:: Step 4 — Align DTM extent and pixel count to match the DSM exactly
::
:: The DSM and merged DTM can differ by one pixel at the edges due to how PDAL
:: tiles are written. gdalwarp forces both to the same extent (-te) and output
:: size (-ts) so the cell-by-cell subtraction in Step 5 is pixel-perfect.
:: Extent and pixel count values were read from dsm_resol.tif using gdalinfo.
:: -----------------------------------------------------------------------------
echo [4/7] Aligning DTM to DSM extent ...
gdalwarp ^
    -s_srs EPSG:28992 ^
    -t_srs EPSG:28992 ^
    -te 254999.504 468749.707 260000.004 475000.207 ^
    -ts 10001 12501 ^
    -r bilinear ^
    -srcnodata -9999 -dstnodata -9999 ^
    "%OUT_ROOT%\dtm\dtm_interp_merged.tif" ^
    "%OUT_ROOT%\dtm\dtm_interp_match_dsm.tif"
echo Aligned DTM written to %OUT_ROOT%\dtm\dtm_interp_match_dsm.tif


:: -----------------------------------------------------------------------------
:: Step 5 — Compute CHM = DSM - DTM
::
:: where() preserves nodata cells: output is -9999 wherever either input is
:: nodata, so gaps are not incorrectly given a height value.
:: -----------------------------------------------------------------------------
echo [5/7] Computing CHM (DSM - DTM) ...
python -m osgeo_utils.gdal_calc ^
    -A "%OUT_ROOT%\dsm\dsm_resol.tif" ^
    -B "%OUT_ROOT%\dtm\dtm_interp_match_dsm.tif" ^
    --calc="where((A!=-9999)&(B!=-9999), A-B, -9999)" ^
    --outfile="%OUT_ROOT%\chm\chm_0p5.tif" ^
    --NoDataValue=-9999 ^
    --type=Float32 ^
    --overwrite
echo CHM written to %OUT_ROOT%\chm\chm_0p5.tif


:: -----------------------------------------------------------------------------
:: Step 6 — Clip negative CHM values to zero
::
:: Negative values arise from small DTM/DSM misalignments in flat areas or
:: under dense canopy. They have no physical meaning (a surface cannot be below
:: the ground) and are set to 0.
:: -----------------------------------------------------------------------------
echo [6/7] Removing negative CHM values ...
python -m osgeo_utils.gdal_calc ^
    -A "%OUT_ROOT%\chm\chm_0p5.tif" ^
    --calc="maximum(A,0)" ^
    --outfile="%OUT_ROOT%\chm\chm_0p5_clipped.tif" ^
    --NoDataValue=-9999 ^
    --overwrite
echo Clipped CHM written to %OUT_ROOT%\chm\chm_0p5_clipped.tif


:: -----------------------------------------------------------------------------
:: Step 7 — Resample CHM from 0.5 m to 0.25 m to match RGB aerial imagery
::
:: Bilinear resampling produces a smooth surface suitable for crown delineation
:: with PyCrown and for co-registration with the 0.25 m RGB tiles.
:: -----------------------------------------------------------------------------
echo [7/7] Resampling CHM to 0.25 m ...
gdalwarp ^
    -tr 0.25 0.25 ^
    -r bilinear ^
    -srcnodata -9999 -dstnodata -9999 ^
    "%OUT_ROOT%\chm\chm_0p5_clipped.tif" ^
    "%OUT_ROOT%\chm\chm_0p25.tif"
echo Final CHM written to %OUT_ROOT%\chm\chm_0p25.tif

echo.
echo All steps complete.
echo Outputs saved to %OUT_ROOT%
