clear all; clc; close;

%% Matlab scipt to read the data from csv files and convert it into a struct .mat file named 'Data_ID'
% input the ID of interest here:


ID = 17;
ID = num2str(ID);
ID_folder = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data_ID_';
ID_folder =  [ID_folder ID '\'];
myfiles = dir(ID_folder);
filenames={myfiles(:).name}';

for i = 1:numel(filenames)
    folder_in = strcat(ID_folder,filenames(i));
    d=dir(fullfile(folder_in{1},'*.csv*'));                        % return the .csv files in the given folder
    var_name = [];

    for i=1:numel(d)

      % stores all experiment data in a structure with the name of the table as
      % the experimental condition, trial, ID, data type.
      file_name = d(i).name;
      var_name = string([file_name(1:end-4)]);
      var_name = strcat('ID_', var_name);
      data = readtable(fullfile(folder_in{1},d(i).name)); 
      experiment_data.(var_name) = data;
      % do whatever w/ the i-th file here before going on to the next...
    end    
end

save(['Data_' ID])


