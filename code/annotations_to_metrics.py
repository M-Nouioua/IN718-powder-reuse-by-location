"""Per-particle size and shape descriptors from the PowderAnnotator contour annotations.

Reads the four annotated SEM fields in ../data/02_sem_particle_annotations and writes
../data/derived/morphology_particles.csv (one row per particle) and
../data/derived/morphology_summary.csv (one row per field).

Descriptors (two-dimensional, from the annotated contour in pixels):
    equivalent diameter  d_eq = 2 sqrt(A / pi) * scale
    circularity          C = 4 pi A / P^2            (1 for a circle)
    elongation           E = a_max / a_min            (fitted ellipse axes)
    convexity            S = A / A_hull               (1 for a convex outline)
The pixel scale of each field is listed in FIELDS (micrometres per pixel, from the SEM scale bar).

Requirements: numpy, opencv-python.
"""
import csv
import json
import math
import os

import cv2
import numpy as np

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ANN = os.path.join(ROOT, 'data', '02_sem_particle_annotations')
OUT = os.path.join(ROOT, 'data', 'derived')

# condition label, annotation file, scale (um per pixel)
FIELDS = [
    ('Virgin', 'Virgin_X150_annotations.json', 0.675933),
    ('Zone 1, reuse 0', 'Zone1_Reuse0_X150_annotations.json', 0.666248),
    ('Zone 4, reuse 5', 'Zone4_Reuse5_X150_annotations.json', 0.666651),
    ('Zone 4, reuse 6', 'Zone4_Reuse6_X150_annotations.json', 100.0 / 150.0),
]


def metrics(contour, scale):
    c = np.array(contour, dtype=np.int32).reshape(-1, 1, 2)
    area = float(cv2.contourArea(c))
    perim = float(cv2.arcLength(c, True))
    circ = min(4 * math.pi * area / (perim * perim), 1.0) if perim > 0 else 0.0
    hull = float(cv2.contourArea(cv2.convexHull(c)))
    conv = min(area / hull, 1.0) if hull > 0 else 0.0
    if len(c) >= 5:
        (_, _), (d1, d2), _ = cv2.fitEllipse(c)
        elong = max(d1, d2) / max(1e-3, min(d1, d2))
    else:
        x, y, w, h = cv2.boundingRect(c)
        elong = max(w, h) / max(1, min(w, h))
    return 2 * math.sqrt(area / math.pi) * scale, circ, elong, conv


def main():
    os.makedirs(OUT, exist_ok=True)
    rows = []
    for name, fname, scale in FIELDS:
        with open(os.path.join(ANN, fname), encoding='utf-8') as fh:
            data = json.load(fh)
        for a in data['annotations']:
            deq, circ, elong, conv = metrics(a['contour'], scale)
            rows.append((name, a['label'], deq, circ, elong, conv))
    with open(os.path.join(OUT, 'morphology_particles.csv'), 'w', newline='', encoding='utf-8') as fh:
        w = csv.writer(fh)
        w.writerow(['condition', 'class', 'eq_diameter_um', 'circularity', 'elongation', 'convexity'])
        for r in rows:
            w.writerow([r[0], r[1], f'{r[2]:.4f}', f'{r[3]:.5f}', f'{r[4]:.5f}', f'{r[5]:.5f}'])
    summary = []
    for name, _, _ in FIELDS:
        r = [x for x in rows if x[0] == name]
        deq = np.array([x[2] for x in r])
        circ = np.array([x[3] for x in r])
        elong = np.array([x[4] for x in r])
        conv = np.array([x[5] for x in r])
        labels = [x[1] for x in r]
        n = len(r)
        spherical = 100 * sum(l == 'Spherical particle' for l in labels) / n
        q = np.percentile(deq, [10, 50, 90])
        summary.append((name, n, q[0], q[1], q[2], (q[2] - q[0]) / q[1], np.median(circ),
                        100 * np.mean(circ < 0.8), np.median(elong), np.median(conv), spherical))
        print(f'{name:16s} n={n:3d}  D10/D50/D90 = {q[0]:.1f}/{q[1]:.1f}/{q[2]:.1f} um  span = {(q[2] - q[0]) / q[1]:.2f}  '
              f'C_med = {np.median(circ):.3f}  C<0.8 = {100 * np.mean(circ < 0.8):.1f}%  E_med = {np.median(elong):.3f}  '
              f'spherical = {spherical:.1f}%')
    with open(os.path.join(OUT, 'morphology_summary.csv'), 'w', newline='', encoding='utf-8') as fh:
        w = csv.writer(fh)
        w.writerow(['condition', 'n', 'D10_um', 'D50_um', 'D90_um', 'span', 'circularity_median',
                    'pct_circularity_below_0.8', 'elongation_median', 'convexity_median', 'spherical_pct'])
        for s in summary:
            w.writerow([s[0], s[1]] + [f'{v:.3f}' for v in s[2:]])


if __name__ == '__main__':
    main()
