# GridAnalysis
This repository has scripts for analyzing optogenetic grid stimulation to pyramidal cells.

The nature of data
The data is recorded from continuous acquisition @20kHz from a Patch Clamped neuron which is also receiveing
direct or indirect optical stimulation. There are two channels in the data.
Ch#1 : Trace of the electrical activity of the neuron
Ch#2 : Records the TTL signals from the optical stimulation onset

The native format of recording in Axon Patch Clamp amplifiers (Molecular Devices) is "Axon Binary Format" (*.abf)
This is currently not readable using the codes given in this repository. That is for a future release.
Using a program called Clampfit (Molecular Devices), the abf files are exported as tab-separated text files
called "Axon Text Format" (*.atf).

The entire recording data is broken into 60000 data point cloumns which are arranged against the first column of time.
Therefore, to produce a continuous trace, all the columns need to be concatenated. There is an 11 row header in each
file which is not required.

File: "atf_to_mat_parser"
The script takes atf files stored in the user selected folder and extracts the data out in the same folder by:
   Removing the header and the first column
   Taking columns of each channel and concatenating them to produce a single continuous trace
   Thereby creating two traces, one for each channel
   Saving these two traces as two variables in a matlab file (*.mat) with the same experiment ID as the imported file
   
Grid Analysis
There are two kinds of analysis done here:
  Peak response of the patched cell corresponding to the given optical stimulus
  Area under the curve of the response of the patched cell to the given stimulus
Plotting it as a heatmap to the coordinates of the optical stimulus given.
