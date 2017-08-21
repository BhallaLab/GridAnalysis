clear all
clc

%% To set the default directories

importDir = uigetdir()
exportDir = importDir;

%% read from the import directory and process
cd(importDir)
allFiles = dir('E*.atf');


for i=1:length(allFiles)
    %Fetch the file
    TraceFile = allFiles(i).name
    ExptID = strsplit(TraceFile,'.');
    ExptID = ExptID{1};
    
    data = dlmread(TraceFile,'\t',11,0);
    %Load the file
    %To check the size of the the variable 'data' inside each file
    %For consistency every file has a single variable called 'data'
    RecSize = size(data);
    
    % Generate a single trace for Ch#1 and Ch#2
    PatchTrace = [];
    PolygonTrace = [];

    for k=2:RecSize(2)
        if mod(k,2)==0
            PatchTrace = [PatchTrace;data(:,k)];
        else
            PolygonTrace = [PolygonTrace;data(:,k)];
        end
    end
    
    exportFileName = strcat(exportDir,'\',ExptID);
    clear k
    clear PathName
    clear TraceFile
    clear RecSize
    clear data     
    
    save(exportFileName, 'P*Trace')
    
    i
    
    clear exportFileName
end