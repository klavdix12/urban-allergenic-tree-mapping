LiDAR Processing - DTM, DSM, and CHM Generation
================================================

This folder contained LiDAR-derived raster products generated from AHN4 point cloud data.
The original datasets included:

  * Digital Terrain Models (DTM)
  * Digital Surface Models (DSM)
  * Canopy Height Models (CHM)

These raster products were generated from AHN4 LiDAR point cloud tiles using PDAL and GDAL
processing workflows and were used for:

  * Tree crown delineation using PyCrown
  * Extraction of structural tree features
  * Random Forest classification

The raster datasets are not included in this archive due to their large size.

Detailed preprocessing workflows, including PDAL pipelines and GDAL commands used for DTM,
DSM, and CHM generation, are provided in:

  scripts/lidar_processing/

The original AHN4 LiDAR point clouds can be obtained from:

  https://geotiles.citg.tudelft.nl/

See the main README for additional metadata and workflow documentation.


OUTPUT LOCATION
---------------

All raster outputs were saved to:

  Z:\Herl_s3482170\data\processed\lidar\

with the following sub-folder structure:

  lidar\
    dsm\
      dsm_resol.tif             DSM, max return, 0.5 m resolution (chosen)
      dsm_inter.tif             DSM, IDW interpolation, 0.5 m (tested, not used)
    dtm\
      dtm_#_inter.tif           DTM tiles, IDW interpolation, 0.5 m (chosen)
      dtm_#_resol.tif           DTM tiles, min return, 0.5 m (tested, not used)
      dtm_interp_merged.tif     Merged DTM mosaic
      dtm_interp_match_dsm.tif  DTM aligned to DSM extent
    chm\
      chm_0p5.tif               CHM at 0.5 m (DSM - DTM, raw)
      chm_0p5_clipped.tif       CHM with negative values set to 0
      chm_0p25.tif              CHM resampled to 0.25 m (matches RGB imagery)


SCRIPTS IN THIS FOLDER
-----------------------

  pdal_dsm_max.json   PDAL pipeline - DSM using max return at 0.5 m (chosen)
  pdal_dsm_idw.json   PDAL pipeline - DSM using IDW interpolation at 0.5 m (tested)
  pdal_dtm_idw.json   PDAL pipeline - DTM using IDW interpolation at 0.5 m (chosen)
  pdal_dtm_min.json   PDAL pipeline - DTM using min return at 0.5 m (tested)
  chm_creation.bat    GDAL batch script - merges, aligns, and computes the CHM


PROCESSING WORKFLOW SUMMARY
-----------------------------

1. DSM - two approaches tested
   
   Max return at 0.5 m resolution (pdal_dsm_max.json, chosen):
   Only unclassified points (Classification 1) are retained, which in AHN4 represent
   vegetation and other above-ground objects. Taking the maximum return per cell captures
   the top of the canopy and produces a structurally rich surface where individual tree
   crowns are visible and well-defined.

   IDW interpolation (pdal_dsm_idw.json, not used):
   Produces a smoother surface but mainly captures the outer frame of the tree crowns
   rather than their internal structure. Discarded in favour of the max-return approach.

2. DTM - two approaches tested

   IDW interpolation at 0.5 m (pdal_dtm_idw.json, chosen):
   Ground points (Classification 2) are filtered, split into 1000 m chunks with
   filters.splitter, cleaned with filters.outlier, and then interpolated using Inverse
   Distance Weighting (radius = 2.0 m, power = 2.0). IDW fills gaps that occur under
   dense vegetation where ground returns are sparse, producing a continuous surface
   without holes.

   Min return at 0.5 m (pdal_dtm_min.json, not used):
   Takes the minimum return per cell without interpolation. At 0.5 m resolution the gaps
   in ground coverage under dense canopy are reduced compared to finer resolutions (0.25 m
   was tested first), but the surface still contains holes that propagate as gaps in the
   final CHM. Discarded in favour of IDW.

3. DTM merging and alignment

   The DTM is produced as numbered tiles by filters.splitter. These are mosaicked into a
   single VRT with gdalbuildvrt and converted to GeoTIFF with gdal_translate. The merged
   DTM is then warped to exactly match the DSM extent and pixel count using gdalwarp,
   because PDAL tiling can introduce a one-pixel size difference between the two surfaces.

4. CHM computation

   The CHM is computed as CHM = DSM - DTM using gdal_calc. Cells where either input is
   nodata are assigned nodata in the output. Negative values (caused by small misalignments
   in flat areas or under dense canopy) are clipped to zero. The final CHM is resampled
   from 0.5 m to 0.25 m using bilinear interpolation to match the resolution of the RGB
   aerial imagery used for tree crown delineation.


SOFTWARE
--------

  PDAL              Point cloud filtering and rasterisation
  GDAL / osgeo_utils  Raster merging, warping, and CHM calculation

All processing used the RD New coordinate reference system (EPSG:28992).
