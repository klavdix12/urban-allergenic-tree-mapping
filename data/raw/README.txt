Raw Input Datasets
==================

This folder originally contained raw input datasets used in this research.
All datasets are not included in this archive due to their large file size
or redistribution restrictions.

  raw/
    cir_tiles/             CIR aerial imagery tiles
    enschede_boundary/     Enschede administrative boundary shapefile
    lidar_tiles/           AHN4 LiDAR point cloud tiles
    rgb_tiles/             RGB aerial imagery tiles
    README.txt


FOLDER CONTENTS
---------------

lidar_tiles/
  AHN4 LiDAR point cloud tiles in LAZ format. Used to generate Digital Terrain
  Models (DTM), Digital Surface Models (DSM), and Canopy Height Models (CHM)
  for individual tree crown delineation and structural feature extraction.

  Tile processed in this study: C_34FN2.LAZ (covers central Enschede)
  Acquisition period: 2020-2022

  Source: https://geotiles.citg.tudelft.nl/

rgb_tiles/
  RGB aerial imagery tiles at 0.25 m spatial resolution in GeoTIFF format.
  Used for Random Forest spectral feature extraction and for training and
  evaluating YOLO object detection and instance segmentation models.

  Tiles used: RGB_34FN2.tif, RGB_34FZ2.tif, RGB_35AN1.tif
  Acquisition year: 2022

  Source: https://geotiles.citg.tudelft.nl/

cir_tiles/
  CIR (Colour Infrared) aerial imagery tiles at 0.25 m spatial resolution
  in GeoTIFF format. Used to derive near-infrared features, calculate NDVI,
  and train and evaluate YOLO models using the IRRG band configuration.

  Tiles used: CIR_34FN2.tif, CIR_34FZ2.tif, CIR_35AN1.tif
  Acquisition year: 2022

  Source: https://geotiles.citg.tudelft.nl/

enschede_boundary/
  Administrative boundary shapefile for the municipality of Enschede (PDOK).
  Used to define the study area extent and spatially clip datasets to the
  municipality boundary.

  Source: https://www.pdok.nl/introductie/-/article/administratieve-eenheden-inspire-geharmoniseerd-


NOTE
----

All datasets listed above can be obtained directly from the original providers
at the sources listed above. See the main README for additional metadata,
acquisition dates, licensing information, and preprocessing workflow details.
