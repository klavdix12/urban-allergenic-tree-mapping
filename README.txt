===================================================================================
GENERAL INFORMATION
===================================================================================

Title of Dataset:
Research Data and Trained Models for: Artificial Intelligence for Allergenic Tree
Species Mapping in Urban Environments - A Case Study of Enschede

Author Information:
  Name:         Klaudia Olimpia Herl
  Student ID:   s3482170
  Institution:  Faculty of Geo-Information Science and Earth Observation (ITC),
                University of Twente
  Address:      Hengelosestraat 99, 7514 AE Enschede, The Netherlands
  Email:        k.o.herl@student.utwente.nl

Supervisors:
  Principal Investigator:   Dr. Rosa Aguilar Bolivar (r.aguilarbolivar@utwente.nl)
  Co-investigator:          Dr. ir. Ellen-Wien Augustijn (e.w.augustijn@utwente.nl)

Programme:          MSc Spatial Engineering
Academic Year:      2025-2026

Date of data collection:
  Aerial imagery:   2022 (summer season, leafy season)
  LiDAR (AHN4):    2020-2022
  Field validation: May 2026

Geographic location:
  City:       Enschede
  Province:   Overijssel
  Country:    The Netherlands
  Bounding box (WGS84 approx.): 6.78E, 52.16N to 6.99E, 52.29N
  CRS:        RD New (EPSG:28992)

Funding / Sponsorship:
  This research was conducted as part of the MSc Spatial Engineering thesis at ITC,
  University of Twente. The research is associated with the KAPPA research initiative
  led by ITC, University of Twente, which aims to model the spatial distribution of
  pollen allergies in the Netherlands.
  Reference: https://www.utwente.nl/en/itc/about-itc/centres-of-expertise/
  big-geodata/stories/story/making-allergy-burden-manageable-from-pollen-to-patient/

===================================================================================
SHARING / ACCESS INFORMATION
===================================================================================

License:
  The licensing conditions of the archived materials will be determined by the
  University of Twente repository upon publication.
  Third-party datasets referenced but NOT included in this archive have their own
  licenses as described under DATA & FILE OVERVIEW below.

Recommended citation for this dataset:
  Herl, K.O. (2026). Research Data and Trained Models for Artificial Intelligence
  for Allergenic Tree Species Mapping in Urban Environments - A Case Study of
  Enschede [Dataset]. University of Twente.
  Repository: \\ad.utwente.nl\itc\Archive\CourseData\Upload\Herl_s3482170

Citation for the associated thesis:
  Herl, K.O. (2026). Artificial Intelligence for Allergenic Tree Species Mapping
  in Urban Environments: A Case Study of Enschede. MSc thesis, Faculty of
  Geo-Information Science and Earth Observation (ITC), University of Twente.

Source code repository (GitHub):
  https://github.com/klavdix12/urban-allergenic-tree-mapping

Links to third-party data sources referenced in this research:
  - AHN4 LiDAR data:           https://geotiles.citg.tudelft.nl/ (public, CC0)
  - Aerial imagery (RGB/CIR):  https://geotiles.citg.tudelft.nl/ (public, open)
  - PDOK administrative bounds: https://www.pdok.nl/introductie/-/article/
    administratieve-eenheden-inspire-geharmoniseerd- (public, CC0)
  - Municipal tree inventory:   via 4TU.HERITAGE project /
                                 Municipality of Enschede / Cobra Groeninzicht
  - Crown polygon shapefile:    via 4TU.HERITAGE project
  - UT campus tree inventory:   via University of Twente
  - LCZ classification:         https://zenodo.org/records/8419340 (CC BY 4.0)

===================================================================================
ARCHIVE CONTENTS
===================================================================================

  Herl_s3482170/
    configs/                   YOLO data configuration YAML files
    data/
      raw/                     Empty folders + README (raw data not included)
      interim/                 Intermediate shapefiles (PyCrown output, GT prep)
      processed/               Processed datasets (splits, RF features, predictions)
      external/                Empty folders + README (third-party data not included)
    models/                    Trained YOLO model weights (weights in .pt format, and 
                               validation metrics charts/figures)
    notebooks/
      random_forest/           RF pipeline notebooks
      yolo_detection/          YOLO object detection notebooks
      yolo_segmentation/       YOLO instance segmentation notebooks
      visualization/           YOLO dataset visualization (samples count per split)
    scripts/
      lidar_processing/        PDAL pipelines (.json) and CHM batch script (.bat)
    src/                       Shared Python path utilities
    thesis_pdf/                Final MSc thesis (PDF)
    README.txt                 This file
    requirements.yaml          Environment specification


