clc
clear all


%% Load the file

[FileName,PathName]=uigetfile;
TraceFile = strcat(PathName,FileName);
cd(PathName)
load(FileName)
ExptID = strsplit(FileName,'.');
ExptID = ExptID(1);

ExptID = ExptID{1};

gridSize = input('How large is the Grid?');
acqRate = 20; % 20 datapoints per ms

%% To import the external grid coordinates

%Get the Coordinates file using GUI window
[coordFileName, coordFilePathName]=uigetfile;

%Open and scan it for the fourth column as the coordinates data is always
%in the fourth column. In textscan, %u = unsigned integer format, an
%asterisk in %*u means that that column is to be skipped

fid = fopen(coordFileName);
coord = textscan(fid,'%*u%*u%*u%u');
fclose(fid);
coord = coord{1};

%% Create Traces and Separate out Triggered Responses

% All data files are parsed and therefore have two variables
% 1)PatchTrace
% 2)PolygonTrace

%Create TimeTrace
TimeTrace = linspace(0,length(PatchTrace)/(1000*acqRate),length(PatchTrace));

%Find out the maximum value of polygon TTL received to use that
% to find locations of the peaks
maxPolygon = max(PolygonTrace);

% Locations of the TTLs in channel 2 i.e. Polygon
[peaks locs] = findpeaks(PolygonTrace,'MinPeakHeight',0.90*maxPolygon,'MinPeakDistance',18000,'Npeaks',gridSize^2);

% Set the time in ms around the stim onset for plotting 
pre = 25; 
post = 75;
points = acqRate*(pre+post)+1; %Number of datapoints

% Create a matrix in which each row corresponds to a section of 
% patch trace around the stimulus
PatchTracelets=zeros(length(locs),points);

%Fill in the matrix using locations of TTL peaks
for i=1:length(locs)
    PatchTracelets(i,:)=PatchTrace((locs(i)-pre*acqRate):(locs(i)+post*acqRate));
    %baseline subtraction
    % A mean value is calculated between datapoints 100 and 400
    % this mean is then subtracted from the entire traceline
    % thus shifting the trace to zero.
    baseline = mean(PatchTracelets(i,100:400));
    PatchTracelets(i,:) = PatchTracelets(i,:)-baseline;
end


%%  Create a matrix denoting the peak response of the cell in each row
%   corresponding to the EPSP peak or spike

gridPeak=zeros(gridSize);

for i=1:length(locs)
    % The remapping of squares is done here using a variable 'j' which maps
    % the index i onto the correct coordinate of the square from the coord
    % data
    j = coord(i);
    gridPeak(j)=max(PatchTracelets(i,:));
    if gridPeak(j) > 30
        gridPeak(j)=30;
    end
end
gridPeak = gridPeak';
 
%%  Create a matrix denoting the peak response of the cell in each row
%   corresponding to the EPSP peak or spike

gridAuc=zeros(gridSize);
aucTime = post; % Time till which AUC is calculated
aucDuration = [pre*acqRate:pre*acqRate+aucTime*acqRate];

for i=1:length(locs)
    j=coord(i);
    gridAuc(j)=trapz(PatchTracelets(i,aucDuration));
end
gridAuc = gridAuc';

%% Generate and save the peak figure

figure
gridPeakMap = imagesc(gridPeak);
colormap('default')
h = colorbar()
title('Peak Response from baseline(Spikes clipped at 30)')
PeakImageFile = strcat(ExptID,'_gridPeakMap_',num2str(gridSize),'x');
print(PeakImageFile,'-dpng')

%% Generate and save AUC figure

figure
gridAucMap = imagesc(gridAuc);
colormap('default')
h = colorbar()
title('Area Under the Curve for Responses')
AucImageFile = strcat(ExptID,'_gridAucMap_',num2str(gridSize),'x');
print(AucImageFile,'-dpng')

%% Clear all junk variables
clear i
clear maxPolygon
clear pre
clear post
clear points
clear acqRate
clear baseline


%% Save data file
mkdir(ExptID)
AnalysedFilePath = strcat(PathName,ExptID,'\');
AnalysedFile = strcat(AnalysedFilePath,ExptID,'_Ordered_Grid_',num2str(gridSize),'.mat');
save(AnalysedFile)

