Processed Datasets
==================

This folder contains processed datasets generated during the research workflow
and used for model training, validation, and evaluation.

  processed/
    lidar/                 LiDAR-derived raster products (DTM, DSM, CHM)
    rf_binary/             Feature datasets and predictions for binary RF classification
    rf_multiclass/         Feature datasets and predictions for multi-class RF classification
    splits_irrg/           IRRG image patches and labels for YOLO object detection
    splits_irrg_seg/       IRRG image patches and labels for YOLO instance segmentation
    splits_rgb/            RGB image patches and labels for YOLO object detection
    splits_rgb_seg/        RGB image patches and labels for YOLO instance segmentation
    tree_shp/              Intermediate and final crown shapefiles for Random Forest
    README.txt


FOLDER CONTENTS
---------------

lidar/
  LiDAR-derived raster products generated from AHN4 point cloud data (tile 34FN2).
  Due to their large file size, the raster products are not included in this archive.
  Processing workflows are documented in scripts/lidar_processing/.

  Sub-folder structure:
    lidar/
      dsm/
        dsm_resol.tif             DSM, max return, 0.5 m (chosen)
        dsm_inter.tif             DSM, IDW interpolation, 0.5 m (tested, not used)
      dtm/
        dtm_#_inter.tif           DTM tiles, IDW interpolation, 0.5 m (chosen)
        dtm_#_resol.tif           DTM tiles, min return, 0.5 m (tested, not used)
        dtm_interp_merged.tif     Merged DTM mosaic
        dtm_interp_match_dsm.tif  DTM aligned to DSM extent
      chm/
        chm_0p5.tif               CHM at 0.5 m (DSM - DTM, raw)
        chm_0p5_clipped.tif       CHM with negative values set to 0
        chm_0p25.tif              CHM resampled to 0.25 m (matches RGB imagery)

rf_binary/
  Input feature datasets and prediction outputs for the binary Random Forest
  classification stage (allergenic vs non-allergenic trees).

  A single feature dataset was used as input for both feature configurations:
    Feature Configuration I (FC1)  — spectral and structural features only
    Feature Configuration II (FC2) — spectral, structural, and NDVI-derived features

  Sub-folder structure:
    rf_binary/
      features/
        features_fc1.csv          Input features for FC1 (no NDVI)
        features_fc2.csv          Input features for FC2 (with NDVI)
      predictions/
        predictions_fc1.shp       Binary predictions for FC1
        predictions_fc2.shp       Binary predictions for FC2

rf_multiclass/
  Prediction outputs for the multi-class Random Forest classification stage
  (species-level classification of allergenic tree crowns).

  The input to this stage is the binary classification output from rf_binary/
  predictions/ — only crowns predicted as allergenic are forwarded here.
  Features are not duplicated; the same feature datasets stored in rf_binary/
  features/ are reused.

  Sub-folder structure:
    rf_multiclass/
      predictions/
        predictions_fc1.shp       Multi-class species predictions for FC1
        predictions_fc2.shp       Multi-class species predictions for FC2

splits_rgb/
  RGB image patches and YOLO bounding-box annotations for object detection.
  Due to archive size limitations, representative samples are included.

  Sub-folder structure:
    splits_rgb/
      train/
        images/                   Training image patches (.tif)
        labels/                   YOLO bounding-box annotation files (.txt)
      val/
        images/
        labels/
      test/
        images/
        labels/

splits_irrg/
  IRRG image patches and YOLO bounding-box annotations for object detection.
  Same structure as splits_rgb/.

splits_rgb_seg/
  RGB image patches and YOLO polygon mask annotations for instance segmentation.
  Same structure as splits_rgb/.

splits_irrg_seg/
  IRRG image patches and YOLO polygon mask annotations for instance segmentation.
  Same structure as splits_rgb/.

tree_shp/
  Intermediate and final crown shapefiles shared across the Random Forest pipeline.

    species_points.shp            Cleaned municipal inventory points (target species)
    tree_crowns_rf.shp            Crown polygons with assigned species labels
    tree_features_rf.shp          Crown polygons with extracted spectral/structural features
    allergenic_points_campus.shp  Cleaned campus inventory points (target species)
    campus_trees_validated.shp    Campus crown predictions with true labels for QGIS validation


See the main README for details regarding preprocessing, feature extraction,
model development, and evaluation workflows.
