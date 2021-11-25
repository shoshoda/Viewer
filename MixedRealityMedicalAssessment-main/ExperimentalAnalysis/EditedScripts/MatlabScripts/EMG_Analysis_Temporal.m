clc; close all;
clear all;

%% Input the ID of data you want to analyse here. The .mat file will then be auto-loaded.
%%%%% The cursed pol timestamps are: 1, 4, 5
IDs = [6,7,8,9,10,11,12,13, 14, 15, 16, 17];
counter_fail = 0;
chk = exist('Nodes','var');
if ~chk
for ID = IDs
    ID = num2str(ID)
    
    ID_folder = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data\Data_MATLAB\UnprocessedData';
    ID_folder =  [ID_folder '\'];
    mat_data = ['Data_' ID];
    load([ID_folder mat_data])



%% first recordings

pol_missing_data = [];
names = fieldnames( experiment_data );
subStrSlow = '_slow';
slow_filteredStruct = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrSlow ) ) ) ) );
subStrMedium = '_medium';
medium_filteredStruct = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrMedium ) ) ) ) );
subStrFast = '_fast';
fast_filteredStruct = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrFast ) ) ) ) );

% %% second recordings

pol_missing_data_v2 = [];
% names = fieldnames( experiment_data );
subStrSlow_v2 = '_slowv2';
slow_filteredStruct_v2 = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrSlow_v2 ) ) ) ) );
subStrMedium_v2 = '_mediumv2';
medium_filteredStruct_v2 = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrMedium_v2 ) ) ) ) );
subStrFast_v2 = '_fastv2';
fast_filteredStruct_v2 = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrFast_v2 ) ) ) ) );

% 
% %% third recordings
% 
pol_missing_data_v3 = [];
% names = fieldnames( experiment_data );
subStrSlow_v3 = '_slowv3';
slow_filteredStruct_v3 = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrSlow_v3 ) ) ) ) );
subStrMedium_v3 = '_mediumv3';
medium_filteredStruct_v3 = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrMedium_v3 ) ) ) ) );
subStrFast_v3 = '_fastv3';
fast_filteredStruct_v3 = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStrFast_v3 ) ) ) ) );
% these need to be changed depending on participant


%% Calibration sequence to associate myo electrodes with muscles.

    names = fieldnames( experiment_data );
    subStr = ['ID_' ID '_test_EMG_data'];
    Calibration_filteredStruct = rmfield( experiment_data, names( find( cellfun( @isempty, strfind( names , subStr ) ) ) ) );
    % only started naming the data with calib part way through experiments
    % so have to manually find some of the calibration data
    if str2num(ID) == 1
        EMG_data = ['ID_1_test_EMG_data_medium'];
        EMG_calibration_data = experiment_data.(EMG_data);
        EMG_calibration_data = EMG_calibration_data(1:19765, :);
    elseif str2num(ID) == 4 %%%%% ID4 timestamps not working.... dodgy
        EMG_data = ['ID_4_test_EMG_data_slow'];
        EMG_calibration_data = experiment_data.(EMG_data);
        EMG_calibration_data = EMG_calibration_data(1:14116, :);
    elseif str2num(ID) == 5 %%%%% ID5 timestamps not working.... dodgy
        EMG_data = ['ID_5_test_EMG_data_medium'];
        EMG_calibration_data = experiment_data.(EMG_data);
%         EMG_calibration_data = EMG_calibration_data(1:14116, :);
    else
        EMG_data = ['ID_' ID '_test_EMG_data_calib'];
        EMG_calibration_data = experiment_data.(EMG_data);
    end
    % plot the moving mean for the cut data. this removes the data with
    % bands below a certain amount, the goal being to take away parts when
    % myo shouldnt have been recording. This should give a total time of
    % ~20seconds
%      figure(1)
     moving_RMS_EMG = sqrt(movmean(EMG_calibration_data{1:end,1:8}.^2,10));
     indices_a = find(moving_RMS_EMG(1:end,1) < 3);
     moving_RMS_EMG(indices_a, :) = [];
     EMG_calibration_data(indices_a, :) = [];
     
     indices_b = find(moving_RMS_EMG(1:end,3) < 3);
     moving_RMS_EMG(indices_b, :) = [];
     EMG_calibration_data(indices_b, :) = [];
          
     indices_c = find(moving_RMS_EMG(1:end,6) < 3);
     moving_RMS_EMG(indices_c, :) = [];
     EMG_calibration_data(indices_c, :) = [];
     