configs/
  yolov11s_object_detection_rgb_config_v01.yaml
  yolov11s_object_detection_irrg_config_v01.yaml
  yolov11s_instance_segmentation_rgb_config_v01.yaml
  yolov11s_instance_segmentation_irrg_config_v01.yaml
    YOLO data configuration files specifying train/val/test image directories,
    number of classes, and class names. Passed to model.train() and model.val()
    via the data= argument in the training notebooks.

models/
  yolov11_detection/
    rgb/ and irrg/ — each containing:
      weights/
        best.pt    Best checkpoint by validation mAP
        last.pt    Final checkpoint at end of training
      args.yaml                  Ultralytics training arguments
      results.csv                Per-epoch training and validation loss values
      results.png                Training loss curve plot
      confusion_matrix.png       Raw confusion matrix on test set
      confusion_matrix_normalized.png  Normalised confusion matrix
      BoxF1_curve.png            F1 vs confidence threshold curve
      BoxP_curve.png             Precision vs confidence threshold curve
      BoxPR_curve.png            Precision-recall curve
      BoxR_curve.png             Recall vs confidence threshold curve
      labels.jpg                 Annotation distribution visualisation
      loss.png                   Loss curve summary
      test_metrics.csv           Per-class precision/recall/mAP on test set
      val_metrics.csv            Per-class precision/recall/mAP on val set

  yolov11_segmentation/
    rgb/ and irrg/ — same structure as yolov11_detection/ above, with
    additional MaskF1, MaskP, MaskPR, MaskR curve files for segmentation masks.

  Load YOLO models: from ultralytics import YOLO; model = YOLO('best.pt')

notebooks/
  random_forest/
    preprocessing/
      pycrown_crown_segmentation.ipynb
        Tree crown delineation from AHN4 LiDAR using PyCrown.
        Outputs: pycrown_segmentation/enschede_pycrown_segmentation_tile34fn2_v01.shp

      crown_species_labelling.ipynb
        Spatial join of PyCrown crowns with municipal tree inventory.
        Assigns species labels using 1-point / closest-point / majority-vote rules.
        Outputs: tree_shp/tree_crowns_rf.shp

      crown_feature_extraction.ipynb
        Extracts per-crown spectral (RGB, NIR, NDVI) and structural (CHM) features.
        Outputs: tree_shp/tree_features_rf.shp

    binary_classification/
      rf_binary_fc1.ipynb
        Binary RF classification — Feature Configuration I (no NDVI).
        Outputs: rf_binary/allerg_pred_binary_fc1.shp

      rf_binary_fc2.ipynb
        Binary RF classification — Feature Configuration II (with NDVI).
        Outputs: rf_binary/allerg_pred_binary_fc2.shp

    multi_class_classification/
      rf_multiclass_fc1.ipynb
        Multi-class RF species classification — Feature Configuration I.
        Outputs: rf_multiclass/allerg_pred_species_fc1.shp

      rf_multiclass_fc2.ipynb
        Multi-class RF species classification — Feature Configuration II
        (Quercus downsampled; used for all downstream analyses).
        Outputs: rf_multiclass/allerg_pred_species_fc2.shp

    prediction_validation/
      campus_prediction_validation.ipynb
        Validates RF species predictions against the UT campus tree inventory.
        Outputs: tree_shp/campus_trees_validated.shp

    lcz_analysis/
      lcz_species_analysis.ipynb
        Analyses RF prediction distribution across Local Climate Zone classes.
        Uses rf_multiclass/allerg_pred_species_fc2.shp as input.

  yolo_detection/
    preprocessing/
      yolo_detection_gt_prep.ipynb
        Integrates crown polygons with municipal inventory to produce
        bounding-box ground-truth shapefiles for YOLO detection training.

      yolo_detection_rgb_tiles_prep.ipynb
        Generates RGB 512x512 patches and YOLO bbox label files.
        Outputs: splits_rgb/ (train/val/test — images/ and labels/)

      yolo_detection_irrg_tiles_prep.ipynb
        Generates IRRG 512x512 patches and YOLO bbox label files.
        Outputs: splits_irrg/ (train/val/test — images/ and labels/)

    rgb/
      yolo_detection_rgb.ipynb
        Trains, validates, and evaluates the RGB object detection model.

    irrg/
      yolo_detection_irrg.ipynb
        Trains, validates, and evaluates the IRRG object detection model.

  yolo_segmentation/
    preprocessing/
      yolo_segmentation_gt_prep.ipynb
        Prepares crown polygon annotations for segmentation training.

      yolo_segmentation_rgb_tiles_prep.ipynb
        Generates RGB patches and YOLO polygon mask label files.
        Outputs: splits_rgb_seg/ (train/val/test — images/ and labels/)

      yolo_segmentation_irrg_tiles_prep.ipynb
        Generates IRRG patches and YOLO polygon mask label files.
        Outputs: splits_irrg_seg/ (train/val/test — images/ and labels/)

    rgb/
      yolo_segmentation_rgb.ipynb
        Trains, validates, evaluates the RGB segmentation model, and exports
        predictions as GeoJSON.

    irrg/
      yolo_segmentation_irrg.ipynb
        Trains, validates, evaluates the IRRG segmentation model, and exports
        predictions as GeoJSON.

  visualization/
    yolo_dataset_visualisation.ipynb
      Universal visualisation notebook for all four YOLO datasets.
      Set SPLITS_DIR, TASK, and CLASS_NAMES at the top; works for detection
      and segmentation, RGB and IRRG.

