#
# Filename: process_acceleration.py
# Acceleration processing code for e-scooter project
#
# Flags - 
#
# Code Purpose:
# This code takes in a csv file generated from the accelerometer data
# of the form YYYYMMDD_HHMMSS_Acc.csv and then generates a corresponding
# YYYYMMDD_HHMMSS_Acc_processed.csv that then has a single vector with
# the timestamps of a processed roughness index that corresponds to the
# processed accelerometer data that can then be used for further
# evaluation of the pavement condition.
#
# Code History:
#
# Version: 0.01
# Date: June 20, 2022
# Author: Brian Mazzeo, bmazzeo@byu.edu
#

import argparse
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
from scipy.fft import fftshift

# First we want to parse the arguments to the python script to extract the filename
parser = argparse.ArgumentParser(description = 'Process e-scooter accelerometer data.')
parser.add_argument("filename", help = 'filename')
args = parser.parse_args()
print('Processing file:', args.filename)

# Process the CSV file using the correct delimiters and remove the header
#data = np.genfromtxt('20211106_103329_Acc.csv', delimiter=';', skip_header = 3, usecols = (0, 1, 2, 3))
data = np.genfromtxt(args.filename, delimiter=';', skip_header = 3, usecols = (0, 1, 2, 3))
#print(data)

# Parse the array into the necessary vectors
times = data[:,0]
x_acc = data[:,1]
y_acc = data[:,2]
z_acc = data[:,3]

avg_time_diff = (times[100] - times[0]) / 100
print('Average time difference (100 samples) in ns:', avg_time_diff)

fs = 1 / (avg_time_diff * 10**-9)
print('Estimated sampling frequency (Hz):', fs)

# Process the means of the accelerations
x_mean = np.mean(x_acc)
y_mean = np.mean(y_acc)
z_mean = np.mean(z_acc)
print('Means (x, y, z):', x_mean, y_mean, z_mean)

x_dev = x_acc - x_mean
y_dev = y_acc - y_mean
z_dev = z_acc - z_mean

# Calculate a total deviation
total_dev = np.sqrt(x_dev**2 + y_dev**2 + z_dev**2)

b, a = signal.butter(5, 0.001)
filtered_total_dev = signal.filtfilt(b, a, total_dev, padlen = 500);


# Plot time data for all three accelerations
fig1, (ax1, ax2, ax3, ax4, ax5) = plt.subplots(5,1)
ax1.plot(times, x_acc)
ax1.set_ylabel('X Acc')
ax2.plot(times, y_acc)
ax2.set_ylabel('Y Acc')
ax3.plot(times, z_acc)
ax3.set_ylabel('Z Acc')
ax4.plot(times, total_dev)
ax4.set_ylabel('Deviation Sum')
ax5.plot(times, filtered_total_dev)
ax5.set_ylabel('Filter Metric')

#plt.ion()
plt.draw()


# Now plot spectrograms of all 3
fig2, (ax1, ax2, ax3) = plt.subplots(3,1)
f, t, Sxx = signal.spectrogram(x_acc, fs)
ax1.pcolormesh(t, f, Sxx, shading='gouraud')
ax1.set_ylabel('Frequency [Hz]')
ax1.set_xlabel('Time [sec]')

f, t, Sxx = signal.spectrogram(y_acc, fs)
ax2.pcolormesh(t, f, Sxx, shading='gouraud')
ax2.set_ylabel('Frequency [Hz]')
ax2.set_xlabel('Time [sec]')

f, t, Sxx = signal.spectrogram(z_acc, fs)
ax3.pcolormesh(t, f, Sxx, shading='gouraud')
ax3.set_ylabel('Frequency [Hz]')
ax3.set_xlabel('Time [sec]')
plt.draw()



plt.show()
exit()

import numpy as np
from scipy import signal
from scipy.fft import fftshift
import matplotlib.pyplot as plt





f, t, Sxx = signal.spectrogram(x, fs)
plt.pcolormesh(t, f, Sxx, shading='gouraud')
plt.ylabel('Frequency [Hz]')
plt.xlabel('Time [sec]')
plt.show()