%      plot(moving_RMS_EMG)
%      legend
    
    % split the timestamp
    EMG_calibration_data_split = datevec(EMG_calibration_data.Timestamp);
    % find the seconds part
    EMG_calibration_data_seconds = seconds(EMG_calibration_data_split(:,6));
    %extract the minutes part
    EMG_calibration_data_minutes = minutes(EMG_calibration_data_split(:,5));
    % remove minutes and seconds index 1 to get normalised
    EMG_calibration_data_normalised_min = EMG_calibration_data_minutes - EMG_calibration_data_minutes(1);
    EMG_calibration_data_normalised_sec = EMG_calibration_data_seconds - EMG_calibration_data_seconds(1);
    % find overall time in seconds
    EMG_calib_total = seconds(EMG_calibration_data_normalised_min + EMG_calibration_data_normalised_sec);
    % find dt the difference in time (note some of these are 0)
    dt = diff(EMG_calib_total);
    % last timestamp in the emg file
    END_TIME = EMG_calib_total(end)
    % total time of emg file with cutting
    TOTAL_TIME = 0.005*length(EMG_calib_total)
    
    % turn seconds into a table
    Arr_emg_data = array2table(EMG_calib_total);
    % add the seconds and calibration emg data to a single table
    for i = 1:8
        Arr_emg_data = [Arr_emg_data EMG_calibration_data(:,i)];        
    end
    
    %%%% Plot the moving average of the whole calibration sequence.
%     for i = 1:8
%          figure(1)
%          
%          plot(sqrt(movmean(EMG_calibration_data{1:end,i}.^2,10)))
%          hold on
% %          hold on
% %          plot(flex_EMG_total)
% %          hold on
% %          plot(extend_EMG_total)
% %          hold on
% %          plot(cocontract_EMG_total)
% %          hold off
%      end
%      hold off
%      legend

     
     %% snip the data up according to the 10s relax,5s flex, 5s extend, and 5s cocontract
     % this has been done using ratios. Need to check the plots to make
     % sure this works for the specific participant. Generally, 2 or 3=
     % flex and 6-7 extend
        relax_EMG = Arr_emg_data(1: round(0.33 * length(EMG_calib_total)), :)  ;
        % flex data
        flex_EMG = Arr_emg_data(round(0.33 * length(EMG_calib_total)) + 1 : round(0.53 * length(EMG_calib_total)), :)  ;
        % extend data
        extend_EMG = Arr_emg_data(round(0.53 * length(EMG_calib_total)) + 1 : round(0.73 * length(EMG_calib_total)), :)  ;
        % cocontract data
        cocontract_EMG = Arr_emg_data(round(0.73 * length(EMG_calib_total)) + 1 : end, :)  ;
        
     relax_EMG_total = zeros(8,1);
     flex_EMG_total = zeros(8,1);
     extend_EMG_total = zeros(8,1);
     cocontract_EMG_total = zeros(8,1);
     
     %%% check the values on right. If they're very close then inspect more
     %%% closely
     for i= 2:9
%          relax_EMG_total(i-1) = sum(abs(relax_EMG{1:end,i}),1);
         relax_EMG_total(i-1) = sum(sqrt(movmean(relax_EMG{1:end,i}.^2,10)));
%          flex_EMG_total(i-1) =  sum(abs(flex_EMG{1:end,i}),1);
         flex_EMG_total(i-1) = sum(sqrt(movmean(flex_EMG{1:end,i}.^2,10)));
%          extend_EMG_total(i-1) = sum(abs(extend_EMG{1:end,i}),1);
         extend_EMG_total(i-1) = sum(sqrt(movmean(extend_EMG{1:end,i}.^2,10)));
%          cocontract_EMG_total(i-1) = sum(abs(cocontract_EMG{1:end,i}),1);
         cocontract_EMG_total(i-1) = sum(sqrt(movmean(cocontract_EMG{1:end,i}.^2,10)));
         
     end
     
     
%      top_three_relax = maxk(relax_EMG_total,3);
%      bands_EMG_relax = [];
     
%      top_three_flex = maxk(flex_EMG_total,3);
     top_flex = maxk(flex_EMG_total,1);
     bands_EMG_flex = [];
     
%      top_three_extend = maxk(extend_EMG_total,3);
     top_extend = maxk(extend_EMG_total,1);
     bands_EMG_extend = [];
     
     top_three_cocontract = maxk(cocontract_EMG_total,3);
     bands_EMG_cocontract = [];
     
%         bands_EMG_relax = [bands_EMG_relax find(top_three_relax(i) == relax_EMG_total)];
      for i = 1
        bands_EMG_flex = [bands_EMG_flex find(top_flex(i) == flex_EMG_total)];
        bands_EMG_extend = [bands_EMG_extend find(top_extend(i) == extend_EMG_total)];
      end
        
    top_three_cocontract = sort(top_three_cocontract,'descend');
        
    for i = 1:3
        bands_EMG_cocontract = [bands_EMG_cocontract find(top_three_cocontract(i) == cocontract_EMG_total)];
        
    end
    
    if abs(bands_EMG_flex - bands_EMG_extend) < 2
        bands_EMG_extend = 6
    end
    
 %% relax EMG for comparison in stat test