scripts/
  lidar_processing/
    pdal_dsm_max.json    PDAL pipeline — DSM, max return, 0.5 m (chosen)
    pdal_dsm_idw.json    PDAL pipeline — DSM, IDW interpolation, 0.5 m (tested)
    pdal_dtm_idw.json    PDAL pipeline — DTM, IDW interpolation, 0.5 m (chosen)
    pdal_dtm_min.json    PDAL pipeline — DTM, min return, 0.5 m (tested)
    chm_creation.bat     GDAL batch script — merges DTM tiles, aligns extents,
                         computes CHM, clips negatives, resamples to 0.25 m
    README.txt           Detailed workflow documentation for LiDAR processing

===================================================================================
DATA & FILE OVERVIEW
===================================================================================

This archive contains DERIVED and MODEL data only. Raw input datasets (third-party)
are NOT included due to licensing and size constraints, but are fully described below.

---- NOT SUBMITTED (raw input data, described only) ----

AHN4 LiDAR point cloud data (tile C_34FN2.LAZ):
  Source:      Actueel Hoogtebestand Nederland (AHN), via GeoTiles.nl
  URL:         https://geotiles.citg.tudelft.nl/
  License:     CC0 (public domain)
  Acquisition: 2020-2022; ~10-14 points/m2
  Reason:      File size; publicly available

RGB and CIR aerial imagery (tiles 34FN2, 34FZ2, 35AN1):
  Source:      Beeldmateriaal Nederland, via GeoTiles.nl
  URL:         https://geotiles.citg.tudelft.nl/
  License:     Open (see Beeldmateriaal.nl terms)
  Acquisition: 2022, summer season, 25 cm resolution
  Reason:      File size; publicly available

Municipal tree inventory (Bomen_gbi.shp):
  Source:      Municipality of Enschede, maintained by Cobra Groeninzicht,
               facilitated via 4TU.HERITAGE research project
  License:     Research use only; contact Municipality of Enschede
  Reason:      Third-party data with access restrictions

Crown polygon shapefile:
  Source:      4TU.HERITAGE research project
  License:     Research use only; contact 4TU.HERITAGE for access
  Reason:      Third-party data

Campus tree inventory (bomen_campus.shp):
  Source:      University of Twente, vegetation maintenance staff
  License:     Internal university data; contact UT facilities management
  Reason:      Third-party data

LCZ classification raster (lcz_v3.tif):
  Source:      Open-access Zenodo repository
  URL:         https://zenodo.org/records/8419340
  License:     CC BY 4.0
  Reason:      Publicly available; direct link provided

PDOK administrative boundary (Enschede):
  Source:      PDOK (Publieke Dienstverlening Op de Kaart)
  URL:         https://www.pdok.nl/introductie/-/article/
               administratieve-eenheden-inspire-geharmoniseerd- 
  License:     CC0
  Reason:      Publicly available

===================================================================================
METHODOLOGICAL INFORMATION
===================================================================================

Overview:
  This research evaluated one-step and two-step AI-based approaches for mapping
  five allergenic tree species (Betula, Alnus, Fraxinus, Quercus, Platanus) in the
  city of Enschede, the Netherlands, using 25 cm aerial imagery and AHN4 LiDAR.

  One-step approach:
    YOLOv11s object detection trained on 512x512 pixel image patches with bounding
    box annotations for 5 allergenic species. Two spectral configurations evaluated:
    RGB (default augmentation) and IRRG (colour augmentation disabled).

  Two-step approach — Crown delineation:
    (a) YOLOv11s-seg instance segmentation for image-based binary crown delineation.
    (b) PyCrown LiDAR-based crown delineation using CHM local maximum detection
        followed by Dalponte region-growing segmentation. Tile 34FN2 only.

  Two-step approach — Species classification:
    Random Forest classifier applied in two hierarchical stages:
    (1) Binary classification: allergenic vs. non-allergenic
    (2) Multi-class classification: 5 allergenic species
    Two feature configurations evaluated:
      FC1 — spectral + structural features (no NDVI; original class distribution)
      FC2 — FC1 + NDVI mean/std; Quercus downsampled to 600 training samples
    Hyperparameter tuning via GridSearchCV (10-fold cross-validation).
    SHAP analysis for feature importance interpretation.

  Validation:
    (a) Campus validation: spatial intersection with UT campus inventory
        (n=410 matched crowns)
    (b) Field validation: visual and PictureThis-assisted species identification
        for unmatched crown predictions on campus

