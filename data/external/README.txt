External Datasets
=================

This folder contained third-party datasets used during the research.
The sub-folder structure is as follows:

  external/
    crown_polygons_gt/     Reference crown polygon boundaries (4TU.HERITAGE project)
    lcz_raster/            Local Climate Zone classification raster for Enschede
    municipal_gt/          Municipal tree inventory (Municipality of Enschede)
    ut_campus_gt/          Campus tree inventory (University of Twente)


DATASETS NOT INCLUDED IN THIS ARCHIVE
--------------------------------------

The following datasets are not redistributed due to access restrictions.
The expected files should be placed in the corresponding sub-folders listed
above when reproducing this research.

  crown_polygons_gt/
    Reference crown boundaries used for YOLO object detection and instance
    segmentation dataset preparation. Provided within the 4TU.HERITAGE research
    project — a collaborative initiative involving the University of Twente
    focused on urban heat stress monitoring and climate adaptation in Dutch cities.

  municipal_gt/
    Municipal tree inventory provided by the Municipality of Enschede, maintained
    through Cobra Groeninzicht, and made available via the 4TU.HERITAGE project.
    Used as the primary ground-truth dataset for species labelling, Random Forest
    training and evaluation, and YOLO dataset preparation.

  ut_campus_gt/
    Campus tree inventory provided by the University of Twente, composed and
    maintained by the vegetation maintenance staff. Used exclusively as an
    independent validation dataset to assess Random Forest predictions for
    private trees on the university campus.

Access restrictions apply to all three datasets listed above. See the main
README for details regarding ownership, licensing conditions, and access
procedures.


DATASETS INCLUDED IN THIS ARCHIVE
-----------------------------------

  lcz_raster/
    Local Climate Zone (LCZ) classification raster for Enschede.
    Used for analysing model performance and species distribution across
    different urban morphological settings.
    Source: https://zenodo.org/records/8419340
