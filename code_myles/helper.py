import numpy as np
import scipy.stats as stats
from scipy.signal import welch

def std(signal):
    return np.std(signal)

def energy(signal):
    return np.sum(np.square(signal)) / len(signal)

def max_val(signal):
    return np.max(signal)

def mean(signal):
    return np.mean(signal)

def min_max_range(signal):
    return np.max(signal) - np.min(signal)


def min_val(signal):
    return np.min(signal)

def median_above_mean(signal):
    mean_val = np.mean(signal)
    above_mean = signal[signal > mean_val]
    return np.median(above_mean) if len(above_mean) > 0 else 0

def interquartile_range(signal):
    return np.percentile(signal, 75) - np.percentile(signal, 25)

def skewness(signal):
    return stats.skew(signal)

def psd_features(signal, fs=20.0):  # fs: sampling frequency
    freqs, psd = welch(signal, fs=fs, nperseg=min(len(signal), 256))
    mean_psd = np.mean(psd)
    std_psd = np.std(psd)
    max_psd = np.max(psd)
    median_psd = np.median(psd)
    # Normalize for entropy calculation
    psd_norm = psd / np.sum(psd) if np.sum(psd) > 0 else np.ones_like(psd) / len(psd)
    entropy = -np.sum(psd_norm * np.log2(psd_norm + 1e-12))  # avoid log(0)
    return {
        "meanPSD": mean_psd,
        "stdPSD": std_psd,
        "maxPSD": max_psd,
        "minPSD": np.min(psd),
        "medianPSD": median_psd,
        "entroS": entropy
    }
