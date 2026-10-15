"""Emission statistics read from the exported melt-pool monitoring maps.

Reads ../data/07_melt_pool_monitoring/exported_maps/Reused{r}-channel{c}.png for reuse cycles 0, 1, 7 and 8
and both photodiode channels, converts the colour of every scan-track pixel back to an emission value through
the 0 to 2500 jet colour scale printed under each map, and writes ../data/derived/mpm_emission_stats.csv.

Pixels of the colour bar, the frame and long straight single-colour runs (part outlines) are excluded, and a
pixel is rejected when its colour is farther than 25 (RGB units) from the nearest colour of the scale.
The values therefore represent the exported display, with a colour resolution of about 40 units, and not the
raw photodiode signal.

Requirements: numpy, pillow.
"""
import csv
import os

import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MAPS = os.path.join(ROOT, 'data', '07_melt_pool_monitoring', 'exported_maps')
OUT = os.path.join(ROOT, 'data', 'derived', 'mpm_emission_stats.csv')
VMIN, VMAX = 0.0, 2500.0
CYCLES = (0, 1, 7, 8)


def long_runs(img, axis, minlen=150):
    """Mark pixels that belong to straight runs of near-constant saturated colour (outlines)."""
    img = img if axis == 1 else img.transpose(1, 0, 2)
    H, W, _ = img.shape
    mark = np.zeros((H, W), bool)
    for r in range(H):
        row = img[r]
        start = 0
        for c in range(1, W + 1):
            same = c < W and np.abs(row[c] - row[c - 1]).sum() < 30 and (row[c].max() - row[c].min()) > 60
            if not same:
                if c - start >= minlen:
                    mark[r, start:c] = True
                start = c
    return mark if axis == 1 else mark.T


def jet_lut(n=2048):
    t = np.linspace(0, 1, n)
    lut = 255 * np.stack([np.clip(1.5 - np.abs(4 * t - 3), 0, 1),
                          np.clip(1.5 - np.abs(4 * t - 2), 0, 1),
                          np.clip(1.5 - np.abs(4 * t - 1), 0, 1)], 1)
    return lut, VMIN + t * (VMAX - VMIN)


def main():
    lut, vals = jet_lut()
    rows = []
    for reuse in CYCLES:
        for ch in (1, 2):
            im = np.asarray(Image.open(os.path.join(MAPS, f'Reused{reuse}-channel{ch}.png')).convert('RGB'), dtype=float)
            H, W, _ = im.shape
            chroma = im.max(2) - im.min(2)
            # colour bar: lowest band of rows whose left end is blue and right end is red
            cand = []
            for r in range(H):
                cols = np.where(chroma[r] > 60)[0]
                if len(cols) > 0.9 * W:
                    left, right = im[r, cols.min() + 3], im[r, cols.max() - 3]
                    if left[2] > left[0] + 60 and right[0] > right[2] + 60:
                        cand.append(r)
            top = min(r for r in cand if r > H * 0.6)
            region = im[8:top - 8, 8:W - 8]
            outline = long_runs(region, 1) | long_runs(region, 0)
            sel = ((region.max(2) - region.min(2)) > 60) & ~outline
            px = region[sel]
            d2 = ((px[:, None, :] - lut[None, :, :]) ** 2).sum(2)
            j = d2.argmin(1)
            dist = np.sqrt(d2[np.arange(len(j)), j])
            ok = dist < 25
            v = vals[j[ok]]
            p = np.percentile(v, [5, 25, 50, 75, 95])
            rows.append([reuse, ch, len(v), round(float(v.mean()), 1), round(float(v.std()), 1)]
                        + [round(float(x), 1) for x in p] + [int(outline.sum()), round(100 * float((~ok).mean()), 2)])
            print(f'reuse {reuse} channel {ch}: n = {len(v)}  mean = {v.mean():.0f}  median = {p[2]:.0f}  '
                  f'IQR = {p[1]:.0f} to {p[3]:.0f}  rejected = {100 * (~ok).mean():.1f}%')
    with open(OUT, 'w', newline='', encoding='utf-8') as fh:
        w = csv.writer(fh)
        w.writerow(['reuse_cycle', 'channel', 'n_pixels', 'mean', 'sd', 'p05', 'p25', 'p50', 'p75', 'p95',
                    'outline_pixels_removed', 'pct_pixels_rejected'])
        w.writerows(rows)


if __name__ == '__main__':
    main()