fs = 200;
fnyq=fs/2;
fco=20;
[b,a]=butter(2,fco*1.25/fnyq);

% Filter the flex emg pod
x_flex = (relax_EMG{1:end,bands_EMG_flex + 1});
x_high_flex = highpass(x_flex,5,fs);
x_band_flex = bandstop(x_high_flex,[49.9 50.1],fs);
x_flex = lowpass(x_band_flex,99,fs) ;

y_flex=abs(x_flex-mean(x_flex));
% apply butterworth to flex
z_flex=filtfilt(b,a,y_flex);
t = 0:0.005:(length(x_flex) - 1) * 0.005;

% Filter the flex emg pod
x_extend = (relax_EMG{1:end,bands_EMG_extend + 1});
x_high_extend = highpass(x_extend,5,fs);
x_band_extend = bandstop(x_high_extend,[49.9 50.1],fs);
x_extend = lowpass(x_band_extend,99,fs) ;

y_extend=abs(x_extend-mean(x_extend));
% apply butterworth to flex
z_extend=filtfilt(b,a,y_extend);


time_calib(str2num(ID)-5) = t(end);


Int_calib_flex(str2num(ID)-5) = trapz(t, z_flex);
Int_calib_extend(str2num(ID)-5) = trapz(t, z_extend);

smoothness_flex_calib(str2num(ID)-5) = var(z_flex);
smoothness_extend_calib(str2num(ID)-5) = var(z_extend);



Calib_Temporal.('time_calib')  = time_calib';

Calib_Temporal.('Int_calib_flex')  = Int_calib_flex';
Calib_Temporal.('Int_calib_extend')  = Int_calib_extend';
Calib_Temporal.('smoothness_flex_calib')  = smoothness_flex_calib';
Calib_Temporal.('smoothness_extend_calib')  = smoothness_extend_calib';
foldersave = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data\Data_MATLAB\EMG_Temporal';
filesave = ['Temporal_EMG_Calib'];
save(fullfile(foldersave, filesave), 'Calib_Temporal')
end
end
%%
%% EMG date temp should only need to run once
if str2num(ID) == 6 | str2num(ID) == 7 | str2num(ID) == 1 ...
        | str2num(ID) == 4 | str2num(ID) == 5
    EMG_date_temp = datetime('2021-08-17');
elseif str2num(ID) == 8 | str2num(ID) == 9 | str2num(ID) == 10
    EMG_date_temp = datetime('2021-08-18');
elseif str2num(ID) == 11
    EMG_date_temp = datetime('2021-08-19');
elseif str2num(ID) == 12 | str2num(ID) == 13
    EMG_date_temp = datetime('2021-08-20');
elseif str2num(ID) == 14
    EMG_date_temp = datetime('2021-08-23');
elseif str2num(ID) == 15 | str2num(ID) == 16 | str2num(ID) == 17
    EMG_date_temp = datetime('2021-08-24');
end

%% Find time of 'catch' and then plot linear envelope for this phase of the movement

% SLOW
namesslow = fieldnames( slow_filteredStruct );
subStrPol = '_POLGroundTruth';
Pol_filteredStruct_slow = rmfield( slow_filteredStruct, namesslow(find(cellfun(@isempty, strfind( namesslow, subStrPol)))));
Polh_Fields_slow = fieldnames(Pol_filteredStruct_slow);
fs = 200;

namesmedium = fieldnames( medium_filteredStruct );
Pol_filteredStruct_medium = rmfield( medium_filteredStruct, namesmedium(find(cellfun(@isempty, strfind( namesmedium, subStrPol)))));
Polh_Fields_medium = fieldnames(Pol_filteredStruct_medium);

namesfast = fieldnames( fast_filteredStruct );
Pol_filteredStruct_fast = rmfield( fast_filteredStruct, namesfast(find(cellfun(@isempty, strfind( namesfast, subStrPol)))));
Polh_Fields_fast = fieldnames(Pol_filteredStruct_fast);

%% slow
dt_mean = (seconds(mean(seconds(dt))));
% signal_flex_slow = zeros(1000,50);
 EMG_data_used = ['ID_',num2str(ID),'_test_EMG_data_slow'];
 EMG_extra1 = ['ID_',num2str(ID),'_test_EMG_data_slowv2'];
 EMG_extra2 = ['ID_',num2str(ID),'_test_EMG_data_slowv3'];
 
EMG_data = experiment_data.(EMG_data_used);
try 
    EMG_data1 = experiment_data.(EMG_extra1);
    EMG_data = [EMG_data; EMG_data1];
end
try 
    EMG_data2 = experiment_data.(EMG_extra2);
    EMG_data = [EMG_data; EMG_data2];
end


