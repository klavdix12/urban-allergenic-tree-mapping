Intermediate Datasets
=====================

This folder contains intermediate datasets generated during the preprocessing
workflows. These datasets were produced from the original LiDAR, aerial imagery,
and ground-truth inventory data and served as inputs for model training,
evaluation, and feature extraction.

  interim/
    pycrown_segmentation/      Tree crown polygons from PyCrown delineation
    random_forest_gt_prep/     Labelled crown shapefiles for Random Forest
    yolo_detection_gt_prep/    Ground-truth shapefiles for YOLO object detection
    yolo_segmentation_gt_prep/ Ground-truth shapefiles for YOLO instance segmentation


FOLDER CONTENTS
---------------

pycrown_segmentation/
  Tree crown polygons delineated using the PyCrown library from the Canopy Height
  Model (CHM) derived from AHN4 LiDAR data (tile 34FN2). After delineation, crowns
  were exported to QGIS where over-segmented polygons with an area smaller than
  15 m² were removed.

  The archived shapefile:
    enschede_pycrown_segmentation_tile34fn2_v01.shp
  represents the cleaned crown delineation used as input for the Random Forest
  ground-truth preprocessing workflow (crown_species_labelling.ipynb).

  The PyCrown processing workflow is documented in:
    notebooks/random_forest/pycrown_crown_segmentation.ipynb

random_forest_gt_prep/
  Intermediate shapefiles produced during the Random Forest ground-truth
  preprocessing workflow, including the spatially joined crown polygons with
  assigned species labels derived from the municipal tree inventory.

  Used as input for:
    notebooks/random_forest/crown_feature_extraction.ipynb

  The preprocessing workflow is documented in:
    notebooks/random_forest/crown_species_labelling.ipynb

yolo_detection_gt_prep/
  Cleaned and labelled ground-truth shapefiles used to generate YOLO bounding-box
  annotations for the object detection experiments. Produced by integrating the
  crown polygon dataset with municipal tree inventory points.

  The preprocessing workflow is documented in:
    notebooks/yolo_detection/yolo_detection_gt_prep.ipynb

yolo_segmentation_gt_prep/
  Cleaned crown polygon shapefiles used to generate YOLO segmentation mask
  annotations for the instance segmentation experiments.

  The preprocessing workflow is documented in:
    notebooks/yolo_segmentation/yolo_segmentation_gt_prep.ipynb


NOTE ON RASTER PRODUCTS
------------------------

Intermediate raster products (uint8 RGB tiles, IRRG composites) are not stored
in this folder and are not included in the archive. These rasters are generated
in memory during the tile preprocessing notebooks and are never written to disk:

  notebooks/yolo_detection/yolo_detection_rgb_tiles_prep.ipynb
  notebooks/yolo_detection/yolo_detection_irrg_tiles_prep.ipynb
  notebooks/yolo_segmentation/yolo_segmentation_rgb_tiles_prep.ipynb
  notebooks/yolo_segmentation/yolo_segmentation_irrg_tiles_prep.ipynb

See the main README for additional details regarding preprocessing workflows.