LiDAR preprocessing:
  1. AHN4 LAZ tile loaded via PDAL
  2. DTM generated with IDW interpolation (radius=2m, power=2, res=0.5m)
  3. DSM generated with max-return rasterisation (res=0.5m, unclassified pts only)
  4. DTM tiles merged (gdalbuildvrt + gdal_translate), aligned to DSM extent (gdalwarp)
  5. CHM = DSM - DTM; negative values clipped to 0 (gdal_calc)
  6. CHM resampled from 0.5m to 0.25m to match aerial imagery (gdalwarp)

Feature extraction:
  1. Crown polygons spatially joined to municipal inventory (left join)
  2. Pixels fully within each polygon extracted from RGB, CIR, CHM rasters
  3. Mean and standard deviation computed per band per crown
  4. NDVI = (NIR - R) / (NIR + R) computed from CIR and RGB
  5. Crown area computed from polygon geometry (m2)

Computational environment:
  Platform:  University of Twente CRIB computing platform
  Hardware:  72 vCPUs, Intel x86-64, 768 GB RAM, NVIDIA RTX A4000 GPU
  OS:        Linux
  Python:    3.8.10
  YOLO models trained on GPU; Random Forest trained on CPU

Key software:
  ultralytics    YOLOv11 training and inference
  scikit-learn   Random Forest, GridSearchCV, metrics
  shap           SHAP feature importance
  geopandas      Vector data and spatial joins
  rasterio       Raster I/O and windowed reads
  pdal           Point cloud processing (DTM/DSM generation)
  pycrown        LiDAR-based tree crown delineation
  gdal           CHM merging, alignment, and computation
  qgis           Manual crown polygon refinement and visualisation
  Full dependency list: requirements.yaml

Spatial reference system:
  All spatial data: RD New (EPSG:28992)
  Units: metres (linear), square metres (area)

Quality assurance:
  - Crown polygons manually reviewed and refined in QGIS
  - Invalid geometries and duplicates removed from all shapefiles
  - Species names standardised to genus level
  - Class imbalance addressed via Quercus downsampling in YOLO object detection 
    and Random Forest FC2

People involved:
  Data collection and processing: Klaudia Olimpia Herl (MSc student)
  Supervision: Dr. Rosa Aguilar Bolivar, Dr. ir. Ellen-Wien Augustijn

===================================================================================
DATA-SPECIFIC INFORMATION
===================================================================================

--- YOLO Model Files (.pt) ---

Format:    PyTorch model weights (Ultralytics format)
Load:      from ultralytics import YOLO; model = YOLO('filename.pt')
Input:     512x512 pixel 3-band uint8 GeoTIFF patch (RGB or IRRG)
Output detection:    Bounding boxes, class labels, confidence scores
Output segmentation: Polygon masks, bounding boxes, confidence scores
Classes (detection): 0=Betula, 1=Alnus, 2=Fraxinus, 3=Quercus, 4=Platanus
Classes (segmentation): 0=tree (binary)

===================================================================================
DUBLIN CORE METADATA
===================================================================================

DC.Title:       Research Data for Allergenic Tree Species Mapping in Enschede
DC.Creator:     Herl, Klaudia Olimpia
DC.Subject:     Allergenic trees; Urban remote sensing; LiDAR; Machine learning;
                Tree species classification; Enschede; Random Forest; YOLO;
                Instance segmentation; Local Climate Zones; SHAP
DC.Description: Trained machine learning models, derived crown segmentation shapefiles,
                and feature datasets produced for the MSc thesis on AI-based allergenic
                tree species mapping in Enschede, Netherlands.
DC.Publisher:   University of Twente, Faculty ITC
DC.Contributor: Dr. Rosa Aguilar Bolivar; Dr. ir. Ellen-Wien Augustijn
DC.Date:        2026-06-08
DC.Type:        Dataset
DC.Format:      SHP; PKL; PT; YAML; TXT; IPYNB
DC.Identifier:  \\ad.utwente.nl\itc\Archive\CourseData\Upload\Herl_s3482170
DC.Source:      AHN4 (https://geotiles.citg.tudelft.nl);
                Beeldmateriaal Nederland (https://geotiles.citg.tudelft.nl);
                4TU.HERITAGE project
DC.Language:    en
DC.Relation:    https://github.com/klavdix12/urban-allergenic-tree-mapping
DC.Coverage:    Enschede, Overijssel, Netherlands; EPSG:28992;
                Bounding box: 6.78E 52.16N 6.99E 52.29N
DC.Rights:      CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/)