for trialnum = 1: length(Polh_Fields_slow)
%     figure(10)
% for trialnum = 1
 pol_dynamic = [string(Polh_Fields_slow(trialnum))]; 

    % find catch part of trial. For more details see
    % AngularVelocity_vs_Error_spline.m
    if isfield(experiment_data,pol_dynamic) == 1
        Pol_data = experiment_data.(pol_dynamic);

        x_pol = (Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
        t_pol = (Pol_data{:,1});
        try
        dt_pol = seconds(diff(t_pol));
        % get rid of dodge dt_pol values
        ind_dt_pol = dt_pol < 0.1 & dt_pol > 0 ;
        dt_pol = dt_pol(ind_dt_pol);
        % get rid of nans and find mean
        dt_pol_mean =  mean(dt_pol(~isnan(dt_pol)));
        % use means to calc vel and then remove nans 
        temp_nans = diff(y_pol)./dt_pol_mean;
        vel_temp = temp_nans(~isnan(temp_nans));
        
        v = (lowpass(vel_temp, 5, 1/dt_pol_mean));
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+100);
        y_pol(more_rowsToDelete) = [];
        x_pol(more_rowsToDelete) = [];
        y_pol(rowsToDelete) = [];
        x_pol(rowsToDelete) = []; 
        length_v_half = round(3*length(v)/10);
        length_v_end_part = round(length(v) * 0.8);
        
        max_v = max(v(length_v_half:length_v_end_part));
        max_v_ind = find(v==max_v);
        
        if max_v > 200
            end_ind = max_v_ind + 50;
            start_ind = max_v_ind - 50;
            
        elseif max_v > 150 & max_v <= 200
            end_ind = max_v_ind + 100;
            start_ind = max_v_ind - 50;
            
        elseif max_v > 100 & max_v <= 150
            end_ind = max_v_ind+ 150;
            start_ind = max_v_ind - 50;
            
        elseif max_v > 60 & max_v <= 100
            end_ind = max_v_ind + 275;
            start_ind = max_v_ind - 50;
            
        else
            end_ind = max_v_ind + 400;
            start_ind = max_v_ind - 75;
        end
        
        velocities_slow(trialnum) = mean(abs(v(start_ind:end_ind)));
        % this finds the EMG catch phase using the timestamps of the catch
        % period from the polh data
%         EMG_date_temp = datetime(EMG_data.Timestamp,'Format','yyyy-MM-dd');

        
        timestamp_start = EMG_date_temp + (x_pol(start_ind));
        timestamp_start.Format = 'hh:mm:ss';
        timestamp_end = EMG_date_temp + (x_pol(end_ind));
        timestamp_end.Format = 'hh:mm:ss';
        EMG_date_timestamp = EMG_data.Timestamp ;
        EMG_date_timestamp.Format = 'hh:mm:ss';
        EMG_indexes = (EMG_date_timestamp >= timestamp_start ) & (EMG_date_timestamp <= timestamp_end) ;
        EMG_catch = EMG_data(EMG_indexes,:);


%         %%%Matlab code to find linear envelope of a signal
%         %%%Taken from EMG analysis.pdf

%         Butterworth filter
        fnyq=fs/2;
        fco=20;
        [b,a]=butter(2,fco*1.25/fnyq);
        
        % Filter the flex emg pod
        x_flex = table2array(EMG_catch(:,bands_EMG_flex));
        x_high_flex = highpass(x_flex,5,fs);
        x_band_flex = bandstop(x_high_flex,[49.9 50.1],fs);
        x_flex = lowpass(x_band_flex,99,fs) ;

        y_flex=abs(x_flex-mean(x_flex));
        % apply butterworth to flex
        z_flex=filtfilt(b,a,y_flex);
        t = 0:0.005:(length(x_flex) - 1) * 0.005;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%   time errors.
        time_slow(trialnum) = t(end);
        
        %plot flex
%         plot(t,z_flex,'r');
%         hold on 
        
        % do the same for extend pod
        x_extend = table2array(EMG_catch(:,bands_EMG_extend));
        x_high_extend = highpass(x_extend,5,fs);
        x_band_extend = bandstop(x_high_extend,[49.9 50.1],fs);
        x_extend = lowpass(x_band_extend,99,fs) ;

        y_extend=abs(x_extend-mean(x_extend));
        % same filter used
        z_extend=filtfilt(b,a,y_extend);
        % time should be the same as well
%         t = 0:0.005:(length(x_extend) - 1) * 0.005;
%         plot(t,z_extend,'b');
%         xlabel('Time after catch (s)', 'FontSize', 16); ylabel('EMG (mV)', 'FontSize', 16);
%         legend('Linear envelope', 'FontSize', 10);
%         hold on
        
        
        % now calculate the integrated EMG and append it
        if z_flex
            Int_slow_flex(trialnum) = trapz(t, z_flex);
            Int_slow_extend(trialnum) = trapz(t, z_extend);

            smoothness_flex_slow(trialnum) = var(z_flex);
            smoothness_extend_slow(trialnum) = var(z_extend);
        else
            Int_slow_flex(trialnum) = 0;
            Int_slow_extend(trialnum) = 0;

            smoothness_flex_slow(trialnum) = 0;
            smoothness_extend_slow(trialnum) = 0;
        end
        %%%%>>>>>>>>>>>>>>>> OLD code slotted in here
        
        signal_flex_slow(1:length(z_flex), trialnum)= z_flex;
        signal_extend_slow(1:length(z_extend), trialnum)= z_extend;
        catch me
            fprintf('Polh timing issues');
            counter_fail = counter_fail + 1 
        end
    end
