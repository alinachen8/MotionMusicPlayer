import numpy as np
import scipy.stats as stats
from scipy.signal import welch

# Feature extraction functions
# Final function, extract_features takes in a dataframe and sampling frequency (100)

def mean(signal):
    return np.mean(signal)

def std(signal):
    return np.std(signal)

def energy(signal):
    return np.sum(np.square(signal)) / len(signal)

def max_val(signal):
    return np.max(signal)

def min_val(signal):
    return np.min(signal)

def min_max_range(signal):
    return np.max(signal) - np.min(signal)

def median_above_mean(signal):
    mean_val = np.mean(signal)
    above_mean = signal[signal > mean_val]
    if len(above_mean) > 0:
        return np.median(above_mean)
    else:
        return 0
    
def interquartile_range(signal):
    return np.percentile(signal, 75) - np.percentile(signal, 25)

def skewness(signal):
    return stats.skew(signal)

def psd_features(signal, fs):  # fs: sampling frequency
    freqs, psd = welch(signal, fs=fs, nperseg=min(len(signal), 256))
    mean_psd = np.mean(psd)
    std_psd = np.std(psd)
    max_psd = np.max(psd)
    min_psd = np.min(psd)
    median_psd = np.median(psd)
    
    # Normalize for entropy calculation
    psd_norm = psd / np.sum(psd) if np.sum(psd) > 0 else np.ones_like(psd) / len(psd)
    entropy = -np.sum(psd_norm * np.log2(psd_norm + 1e-12))  # avoid log(0)
    
    return {
        'mean_psd': mean_psd,
        'std_psd': std_psd,
        'max_psd': max_psd,
        'min_psd': min_psd,
        'median_psd': median_psd,
        'entropy_psd': entropy
    }

def extract_features_column(signal, column_name, fs):
    features = {}
    features[column_name + '_mean'] = mean(signal)
    features[column_name + '_std'] = std(signal)
    features[column_name + '_energy'] = energy(signal)
    features[column_name + '_max_val'] = max_val(signal)
    features[column_name + '_min_val'] = min_val(signal)
    features[column_name + '_min_max_range'] = min_max_range(signal)
    features[column_name + '_median_above_mean'] = median_above_mean(signal)
    features[column_name + '_iqr'] = interquartile_range(signal)
    features[column_name + '_skewness'] = skewness(signal)

    signal_psd_features = psd_features(signal, fs)
    for key, value in signal_psd_features.items():
        features[column_name + '_' + key] = value
    
    return features

def extract_features(df, fs):
    combined_features = {}
    for column_name in df.columns:
        column_data = df[column_name].to_numpy()
        column_features = extract_features_column(column_data, column_name, fs)
        combined_features.update(column_features)
    return combined_features