"""Gamma-Ni peak positions and displacement-corrected lattice parameter from the raw XRD scans.

Reads ../data/05_xrd/raw/job_N.csv (two header lines; columns 2theta in degrees, intensity) and writes
../data/derived/xrd_gamma_peaks.csv   fitted (111), (200) and (220) positions, FWHM and integrated area
../data/derived/xrd_displacement_fit.csv   lattice parameter a and specimen displacement s that
                                           reproduce the three positions, with the rms residual

Each reflection is fitted with a pseudo-Voigt profile on a linear background within +/- 0.8 degrees of the
peak maximum. The specimen-displacement model is
    2theta_obs = 2theta(a, hkl) - (2 s cos(theta) / R) * 180 / pi
with the goniometer radius R = 150 mm and the Cu K-alpha weighted wavelength.

Requirements: numpy, scipy.
"""
import csv
import os

import numpy as np
from scipy.optimize import curve_fit, least_squares

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
XDIR = os.path.join(ROOT, 'data', '05_xrd', 'raw')
OUT = os.path.join(ROOT, 'data', 'derived')

LAM = (2 * 1.540593 + 1.544414) / 3   # Cu K-alpha, intensity-weighted (angstrom)
R = 150.0                              # goniometer radius (mm)
HKL = [(1, 1, 1), (2, 0, 0), (2, 2, 0)]
GUESS = [43.2, 50.4, 74.2]             # approximate 2theta of the three reflections (degrees)
JOBS = (6, 7, 8, 10, 11, 12, 13, 14, 15)


def pseudo_voigt(x, A, x0, w, eta, b0, b1):
    L = 1 / (1 + ((x - x0) / (w / 2)) ** 2)
    G = np.exp(-np.log(2) * ((x - x0) / (w / 2)) ** 2)
    return A * (eta * L + (1 - eta) * G) + b0 + b1 * (x - x0)


def fit_peak(tt, I, centre, half=0.8):
    m = (tt > centre - half) & (tt < centre + half)
    x, y = tt[m], I[m]
    i = np.argmax(y)
    p, _ = curve_fit(pseudo_voigt, x, y, p0=[y[i] - np.median(y), x[i], 0.3, 0.5, np.median(y), 0],
                     bounds=([0, centre - half, 0.05, 0, -np.inf, -np.inf],
                             [np.inf, centre + half, 2.0, 1, np.inf, np.inf]), maxfev=20000)
    area = p[0] * p[2] * (p[3] * np.pi / 2 + (1 - p[3]) * np.sqrt(np.pi / np.log(2)) / 2)
    return p[1], p[2], area


def two_theta(a, hkl):
    return 2 * np.degrees(np.arcsin(LAM * np.sqrt(sum(v * v for v in hkl)) / (2 * a)))


def model(p, hkls):
    a, s = p
    return np.array([two_theta(a, h) - np.degrees(2 * s * np.cos(np.radians(two_theta(a, h) / 2)) / R) for h in hkls])


def main():
    os.makedirs(OUT, exist_ok=True)
    peaks, fits = [], []
    for j in JOBS:
        name = f'job {j}'
        d = np.loadtxt(os.path.join(XDIR, f'job_{j}.csv'), delimiter=',', skiprows=2, usecols=(0, 1))
        tt, I = d[:, 0], d[:, 1]
        obs = []
        for h, c in zip(HKL, GUESS):
            m = (tt > c - 2.2) & (tt < c + 1.2)
            c0 = tt[m][np.argmax(I[m])]
            x0, w, area = fit_peak(tt, I, c0)
            obs.append(x0)
            peaks.append([name, ''.join(map(str, h)), round(x0, 3), round(w, 3), round(area, 1)])
        r = least_squares(lambda p: model(p, HKL) - np.array(obs), [3.6, 0.5])
        fits.append([name, round(r.x[0], 4), round(r.x[1], 2), round(float(np.sqrt(np.mean(r.fun ** 2))), 3)])
        print(fits[-1])
    with open(os.path.join(OUT, 'xrd_gamma_peaks.csv'), 'w', newline='') as fh:
        w = csv.writer(fh)
        w.writerow(['scan', 'hkl', 'two_theta_deg', 'fwhm_deg', 'integrated_area'])
        w.writerows(peaks)
    with open(os.path.join(OUT, 'xrd_displacement_fit.csv'), 'w', newline='') as fh:
        w = csv.writer(fh)
        w.writerow(['scan', 'lattice_parameter_A', 'displacement_mm', 'rms_residual_deg'])
        w.writerows(fits)


if __name__ == '__main__':
    main()