end


% title('Slow', ['Flex IEMG:  ' num2str(mean(Int_slow_flex)) ' smooth ' num2str(mean(smoothness_flex_slow)) ' :Extend  '...
%     num2str(mean(Int_slow_extend)) ' Smooth  ' num2str(mean(smoothness_extend_slow))])
% hold off



%% medium 
EMG_data_used = ['ID_',num2str(ID),'_test_EMG_data_medium']; 
EMG_extra1 = ['ID_',num2str(ID),'_test_EMG_data_mediumv2'];
EMG_extra2 = ['ID_',num2str(ID),'_test_EMG_data_mediumv3'];

EMG_data = experiment_data.(EMG_data_used);
try
    EMG_data1 = experiment_data.(EMG_extra1);
    EMG_data = [EMG_data; EMG_data1];
end
try
    EMG_data2 = experiment_data.(EMG_extra2);
    EMG_data = [EMG_data; EMG_data2];
end

for trialnum = 1: length(Polh_Fields_medium)
%     figure(20)
% for trialnum = 4
 pol_dynamic = [string(Polh_Fields_medium(trialnum))]; 
 
 
    % find catch part of trial. For more details see
    % AngularVelocity_vs_Error_spline.m
    if isfield(experiment_data,pol_dynamic) == 1
        Pol_data = experiment_data.(pol_dynamic);
                
        x_pol = (Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
        t_pol = (Pol_data{:,1});
        try
        dt_pol = seconds(diff(t_pol));
        % get rid of dodge dt_pol values
        ind_dt_pol = dt_pol < 0.1 & dt_pol > 0 ;
        dt_pol = dt_pol(ind_dt_pol);
        % get rid of nans and find mean
        dt_pol_mean =  mean(dt_pol(~isnan(dt_pol)));
        % use means to calc vel and then remove nans 
        temp_nans = diff(y_pol)./dt_pol_mean;
        vel_temp = temp_nans(~isnan(temp_nans));
        
        v = (lowpass(vel_temp, 5, 1/dt_pol_mean));
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+100);
        y_pol(more_rowsToDelete) = [];
        x_pol(more_rowsToDelete) = [];
        y_pol(rowsToDelete) = [];
        x_pol(rowsToDelete) = []; 
        length_v_half = round(3*length(v)/10);
        length_v_end_part = round(length(v) * 0.8);
        
        max_v = max(v(length_v_half:length_v_end_part));
        max_v_ind = find(v==max_v);
        
        if max_v > 200
            end_ind = max_v_ind + 50;
            start_ind = max_v_ind - 50;
            
        elseif max_v > 150 & max_v <= 200
            end_ind = max_v_ind + 100;
            start_ind = max_v_ind - 50;
            
        elseif max_v > 100 & max_v <= 150
            end_ind = max_v_ind+ 150;
            start_ind = max_v_ind - 50;
            
        elseif max_v > 60 & max_v <= 100
            end_ind = max_v_ind + 275;
            start_ind = max_v_ind - 50;
            
        else
            end_ind = max_v_ind + 400;
            start_ind = max_v_ind - 75;
        end
        if end_ind < length(v)
            velocities_medium(trialnum) = mean(abs(v(start_ind:end_ind)));
        else
            velocities_medium(trialnum) = mean(abs(v(start_ind:end)));
        end
        % this finds the EMG catch phase using the timestamps of the catch
        % period from the polh data
       
        
        if end_ind < length(v)
        
            timestamp_start = EMG_date_temp + (x_pol(start_ind));
            timestamp_start.Format = 'hh:mm:ss';
            timestamp_end = EMG_date_temp + (x_pol(end_ind));
            timestamp_end.Format = 'hh:mm:ss';
        else
            timestamp_start = EMG_date_temp + (x_pol(start_ind));
            timestamp_start.Format = 'hh:mm:ss';
            timestamp_end = EMG_date_temp + (x_pol(end));
            timestamp_end.Format = 'hh:mm:ss';
        end
            EMG_date_timestamp = EMG_data.Timestamp ;
            EMG_date_timestamp.Format = 'hh:mm:ss';
            EMG_indexes = (EMG_date_timestamp >= timestamp_start ) & (EMG_date_timestamp <= timestamp_end) ;
            EMG_catch = EMG_data(EMG_indexes,:);
        
        %         %%%Matlab code to find linear envelope of a signal
