#
# Filename: process_folder_acc.py
# Acceleration processing code for e-scooter project
#
# Flags - 
#
# Code Purpose:
# This code takes in a csv file generated from the accelerometer data
# of the folder form YYYYMMDD_HHMMSS and then generates a corresponding
# YYYYMMDD_HHMMSS_Acc_processed.csv that then has a single vector with
# the timestamps of a processed roughness index that corresponds to the
# processed accelerometer data that can then be used for further
# evaluation of the pavement condition.
#
# Code History:
#
# Version: 0.02
# Date: August 1, 2022
# Author: Brian Mazzeo, bmazzeo@byu.edu
#

import argparse
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
from scipy.fft import fftshift
import csv

# First we want to parse the arguments to the python script to extract the filename
parser = argparse.ArgumentParser(description = 'Process e-scooter accelerometer data.')
parser.add_argument("folder", help = 'folder')
args = parser.parse_args()
print('Processing folder:', args.folder)

# Process the CSV file using the correct delimiters and remove the header
file_path = 'C:\\Users\\bmazzeo\\Documents\\GitHub\\escooter_pavements\\data\\pavement_data\\' + args.folder + '\\' + args.folder + '_Acc.csv'
data = np.genfromtxt(file_path, delimiter=';', skip_header = 3, usecols = (0, 1, 2, 3))
#print(data)

# Parse the array into the necessary vectors
times = data[:,0]
x_acc = data[:,1]
y_acc = data[:,2]
z_acc = data[:,3]

avg_time_diff = (times[len(times)-1] - times[0]) / (len(times) - 1)
print('Number of samples:', len(times))
print('Average time difference in ns:', avg_time_diff)

fs = 1 / (avg_time_diff * 10**-9)
print('Estimated sampling frequency (Hz):', fs)

# Process the means of the accelerations
x_mean = np.mean(x_acc)
y_mean = np.mean(y_acc)
z_mean = np.mean(z_acc)
print('Means (x, y, z):', x_mean, y_mean, z_mean)

x_std = np.std(x_acc, ddof=1)
y_std = np.std(y_acc, ddof=1)
z_std = np.std(z_acc, ddof=1)

print('StandardDeviation (x, y, z):', x_std, y_std, z_std)

x_dev = x_acc - x_mean
y_dev = y_acc - y_mean
z_dev = z_acc - z_mean

# Calculate a total deviation
total_dev = np.sqrt(x_dev**2 + y_dev**2 + z_dev**2)

# Only do the following signal processing if the signals are long enough
if (len(times) < 500):
    print('!!! Length of data shorter than 500 !!!')
    quit()

b, a = signal.butter(5, 0.001)
filtered_total_dev = signal.filtfilt(b, a, total_dev, padlen = 500);

# Write data to file
with open(args.folder + '_Acc_processed.csv', 'w', newline='') as f:
    writer = csv.writer(f, delimiter=';')
    writer.writerow(['TimestampAcc [ns]', 'Metric'])
    for index in range(len(times)):
        writer.writerow([times[index], filtered_total_dev[index]])

# Plotting available if this statement is removed
quit()


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
quit()

import numpy as np
from scipy import signal
from scipy.fft import fftshift
import matplotlib.pyplot as plt





f, t, Sxx = signal.spectrogram(x, fs)
plt.pcolormesh(t, f, Sxx, shading='gouraud')
plt.ylabel('Frequency [Hz]')
plt.xlabel('Time [sec]')
plt.show()