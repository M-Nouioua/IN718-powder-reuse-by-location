# Inconel 718 powder properties by collection location and reuse cycle in laser powder bed fusion

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23383351.svg)](https://doi.org/10.5281/zenodo.23383351)
[![License: CC BY 4.0](https://img.shields.io/badge/License-CC_BY_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

Measurement data, derived tables, analysis scripts and figures of the article

> I. Chekalil, V. Swaminathan, M. Nouioua, R. M. A. Khan, A. F. M. Arif,
> *Variation in Inconel 718 powder properties by collection location and reuse cycle in laser powder bed fusion*
> (Interdisciplinary Research Center for Intelligent Manufacturing and Robotics, King Fahd University of Petroleum and Minerals).

One 100 kg batch of gas-atomised Inconel 718 powder (nominal 15 to 45 µm) was followed through a 13-job
production campaign on an SLM Solutions SLM 280 system, from reuse cycle 0 to reuse cycle 8. After each job the
unfused powder was recovered and sieved in a PSM 100 station. Powder was sampled at five fixed locations:

| Zone | Location |
|------|----------|
| 1 | recoater side, upstream of the parts |
| 2 | chamber mid, between the parts and the downstream wall |
| 3 | chamber left, between the parts and the downstream wall |
| 4 | chamber extreme left, downstream edge of the bed along the shielding-gas flow |
| 5 | sieve reject collected at the PSM 100 |

The samples were examined by SEM with particle-by-particle classification, EDS, XRD and funnel flow tests.
Melt-pool monitoring maps and Vickers microhardness of parts from the same campaign are included.
The campaign followed a production schedule, so every zone and cycle combination was measured once; the data
are suitable for descriptive comparison, not for statistical testing.

## Repository layout

```
data/
  01_campaign/                    job table and photographs of the machine and the sampling locations
  02_sem_particle_annotations/    four SEM fields (x150) with contour annotations in six morphology classes
  03_sem_zone_micrographs/        SEM micrographs (x150, x1000) of Zones 1 to 5 at several reuse cycles
  04_eds/                         EDS element tables (12 spectra) and the campaign compilation sheet
  05_xrd/raw/                     Rigaku MiniFlex scans (.rasx, .csv), instrument reports and photographs
  06_flow/                        Hall, Carney and Gustavsson funnel flow record
  07_melt_pool_monitoring/        exported melt-pool monitoring maps (one layer, two channels, four jobs)
  08_hardness/                    Vickers microhardness of parts by reuse cycle
  derived/                        tables computed from the raw files by the scripts in code/
code/
  annotations_to_metrics.py       contour annotations -> per-particle descriptors and field summary
  xrd_peak_fit.py                 raw scans -> gamma-Ni peak positions and displacement-corrected lattice parameter
  mpm_maps_to_stats.py            exported monitoring maps -> emission statistics
  make_figures.m                  MATLAB script that produces every data figure in figures/
figures/                          data figures of the article (vector PDF and 900 dpi PNG)
```

## Data description

### 01_campaign

`jobs.csv`: one row per job. `job` is the consecutive numbering used in the article, `machine_log_job` the
number in the machine log (the log has no job 10), `reuse_cycle` the reuse count of the powder consumed,
`duration_h` the build duration in hours and `layers` the layer count. Empty cells were not recorded.
`sampling_locations_photo.png` shows the build chamber with the gas-flow direction and Zones 1 to 4 and the
collection of the sieve reject; `slm280_system_photo.jpg` shows the machine and its ancillary units.

### 02_sem_particle_annotations

Four secondary-electron fields at x150 (20 kV) in which every resolvable particle was outlined and assigned to one of
six classes with PowderAnnotator v1.0 (https://doi.org/10.5281/zenodo.20628158): spherical particle; agglomerated,
sintered or fused particles; particle with a satellite; deformed particle; elongated particle; fused particle.
In the reuse-6 field, agglomerated or sintered and fused particles were annotated as one combined class.

| File | Condition | Particles | Scale (µm per pixel) |
|------|-----------|-----------|----------------------|
| `Virgin_X150` | virgin powder as received | 494 | 0.675933 |
| `Zone1_Reuse0_X150` | recoater (Zone 1) after the first build with virgin powder | 385 | 0.666248 |
| `Zone4_Reuse5_X150` | chamber extreme left (Zone 4) at reuse 5 | 315 | 0.666651 |
| `Zone4_Reuse6_X150` | chamber extreme left (Zone 4) at reuse 6 | 414 | 0.666667 |

Each `*_annotations.json` file holds `info` (creation date, source image) and `annotations`, a list of objects with
`id`, `label` (class name), `click_point`, `contour` (list of [x, y] pixel coordinates), `bbox`
([x, y, width, height]), `area` (pixels) and `color`. The scale factors come from the SEM scale bars.
`morphology_class_examples.jpg` shows reference examples of the six classes.

### 03_sem_zone_micrographs

Secondary-electron micrographs of the powder sampled in each zone, named `Reuse{cycle}-X{magnification}`. Not every
zone was sampled at every cycle. `zones_reuse2_reuse8_montage_x1000.jpg` is the montage of the five zones at
reuse cycles 2 and 8 used in the article.

### 04_eds

`eds_spectra.csv`: the twelve EDS results (one area spectrum per zone and cycle, normalised to 100 wt% by the
instrument software) with the elements fitted in each spectrum. Empty cells mean that the element was not included
in the fit. `B_sigma_wt` is the uncertainty reported by the software for boron, `other_wt` the sum of Al, Si, P, S,
Ca, Ti, Mn, Co, Cu, Mg and Cl, and `remainder_wt` equals 100 minus (Ni + Cr + Fe + C).
`EDS_element_tables_by_zone_and_cycle.docx` contains the original element tables exported from the instrument.
`EDS_campaign_compilation_sheet.xlsx` is a compilation sheet kept during the campaign; its reuse labels differ in
places from the element tables, and it lists additional single spectra whose acquisition records could not be
located. The article uses the element tables.

Carbon contents of 15 to 40 wt% arise mainly from the carbon mounting tape and surface hydrocarbons. EDS is
surface-sensitive and semi-quantitative, especially for light elements, and the values should be used for relative
comparison only.

### 05_xrd

Rigaku MiniFlex scans (Cu K-alpha, 40 kV, 15 mA, HyPix-400 MF detector, no K-beta filter, 3 to 90 degrees 2theta,
step 0.01 degrees, 10 degrees per minute) of nine powder samples labelled with machine job numbers 6 to 15.
Machine jobs 6, 7 and 8 correspond to reuse cycles 1, 2 and 3 and machine jobs 11 to 14 to reuse cycles 5 to 8;
jobs 10 and 15 do not appear in the campaign log. The collection zone of the XRD samples was not recorded.
For each job: `job_N.rasx` (native instrument file), `job_N.csv` (two header lines, then 2theta in degrees and
intensity in counts), `job_N_report.pdf` (instrument phase-identification report) and `powder_job_NN.jpeg`
(photograph of the loaded holder). Sharp reflections at 36.8, 63.4, 76.5 and 80.7 degrees in jobs 10, 11 and 15
and a fixed reflection near 89.4 degrees originate from the aluminium sample holder.

### 06_flow

`flow_rate_measurement_record.xlsx`: Hall, Carney and Gustavsson funnel flow times recorded on four occasions
(reuse 1, labelled Job 6 on the sheet, and reuse 4, 5 and 8) for the zones available on each occasion. One
measurement per zone, funnel and occasion. The sample mass and the standard followed were not recorded.

### 07_melt_pool_monitoring

`exported_maps/Reused{cycle}-channel{1,2}.png`: one-layer melt-pool monitoring maps exported from the SLM 280
software for machine jobs 3, 6, 13 and 14 (reuse cycles 0, 1, 7 and 8), each with its 0 to 2500 colour scale.
The `j{job}c12.png` files are further exports of the same jobs as saved from the machine software and are not used
in the article. `cropped_maps/mpm_r{cycle}_ch{channel}.png` are the same maps without the colour bar, as placed
in the figure.

### 08_hardness

`microhardness.csv`: Vickers microhardness of parts built with one fixed parameter set (scan speed 200 mm/s,
hatch spacing 0.09 mm, constant laser power). Two parts (jobs 1 and 3) at reuse 0 and one part at each of reuse
1, 4, 7 and 8. The laser power, layer thickness, indentation load and number of indents were not recorded.

### derived

| File | Produced by | Content |
|------|-------------|---------|
| `morphology_particles.csv` | `annotations_to_metrics.py` | condition, class, equivalent diameter (µm), circularity, elongation, convexity of each annotated particle |
| `morphology_summary.csv` | `annotations_to_metrics.py` | per field: n, D10, D50, D90, span, median circularity, share below 0.8, median elongation, median convexity, spherical share |
| `xrd_gamma_peaks.csv` | `xrd_peak_fit.py` | pseudo-Voigt position, FWHM and area of the (111), (200) and (220) gamma-Ni reflections of each scan |
| `xrd_displacement_fit.csv` | `xrd_peak_fit.py` | lattice parameter and specimen displacement (R = 150 mm) fitted to the three positions, with rms residual |
| `mpm_emission_stats.csv` | `mpm_maps_to_stats.py` | per map: pixel count, mean, sd and 5th to 95th percentiles of the emission read through the colour scale |
| `flow_times.csv` | transcribed from the flow record | method, zone, occasion, flow time (s) |

Definitions: equivalent diameter 2 sqrt(A / pi); circularity 4 pi A / P^2; elongation = major / minor axis of the
fitted ellipse; convexity A / A_hull; span (D90 - D10) / D50. All descriptors are two-dimensional projections.

## Reproducing the tables and figures

```
cd code
python annotations_to_metrics.py     # needs numpy, opencv-python
python xrd_peak_fit.py               # needs numpy, scipy
python mpm_maps_to_stats.py          # needs numpy, pillow
matlab -batch make_figures           # MATLAB R2025a; writes figures/Fig*.pdf and figures/Fig*.png
```

The three Python scripts rewrite the files in `data/derived`; the versions in this repository were produced with
them. `make_figures.m` reads `data/derived`, `data/05_xrd/raw` and `data/07_melt_pool_monitoring/cropped_maps`
and regenerates Figures 2, 3, 6, 7, 8, 10, 11, 12, 13, 14, 15 and 16 of the article.

## How to cite

Chekalil, I., Swaminathan, V., Nouioua, M., Khan, R. M. A., Arif, A. F. M. (2026). Dataset: Variation in
Inconel 718 powder properties by collection location and reuse cycle in laser powder bed fusion (version 1.0.0).
Zenodo. https://doi.org/10.5281/zenodo.23383351

The particle classification tool is described in: Nouioua, M., Chekalil, I., Imran, Swaminathan, V., Khan, R. M.,
Arif, A. F. M. (2026). Quantitative SEM morphometry for monitoring laser powder-bed-fusion metal-powder feedstock.
Materials Today Communications 55, 115825. https://doi.org/10.1016/j.mtcomm.2026.115825

## Licence

All files in this repository are released under the Creative Commons Attribution 4.0 International licence
(CC BY 4.0); see `LICENSE`.

## Acknowledgements

X-ray diffraction and field-emission scanning electron microscopy were carried out at the Core Research
Facilities of King Fahd University of Petroleum and Minerals, Dhahran, Saudi Arabia.