%         %%%Taken from EMG analysis.pdf

%         Butterworth filter
        fnyq=fs/2;
        fco=20;
        [b,a]=butter(2,fco*1.25/fnyq);
        
        % Filter the flex emg pod
        x_flex = table2array(EMG_catch(:,bands_EMG_flex));
        x_high_flex = highpass(x_flex,5,fs);
        x_band_flex = bandstop(x_high_flex,[49.9 50.1],fs);
        x_flex = lowpass(x_band_flex,99,fs) ;

        y_flex=abs(x_flex-mean(x_flex));
        % apply butterworth to flex
        z_flex=filtfilt(b,a,y_flex);
        t = 0:0.005:(length(x_flex) - 1) * 0.005;
        ind_del = t > 0.75;
        t(ind_del) = [];
        z_flex(ind_del) = [];
        %plot flex
%%%%%%%%%%%%%%%%%%%%%%%%%   time errors.
        time_medium(trialnum) = t(end);

%         plot(t,z_flex,'r');
%         hold on 
        
        % do the same for extend pod
        x_extend = table2array(EMG_catch(:,bands_EMG_extend));
        x_high_extend = highpass(x_extend,5,fs);
        x_band_extend = bandstop(x_high_extend,[49.9 50.1],fs);
        x_extend = lowpass(x_band_extend,99,fs) ;

        y_extend=abs(x_extend-mean(x_extend));
        % same filter used
        z_extend=filtfilt(b,a,y_extend);
        
        z_extend(ind_del) = [];
        % time should be the same as well
%         t = 0:0.005:(length(x_extend) - 1) * 0.005;
%         plot(t,z_extend,'b');
%         xlabel('Time after catch (s)', 'FontSize', 16); ylabel('EMG (mV)', 'FontSize', 16);
%         legend('Linear envelope', 'FontSize', 10);
%         hold on
        
        
        % now calculate the integrated EMG and append it
        if z_flex
            Int_medium_flex(trialnum) = trapz(t, z_flex);
            Int_medium_extend(trialnum) = trapz(t, z_extend);

            smoothness_flex_medium(trialnum) = var(z_flex);
            smoothness_extend_medium(trialnum) = var(z_extend);
        else
            Int_medium_flex(trialnum) = 0;
            Int_medium_extend(trialnum) = 0;

            smoothness_flex_medium(trialnum) = 0;
            smoothness_extend_medium(trialnum) = 0;
        end
        %%%%>>>>>>>>>>>>>>>> OLD code slotted in here
              
        signal_flex_medium(1:length(z_flex), trialnum)= z_flex;
        signal_extend_medium(1:length(z_extend), trialnum)= z_extend;
        catch me
            fprintf('Polh timing issues');
            counter_fail = counter_fail + 1
        end
    end
end


% title('Medium', ['Flex IEMG:  ' num2str(mean(Int_medium_flex)) ' smooth ' num2str(mean(smoothness_flex_medium)) ' :Extend  '...
%     num2str(mean(Int_medium_extend)) ' Smooth  ' num2str(mean(smoothness_extend_medium))])
% hold off


%% fast
EMG_data_used = ['ID_',num2str(ID),'_test_EMG_data_fast']; 
EMG_extra1 = ['ID_',num2str(ID),'_test_EMG_data_fastv2'];
EMG_extra2 = ['ID_',num2str(ID),'_test_EMG_data_fastv3'];

EMG_data = experiment_data.(EMG_data_used);
try
    EMG_data1 = experiment_data.(EMG_extra1);
    EMG_data = [EMG_data; EMG_data1];
end
try
    EMG_data2 = experiment_data.(EMG_extra2);
    EMG_data = [EMG_data; EMG_data2];
end

