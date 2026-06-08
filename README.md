# Allergenic Tree Species Mapping in Urban Environments
### A Case Study of Enschede, the Netherlands

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Python 3.8](https://img.shields.io/badge/python-3.8-blue.svg)](https://www.python.org/)
[![Ultralytics YOLOv11](https://img.shields.io/badge/YOLO-v11-green.svg)](https://github.com/ultralytics/ultralytics)
[![scikit-learn](https://img.shields.io/badge/scikit--learn-ML-orange.svg)](https://scikit-learn.org/)

> MSc Spatial Engineering thesis — Faculty of Geo-Information Science and Earth Observation (ITC), University of Twente, 2025–2026

This repository contains the source code, preprocessing pipelines, training notebooks, and evaluation workflows developed for the MSc thesis:

**"Artificial Intelligence for Allergenic Tree Species Mapping in Urban Environments: A Case Study of Enschede"**

The research explores whether AI-based approaches can detect and classify five allergenic tree species — *Betula*, *Alnus*, *Fraxinus*, *Quercus*, and *Platanus* — in the city of Enschede using 25 cm aerial imagery and AHN4 LiDAR data, including trees located in private areas not covered by the municipal inventory.

---

## Overview

Urban trees improve quality of life but also pose health risks through allergenic pollen. Municipal tree inventories document only publicly managed trees, leaving private and unmanaged areas unmapped. This study addresses this gap by applying two main AI-based workflows:

- **One-step approach** — YOLOv11s object detection directly detects and classifies allergenic tree species from aerial image patches.
- **Two-step approach** — Tree crown delineation (LiDAR-based PyCrown or image-based YOLOv11s-seg) followed by Random Forest species classification using extracted spectral and structural crown features.

Both approaches were evaluated across two spectral configurations: standard **RGB** and **IRRG** (Infrared-Red-Green).

---

## Methodology

```
                     ┌─────────────────────────────────────────┐
                     │           Input Data                     │
                     │  RGB + CIR aerial imagery (25 cm)        │
                     │  AHN4 LiDAR point cloud (tile 34FN2)     │
                     │  Municipal tree inventory (Enschede)     │
                     └──────────────┬──────────────────────────┘
                                    │
               ┌────────────────────┴────────────────────┐
               │                                         │
       ┌───────▼────────┐                    ┌───────────▼──────────┐
       │  ONE-STEP      │                    │   TWO-STEP           │
       │  APPROACH      │                    │   APPROACH           │
       │                │                    │                      │
       │ YOLOv11s       │                    │ Crown delineation:   │
       │ Object         │                    │  (a) PyCrown/LiDAR   │
       │ Detection      │                    │  (b) YOLOv11s-seg    │
       │                │                    │                      │
       │ RGB / IRRG     │                    │ ↓                    │
       └───────┬────────┘                    │ Feature extraction   │
               │                             │ (RGB, NIR, NDVI, CHM)│
               │                             │                      │
               │                             │ ↓                    │
               │                             │ Random Forest        │
               │                             │ Binary + Multi-class │
               │                             └───────────┬──────────┘
               │                                         │
               └──────────────┬──────────────────────────┘
                              │
                    ┌─────────▼──────────┐
                    │  Species mapping   │
                    │  + LCZ analysis    │
                    │  + Campus validation│
                    └────────────────────┘
```

---

## Repository Structure

```
Herl_s3482170/
├── configs/                          # YOLO data configuration YAML files
├── data/
│   ├── raw/                          # Raw input data (not included — see below)
│   ├── interim/                      # Intermediate shapefiles (PyCrown, GT prep)
│   ├── processed/                    # Processed splits, RF features, predictions
│   └── external/                     # Third-party datasets (not included — see below)
├── models/
│   ├── yolov11_detection/rgb|irrg/   # YOLO detection weights + metric plots
│   ├── yolov11_segmentation/rgb|irrg/# YOLO segmentation weights + metric plots
│   └── random_forest/                # Trained RF model weights (.pkl)
├── notebooks/
│   ├── random_forest/                # RF pipeline (see execution order below)
│   ├── yolo_detection/               # YOLO detection pipeline
│   └── yolo_segmentation/            # YOLO segmentation pipeline
├── scripts/
│   └── lidar_processing/             # PDAL pipelines + CHM batch script
├── src/                              # Shared path utilities
├── .gitignore
├── LICENSE
├── README.md                         # This file
├── README.txt                        # Full archive metadata (for university deposit)
└── requirements.txt                  # Python dependencies
```

---

## Data

The following input datasets are **not included** in this repository due to file size or access restrictions. Place them in the corresponding folders before running the notebooks.

| Dataset | Folder | Source |
|---|---|---|
| AHN4 LiDAR tiles (LAZ) | `data/raw/lidar_tiles/` | [geotiles.citg.tudelft.nl](https://geotiles.citg.tudelft.nl/) |
| RGB aerial imagery (25 cm) | `data/raw/rgb_tiles/` | [geotiles.citg.tudelft.nl](https://geotiles.citg.tudelft.nl/) |
| CIR aerial imagery (25 cm) | `data/raw/cir_tiles/` | [geotiles.citg.tudelft.nl](https://geotiles.citg.tudelft.nl/) |
| Enschede boundary (PDOK) | `data/raw/enschede_boundary/` | [pdok.nl](https://www.pdok.nl) |
| Municipal tree inventory | `data/external/municipal_gt/` | 4TU.HERITAGE / Municipality of Enschede |
| Crown polygon shapefile | `data/external/crown_polygons_gt/` | 4TU.HERITAGE project |
| UT campus tree inventory | `data/external/ut_campus_gt/` | University of Twente |
| LCZ raster (Enschede) | `data/external/lcz_raster/` | [zenodo.org/records/8419340](https://zenodo.org/records/8419340) |

Tiles used: `34FN2` (train), `34FZ2` (val), `35AN1` (test). Imagery acquisition year: 2022.

---

## Installation

The notebooks were developed on the University of Twente CRIB computing platform (Python 3.8.10, NVIDIA RTX A4000). To reproduce locally:

```bash
pip install -r requirements.txt
```

> **Note for geospatial packages:** `geopandas`, `rasterio`, `shapely`, and `fiona` can have dependency conflicts when installed via pip on some systems. Using `conda-forge` is recommended if you are working in a conda environment.

**External tools** (not pip-installable):
- [PDAL](https://pdal.io) — point cloud processing (DTM/DSM generation)
- [GDAL CLI](https://gdal.org) — CHM merging, alignment, and computation
- [QGIS](https://qgis.org) — manual crown polygon refinement

---

## Execution Order

### LiDAR preprocessing (run once, before anything else)

```
scripts/lidar_processing/
  1. pdal_dtm_idw.json          → generate DTM tiles
  2. pdal_dsm_max.json          → generate DSM
  3. chm_creation.bat           → merge DTM, align extents, compute CHM
```

---

### Random Forest pipeline

```
notebooks/random_forest/

preprocessing/
  1. pycrown_crown_segmentation.ipynb     → delineate tree crowns from LiDAR
  2. crown_species_labelling.ipynb        → assign species labels from municipal inventory
  3. crown_feature_extraction.ipynb       → extract spectral + structural features

binary_classification/
  4. rf_binary_fc1.ipynb                  → train binary RF (no NDVI)
  5. rf_binary_fc2.ipynb                  → train binary RF (with NDVI)

multi_class_classification/
  6. rf_multiclass_fc1.ipynb              → train multi-class RF (no NDVI)
  7. rf_multiclass_fc2.ipynb              → train multi-class RF (NDVI + Quercus downsampling)

prediction_validation/
  8. campus_prediction_validation.ipynb   → validate predictions on UT campus inventory

lcz_analysis/
  9. lcz_species_analysis.ipynb           → analyse species distribution across LCZ classes
```

---

### YOLO object detection pipeline

```
notebooks/yolo_detection/

preprocessing/
  1. yolo_detection_gt_prep.ipynb              → prepare ground-truth shapefiles
  2. yolo_detection_rgb_tiles_prep.ipynb       → generate RGB patches + bbox labels
  3. yolo_detection_irrg_tiles_prep.ipynb      → generate IRRG patches + bbox labels

rgb/
  4. YOLOv11s_rgb.ipynb                        → train, validate, test RGB model

irrg/
  5. YOLOv11s_irrg.ipynb                       → train, validate, test IRRG model
```

---

### YOLO instance segmentation pipeline

```
notebooks/yolo_segmentation/

preprocessing/
  1. yolo_segmentation_gt_prep.ipynb           → prepare ground-truth shapefiles
  2. yolo_segmentation_rgb_tiles_prep.ipynb    → generate RGB patches + mask labels
  3. yolo_segmentation_irrg_tiles_prep.ipynb   → generate IRRG patches + mask labels

rgb/
  4. YOLOv11s-seg_rgb.ipynb                    → train, validate, test, export GeoJSON

irrg/
  5. YOLOv11s-seg_irrg.ipynb                   → train, validate, test, export GeoJSON
```

---

### Visualisation

```
notebooks/yolo_visualisation.ipynb    → inspect any YOLO dataset (detection or segmentation,
                                        RGB or IRRG) — set SPLITS_DIR, TASK, CLASS_NAMES
```

---

## Model Weights

Trained model weights are archived at the University of Twente data repository:

```
\\ad.utwente.nl\itc\Archive\CourseData\Upload\Herl_s3482170\models\
```

| Model | Task | Config | File |
|---|---|---|---|
| YOLOv11s | Object detection | RGB | `yolov11_detection/rgb/weights/best.pt` |
| YOLOv11s | Object detection | IRRG | `yolov11_detection/irrg/weights/best.pt` |
| YOLOv11s-seg | Instance segmentation | RGB | `yolov11_segmentation/rgb/weights/best.pt` |
| YOLOv11s-seg | Instance segmentation | IRRG | `yolov11_segmentation/irrg/weights/best.pt` |
| Random Forest | Binary classification | FC1 | `random_forest/RF_BinaryClassifier_FeatureConfigI_v01.pkl` |
| Random Forest | Binary classification | FC2 | `random_forest/RF_BinaryClassifier_FeatureConfigII_v01.pkl` |
| Random Forest | Multi-class classification | FC1 | `random_forest/RF_MulticlassClassifier_FeatureConfigI_v01.pkl` |
| Random Forest | Multi-class classification | FC2 | `random_forest/RF_MulticlassClassifier_FeatureConfigII_v01.pkl` |

**Load YOLO model:**
```python
from ultralytics import YOLO
model = YOLO('path/to/best.pt')
```

**Load RF model:**
```python
import pickle
model = pickle.load(open('path/to/model.pkl', 'rb'))
```

---

## Key Results

| Method | Configuration | Overall Accuracy |
|---|---|---|
| YOLOv11s detection | RGB | Limited — high background misclassification |
| YOLOv11s detection | IRRG | Limited — increased missed detections |
| YOLOv11s-seg segmentation | RGB | ~40% crown recall |
| YOLOv11s-seg segmentation | IRRG | ~42% crown recall |
| Random Forest binary | FC1 | 76.1% (test) |
| Random Forest binary | FC2 | 75.5% (test) |
| Random Forest multi-class | FC1 | 76.6% — biased toward Quercus |
| Random Forest multi-class | FC2 | 61.6% — balanced after downsampling |
| Campus validation (FC2) | — | ~63% of matched crowns correct |

The two-step LiDAR + Random Forest workflow substantially outperformed the one-step YOLO detection approach for species-level classification in heterogeneous urban environments.

---

## Citation

If you use this code or workflow, please cite the associated thesis:

```
Herl, K.O. (2026). Artificial Intelligence for Allergenic Tree Species Mapping
in Urban Environments: A Case Study of Enschede. MSc thesis, Faculty of
Geo-Information Science and Earth Observation (ITC), University of Twente.
```

---

## License

This repository is licensed under the [MIT License](LICENSE).
The license applies to the source code and notebooks only. Data files and
trained model weights are subject to separate terms as described in `README.txt`.

---

## Acknowledgements

Supervisors: Dr. Rosa Aguilar Bolivar and Dr. ir. Ellen-Wien Augustijn (ITC, University of Twente).

This research is associated with the [KAPPA research initiative](https://www.utwente.nl/en/itc/about-itc/centres-of-expertise/big-geodata/stories/story/making-allergy-burden-manageable-from-pollen-to-patient/) at ITC, University of Twente, which aims to model the spatial distribution of pollen allergies in the Netherlands.