for trialnum = 1: length(Polh_Fields_fast)
dt_mean = (seconds(mean(seconds(dt))));
% figure(30)
pol_dynamic = [string(Polh_Fields_fast(trialnum))]; 
 
    % find catch part of trial. For more details see
    % AngularVelocity_vs_Error_spline.m
    if isfield(experiment_data,pol_dynamic) == 1
        Pol_data = experiment_data.(pol_dynamic);
        
        x_pol = (Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
        t_pol = (Pol_data{:,1});
        try
        dt_pol = seconds(diff(t_pol));
        % get rid of dodge dt_pol values
        ind_dt_pol = dt_pol < 0.1 & dt_pol > 0 ;
        dt_pol = dt_pol(ind_dt_pol);
        % get rid of nans and find mean
        dt_pol_mean =  mean(dt_pol(~isnan(dt_pol)));
        % use means to calc vel and then remove nans 
        temp_nans = diff(y_pol)./dt_pol_mean;
        vel_temp = temp_nans(~isnan(temp_nans));
        
        v = (lowpass(vel_temp, 5, 1/dt_pol_mean));

        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+100);
        y_pol(more_rowsToDelete) = [];
        x_pol(more_rowsToDelete) = [];
        y_pol(rowsToDelete) = [];
        x_pol(rowsToDelete) = []; 
        length_v_half = round(3*length(v)/10);
        length_v_end_part = round(length(v) * 0.8);
        
        max_v = max(v(length_v_half:length_v_end_part));
        max_v_ind = find(v==max_v);
        
        
        if max_v > 200
            end_ind = max_v_ind + 50;
            start_ind = max_v_ind - 50;
            
        elseif max_v > 150 & max_v <= 200
            end_ind = max_v_ind + 100;
            start_ind = max_v_ind - 50;
            
        elseif max_v > 100 & max_v <= 150
            end_ind = max_v_ind+ 150;
            start_ind = max_v_ind - 50;
            
        elseif max_v > 60 & max_v <= 100
            end_ind = max_v_ind + 275;
            start_ind = max_v_ind - 50;
            
        else
            end_ind = max_v_ind + 400;
            start_ind = max_v_ind - 75;
        end
        
        if end_ind < length(v)
            velocities_fast(trialnum) = mean(abs(v(start_ind:end_ind)));
        else
            velocities_fast(trialnum) = mean(abs(v(start_ind:end)));
        end
        
        
        if end_ind < length(v)
        
            timestamp_start = EMG_date_temp + (x_pol(start_ind));
            timestamp_start.Format = 'hh:mm:ss';
            timestamp_end = EMG_date_temp + (x_pol(end_ind));
            timestamp_end.Format = 'hh:mm:ss';
        else
            timestamp_start = EMG_date_temp + (x_pol(start_ind));
            timestamp_start.Format = 'hh:mm:ss';
            timestamp_end = EMG_date_temp + (x_pol(end));
            timestamp_end.Format = 'hh:mm:ss';
        end
        EMG_date_timestamp = EMG_data.Timestamp ;
        EMG_date_timestamp.Format = 'hh:mm:ss';
        EMG_indexes = (EMG_date_timestamp >= timestamp_start ) & (EMG_date_timestamp <= timestamp_end) ;
        EMG_catch = EMG_data(EMG_indexes,:);

        %         %%%Matlab code to find linear envelope of a signal
%         %%%Taken from EMG analysis.pdf

%         Butterworth filter
        fnyq=fs/2;
        fco=20;
        [b,a]=butter(2,fco*1.25/fnyq);
        
        % Filter the flex emg pod
        x_flex = table2array(EMG_catch(:,bands_EMG_flex));
        x_high_flex = highpass(x_flex,5,fs);
        x_band_flex = bandstop(x_high_flex,[49.9 50.1],fs);
        x_flex = lowpass(x_band_flex,99,fs) ;

        y_flex=abs(x_flex-mean(x_flex));
        % apply butterworth to flex
        z_flex=filtfilt(b,a,y_flex);
        t = 0:0.005:(length(x_flex) - 1) * 0.005;
        ind_del = t > 0.45;
        t(ind_del) = [];
        z_flex(ind_del) = [];
        %plot flex
%%%%%%%%%%%%%%%%%%%%%%%%%   time errors.
        time_fast(trialnum) = t(end);

%         plot(t,z_flex,'r');
%         hold on 
        
        % do the same for extend pod
        x_extend = table2array(EMG_catch(:,bands_EMG_extend));
        x_high_extend = highpass(x_extend,5,fs);
        x_band_extend = bandstop(x_high_extend,[49.9 50.1],fs);
        x_extend = lowpass(x_band_extend,99,fs) ;

        y_extend=abs(x_extend-mean(x_extend));
        % same filter used
        z_extend=filtfilt(b,a,y_extend);
        
        z_extend(ind_del) = [];
        % time should be the same as well
%         t = 0:0.005:(length(x_extend) - 1) * 0.005;
%         plot(t,z_extend,'b');
%         xlabel('Time after catch (s)', 'FontSize', 16); ylabel('EMG (mV)', 'FontSize', 16);
%         legend('Linear envelope', 'FontSize', 10);
%         hold on
        
        
        % now calculate the integrated EMG and append it
        if z_flex
            Int_fast_flex(trialnum) = trapz(t, z_flex);
            Int_fast_extend(trialnum) = trapz(t, z_extend);

            smoothness_flex_fast(trialnum) = var(z_flex);
            smoothness_extend_fast(trialnum) = var(z_extend);
        
        else
            Int_fast_flex(trialnum) = 0;
            Int_fast_extend(trialnum) = 0;

            smoothness_flex_fast(trialnum) = 0;
            smoothness_extend_fast(trialnum) = 0;
        end
        %%%%>>>>>>>>>>>>>>>> OLD code slotted in here
             
        signal_flex_fast(1:length(z_flex), trialnum)= z_flex;
        signal_extend_fast(1:length(z_extend), trialnum)= z_extend;
        catch me
            fprintf('Polh timing issues');
            counter_fail = counter_fail + 1
        end
    end
end


% title('fast', ['Flex IEMG:  ' num2str(mean(Int_fast_flex)) ' smooth ' num2str(mean(smoothness_flex_fast)) ' :Extend  '...
%     num2str(mean(Int_fast_extend)) ' Smooth  ' num2str(mean(smoothness_extend_fast))])
% hold off


%%
EMG_Temporal.('Int_slow_flex') = Int_slow_flex';
EMG_Temporal.('Int_slow_extend') = Int_slow_extend';
EMG_Temporal.('Int_medium_flex') = Int_medium_flex';
EMG_Temporal.('Int_medium_extend') = Int_medium_extend';
EMG_Temporal.('Int_fast_flex') = Int_fast_flex';
EMG_Temporal.('Int_fast_extend') = Int_fast_extend';

EMG_Temporal.('smoothness_flex_slow') = smoothness_flex_slow';
EMG_Temporal.('smoothness_extend_slow') = smoothness_extend_slow';
EMG_Temporal.('smoothness_flex_medium') = smoothness_flex_medium';
EMG_Temporal.('smoothness_extend_medium') = smoothness_extend_medium';
EMG_Temporal.('smoothness_flex_fast') = smoothness_flex_fast';
EMG_Temporal.('smoothness_extend_fast') = smoothness_extend_fast';

EMG_Temporal.('velocities_slow') = velocities_slow';
EMG_Temporal.('velocities_medium') = velocities_medium';
EMG_Temporal.('velocities_fast') = velocities_fast';

EMG_Temporal.('time_slow') = time_slow';
EMG_Temporal.('time_medium') = time_medium';
EMG_Temporal.('time_fast') = time_fast';

EMG_Temporal.('signal_flex_slow') = signal_flex_slow';
EMG_Temporal.('signal_extend_slow') = signal_extend_slow';
EMG_Temporal.('signal_flex_medium') = signal_flex_medium';
EMG_Temporal.('signal_extend_medium') = signal_extend_medium';
EMG_Temporal.('signal_flex_fast') = signal_flex_fast';
EMG_Temporal.('signal_extend_fast') = signal_extend_fast';


%%
ID = num2str(ID);
foldersave = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data\Data_MATLAB\EMG_Temporal';
filesave = ['Temporal_EMG_ID_' ID];
save(fullfile(foldersave, filesave), 'EMG_Temporal')
% 
% end 
% 
% end


% 
% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % OLD CODE:
%         %%%%%%%%%%%%>>>>>>>>> UNCOMMENT HERE!
% % % %         length(x_flex);
% % % % 
% %         figure(2)
% %         x_high_flex = highpass(x_flex,5,fs);
% %         x_band_flex = bandstop(x_high_flex,[49.9 50.1],fs);
% %         x_flex = lowpass(x_band_flex,99,fs) ;
% %         
% 
% %         movRMS_flex_50 = sqrt(movmean(x_flex.^2,10));
% %         movRMS_flex_25 = sqrt(movmean(x_flex.^2,5));
% %         x_time_50 = 0:0.005:(length(movRMS_flex_50) - 1) * 0.005;
% %         x_time_25 = 0:0.005:(length(movRMS_flex_25) - 1) * 0.005;
% % %         subplot(2,1,1)
% %         plot(x_time_50, movRMS_flex_50,'b')
% %         hold on
% %         plot(x_time_25, movRMS_flex_25,'r')
% %         Int_slow_flex(trialnum) = trapz(x_time_50, movRMS_flex_50)/ x_time_50(end);
% %         
% %         xlabel('Time after catch (s)', 'FontSize', 16)
% %         ylabel('RMS Voltage (mV)', 'FontSize', 16)
% %         legend('Sliding window of 50ms', 'Sliding window of 25ms', 'FontSize', 10)
% % %         title('Top is flexor, bottom is extensor')
% %         hold on
% % % %         
% % % %         x_extend= table2array(EMG_catch(:,bands_EMG_extend));
% % % %         length(x_extend);
% % % % 
% % % %         subplot(2,1,2)
% % % %         x_slow_extend = highpass(x_extend,5,fs);
% % % %         x_band_extend = bandstop(x_slow_extend,[49.9 50.1],fs);
% % % %         x_extend = lowpass(x_band_extend,99,fs) ;
% % % %         
% % % % 
% % % %         movRMS_extend = sqrt(movmean(x_extend.^2,10));
% % % %         x_extend = 0:0.005:(length(movRMS_extend) - 1) * 0.005;
% % % %         plot(x_extend, movRMS_extend)
% % % %         Int_slow_extend(trialnum) = trapz(x_extend, movRMS_extend)/ x_extend(end);
% % % %         xlabel('Time after catch (s)')
% % % %         ylabel('RMS Voltage (mV)')
% % % %         hold on