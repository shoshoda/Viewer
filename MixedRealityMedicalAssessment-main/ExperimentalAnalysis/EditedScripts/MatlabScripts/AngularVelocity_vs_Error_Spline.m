clc; close all;
clear all;
%% Input the ID of data you want to analyse here. The .mat file will then be auto-loaded.

chk = exist('Nodes','var');
if ~chk
    
    ID = 14;
    ID = num2str(ID);
    ID_folder = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data\Data_MATLAB\UnprocessedData';
    ID_folder =  [ID_folder '\'];
    mat_data = ['Data_' ID];


    load([ID_folder mat_data])
end

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

%% slow
namesslow = fieldnames( slow_filteredStruct );
subStrPol = '_POLGroundTruth';
Pol_filteredStruct_slow = rmfield( slow_filteredStruct, namesslow(find(cellfun(@isempty, strfind( namesslow, subStrPol)))));
Polh_Fields = fieldnames(Pol_filteredStruct_slow);
subStrHolo = '_HoloData';
Holo_filteredStruct_slow = rmfield( slow_filteredStruct, namesslow(find(cellfun(@isempty, strfind( namesslow, subStrHolo)))));
Holo_Fields = fieldnames(Holo_filteredStruct_slow);
lag_term_slow = 0.15;
calibration_term_slow = 2.8;
lag_term_medium = 0.2;
calibration_term_medium = 4;
lag_term_fast = 0.2;
calibration_term_fast = 4;

%% slow
vels_cell_slow_ID_1 = cell(0, 12);
integer = 0;
% for trialnum = 1:length(Polh_Fields)
for trialnum = 20
       
    pol_dynamic = [string(Polh_Fields(trialnum - integer))]; 
    
    if trialnum < length(Holo_Fields)
        
    holo_dynamic = [string(Holo_Fields(trialnum))];
    newStr = erase(pol_dynamic,'_POLGroundTruth');
    newSubstr = erase(holo_dynamic, '_HoloData');
    
    if newStr ~= newSubstr
        integer = integer+1;
        
    elseif newStr == newSubstr

    if isfield(experiment_data,pol_dynamic) == 1
        Pol_data = experiment_data.(pol_dynamic);
        Holo_data = experiment_data.(holo_dynamic);
        
        try
            
        x_pol = seconds(Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
%         pol_millis = Pol_data.Milliseconds;

        t = (Pol_data{:,1});
%         y_angular = Pol_data.AngularVelocity;

        dt = diff(t);
        try
%         y_angular = (diff(y_pol)./seconds(dt));
        v = (lowpass(diff(y_pol)./seconds(dt), 5, 1/mean(seconds(dt))));
        
%         time = seconds(t(2:end,1)- t(1,1));
%         figure(1)
%         plot( time ,y_angular )
%         xlabel('Time (s)', 'FontSize', 20)
%         ylabel('Raw velocity (deg/s)', 'FontSize', 16)
%         
%         
%         
%         figure(2)
%         plot( time,v(:) )
%         hold on
%         xlabel('Time (s)', 'FontSize', 20)
%         ylabel('Filtered velocity (deg/s)', 'FontSize', 16)
%         hold off

        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp) - lag_term_slow;
        seconds_diff = diff(seconds(Holo_data.Timestamp));
        holo_freq = 1/(sum(seconds_diff)/ length(seconds_diff));
     
        y_holo = Holo_data.Angle + calibration_term_slow;

        % remove data outside of 0-180 degrees
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+100);
        y_pol(more_rowsToDelete) = [];
        x_pol(more_rowsToDelete) = [];
        y_pol(rowsToDelete) = [];
        x_pol(rowsToDelete) = []; 

        
        %%% Old method of calculating velocity from smoothed polhemus angle data 
       
%         order = 3;
%         framelen = 93;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);

%         v_temp = zeros(length(pol_millis),1) ;
%         for i = 1:length(pol_millis)-1
%             v_temp(i) = abs((sgf(i+1)-sgf(i))/(pol_millis(i+1)-pol_millis(i)) * 1000000);
% %             v(i) = abs((y_pol(i+1)-y_pol(i))/(pol_millis(i+1)-pol_millis(i)) * 1000000);
%         end
%         
%         v = sgolayfilt(v_temp ,order, framelen);


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

        pol_dataframe = [x_pol y_pol];
        holo_data_comp = [x_holo y_holo];
        
        if end_ind < length(v)
            velocities = abs(v(start_ind:end_ind));
            avg_vel = mean(velocities);
            pol_comp = pol_dataframe(start_ind:end_ind, :);
            pol_comp_non_spline = pol_dataframe(start_ind:end, :);
%             
            
        elseif end_ind >= length(v)
            fprintf('end_ind out of length(v)')
            velocities = abs(v(start_ind:end-250));
            avg_vel = mean(velocities);
            pol_comp = pol_dataframe(start_ind:end-250, :);
            pol_comp_non_spline = pol_dataframe(start_ind:end, :);
        else
            avg_vel = 0;
            pol_comp = [0 0];
            fprintf('No avg vel data trial %i\n', trialnum)
        end
        
        % create spline!!
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));

        % removing duplicate data from y_holo
        [~, indexA, ~] = unique(y_holo);
        A = sort(indexA);
        y_holo_spline_temp = y_holo(A);
        x_holo_spline_temp = x_holo(A);
        % removing duplicate data from x_holo_spline
        [~, indexA, ~] = unique(x_holo_spline_temp);
        A = sort(indexA);
        y_holo_spline = y_holo_spline_temp(A);
        x_holo_spline = x_holo_spline_temp(A);
        
        %now create the spline
        steps_holo_spline = (x_holo_spline(length(x_holo_spline)) - x_holo_spline(1)) / sum(x_holo_spline);
        xx_holo_spline_post = x_holo_spline(1):steps_holo_spline:x_holo_spline(length(x_holo_spline));
        if length(y_holo_spline) > 1
            
            yy_holo_spline_post = spline(x_holo_spline,y_holo_spline,xx_holo_spline_post);
        
        % cut the spline data so that it perfectly matches pol_comp    
        index_holo_spline_temp = xx_holo_spline_post(:)>( pol_comp(1,1));
        spline_filtered_temp_x = xx_holo_spline_post((index_holo_spline_temp));
        spline_filtered_temp_y = yy_holo_spline_post((index_holo_spline_temp));
        index_holo_spline = spline_filtered_temp_x(:)<( pol_comp(end,1));
        xx_holo_spline_post = spline_filtered_temp_x((index_holo_spline));
        yy_holo_spline_post = spline_filtered_temp_y((index_holo_spline));
        
           
        % cut holo data 'around' the polh determined catch phase
        index_holo = holo_data_comp(:,1)>( pol_comp_non_spline(1,1));
        holo_filtered_temp = holo_data_comp((index_holo),1:2);
        diff_holo = diff(holo_filtered_temp(:,2));
        max_diff = (max(diff_holo));
        idx_diff = find(max_diff == diff_holo);
        if idx_diff + 3 < length(holo_filtered_temp)
            holo_filtered = holo_filtered_temp((1:idx_diff+3),1:2);
        else
                temp_idx_diff = max(diff_holo(diff_holo<max(diff_holo)));
                holo_filtered = holo_filtered_temp((1:temp_idx_diff+3),1:2);
        end

        
        % now need to make sure the timing is the same so cut polh data
        % around holo
        pol_index = pol_comp_non_spline(:,1) > holo_filtered(1,1);
        pol_filtered_temp = pol_comp_non_spline((pol_index),1:2);
        idx_pol_end = pol_filtered_temp(:,1) < holo_filtered(end,1);
        pol_comp_non_spline = pol_filtered_temp((idx_pol_end),1:2);
        
        % bin the data
        holo_comp_length = length(holo_filtered);
        pol_comp_length_non_spline = length(pol_comp_non_spline(:,1));
        bins_raw = floor(pol_comp_length_non_spline/holo_comp_length);
        i = 0;

        % bin the holo data
        holo_repeat_bins = [];
        bool = 0;
        for n = 1:holo_comp_length
            if bool == 0
                bool = 1;
                holo_repeat_bins(n:(n)*bins_raw) = holo_filtered(n,2);
            else
                holo_repeat_bins((n-1)*bins_raw + 1:(n)*bins_raw) = holo_filtered(n,2);
            end
            if n == holo_comp_length
                holo_repeat_bins(end:pol_comp_length_non_spline) = holo_filtered(n,2);
            end
        end
        
        % calculate the onset time during catch phase when holo misses tags
        holo_diffs = diff(y_holo_spline(:));
        time_diffs = diff(x_holo_spline(:));
        result = max( holo_diffs (holo_diffs >= 0) );
        onset_time = time_diffs(find(result == holo_diffs));
        
%         comparing_diff = abs(pol_binned_data(:) - holo_filtered(:,2));
        comparing_diff = abs(pol_comp_non_spline(:,2) - holo_repeat_bins(:));
        
        
        if length(comparing_diff) > 0 & onset_time < 1.2
             
            rmse = sqrt((sum(comparing_diff).^2)/length(comparing_diff));
            if avg_vel < 240
            vels_cell_slow_ID_1{end+1, 1}  = pol_dynamic;
            vels_cell_slow_ID_1{end, 2} = avg_vel;
            vels_cell_slow_ID_1{end, 3} = rmse;
            vels_cell_slow_ID_1{end, 5} = pol_comp_non_spline(:,1:2);
            vels_cell_slow_ID_1{end, 6} = holo_repeat_bins(:);
                   
            
            %spline rmse work: .....>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
            spline_comp_length = length(yy_holo_spline_post);
            pol_comp_length_non_spline = length(pol_comp(:,1));
            bins = floor(spline_comp_length/pol_comp_length_non_spline);
            i = 0;
            spline_binned_data =[];

            for n = 1:pol_comp_length_non_spline
                i= i + 1;
                if i == 1
                    spline_binned_data(i) = mean(yy_holo_spline_post(1:(n)*bins));
                else
                    spline_binned_data(i) = mean(yy_holo_spline_post(bins*(n-1):(n)*bins));
                end
            end

            comparing_diff_spline = abs(pol_comp(:,2)-spline_binned_data(:) );

            rmse_spline = sqrt((sum(comparing_diff_spline).^2)/length(comparing_diff_spline));
            avg_vel_whole_trial = mean(abs(v));
            
            vels_cell_slow_ID_1{end, 4} = rmse_spline;
            vels_cell_slow_ID_1{end, 7} = pol_comp(:,2);
            vels_cell_slow_ID_1{end, 8} = spline_binned_data(:);
            vels_cell_slow_ID_1{end, 9 } = onset_time;
            vels_cell_slow_ID_1{end, 10} = avg_vel_whole_trial;
            vels_cell_slow_ID_1{end, 11} = holo_freq;
            vels_cell_slow_ID_1{end, 12} = velocities;
            
            
%             figure(trialnum)
%             subplot(2,1,1)
% %             plot(holo_filtered(:,1) - pol_comp_non_spline(1,1), holo_filtered(:,2), 'x' )
%             plot( pol_comp_non_spline(:,1)- pol_comp_non_spline(1,1) ,holo_repeat_bins(:) )
%             hold on
%             plot(pol_comp_non_spline(:,1) - pol_comp_non_spline(1,1), pol_comp_non_spline(:,2))
%             title(['onset time: ' num2str(onset_time)], ['rmse with raw data: ' num2str(rmse)])
% %             title(['max v ' num2str(max_v)], ['start ind ' num2str(start_ind)])
%             hold off 
%             if trialnum == 8
            figure(trialnum)
            plot(x_holo_spline - x_pol(1), y_holo_spline)
            hold on
            plot(x_pol- x_pol(1), y_pol)
            xlim([0,7])
            hold off 
            legend('Hololens 2 data', 'Polhemus data','Location','SouthEast','FontSize', 16)
            ylabel('Angle (deg)','FontSize', 16)
            xlabel('Time (s)','FontSize', 16)
%             end
% %             
%             subplot(2,1,2)
%             plot(xx_holo_spline_post-pol_comp(1,1), yy_holo_spline_post);
%             hold on
%             plot(pol_comp(:,1) - pol_comp(1,1), pol_comp(:,2))
%             title(['rmse with spline: ' num2str(rmse_spline)],['avg vel: ' num2str(avg_vel)])
% %             title(['end ind ' num2str(end_ind)],['max v ind ' num2str(max_v_ind)])
%             hold off 
%            
            end
        end
        
        end
        catch me
        end
        catch me
        end
    
            else
        fprintf('No polhemus data for trial %i\n; slow trial \n',i)
            end
    end
    
    end
end

%% just plot
% close all;
% figure(1)
avg_vel_tot_slow = vels_cell_slow_ID_1(:,2);
rmse_tot_slow_raw = vels_cell_slow_ID_1(:,3);
rmse_tot_slow_spline = vels_cell_slow_ID_1(:,4);

% plot([avg_vel_tot_slow{:}], [rmse_tot_slow_raw{:}], 'o')
% hold on
% plot([avg_vel_tot_slow{:}], [rmse_tot_slow_spline{:}], 'X')
% hold off
% xlabel('Velocity (rad/s)')
% ylabel('RMSE error')
% legend('Raw data', 'Spline data')

%%
% close all;
% figure(2)
time_onset_slow = vels_cell_slow_ID_1(:,9);
rmse_tot_slow_raw = vels_cell_slow_ID_1(:,3);
rmse_tot_slow_spline = vels_cell_slow_ID_1(:,4);

% plot([time_onset_slow{:}], [rmse_tot_slow_raw{:}], 'o')
% hold on
% plot([time_onset_slow{:}], [rmse_tot_slow_spline{:}], 'X')
% hold off
% xlabel('Time onset (s)')
% ylabel('RMSE error')
% legend('Raw data', 'Spline data')
% 
%% medium
namesMedium = fieldnames( medium_filteredStruct );
subStrPol = '_POLGroundTruth';
Pol_filteredStruct_medium = rmfield( medium_filteredStruct, namesMedium(find(cellfun(@isempty, strfind( namesMedium, subStrPol)))));
Polh_Fields = fieldnames(Pol_filteredStruct_medium);
subStrHolo = '_HoloData';
Holo_filteredStruct_medium = rmfield( medium_filteredStruct, namesMedium(find(cellfun(@isempty, strfind( namesMedium, subStrHolo)))));
Holo_Fields = fieldnames(Holo_filteredStruct_medium);


%% edit ID number here !!
vels_cell_medium_ID_1 = cell(0, 12);
integer = 0;
for trialnum = 1:length(Polh_Fields) 
%     for trialnum = 1
       

    pol_dynamic = [string(Polh_Fields(trialnum - integer))]; 
    
    if trialnum < length(Holo_Fields)
        
    holo_dynamic = [string(Holo_Fields(trialnum))];
    newStr = erase(pol_dynamic,'_POLGroundTruth');
    newSubstr = erase(holo_dynamic, '_HoloData');
    
    if newStr ~= newSubstr
        integer = integer+1
        
    elseif newStr == newSubstr

    if isfield(experiment_data,pol_dynamic) == 1
        Pol_data = experiment_data.(pol_dynamic);
        Holo_data = experiment_data.(holo_dynamic);

        try
        x_pol = seconds(Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
        t = (Pol_data{:,1});

        dt = diff(t);
%         try
        v = (lowpass(diff(y_pol)./seconds(dt), 5, 1/mean(seconds(dt))));
       
        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp) - lag_term_medium;
        seconds_diff = diff(seconds(Holo_data.Timestamp));
        holo_freq = 1/(sum(seconds_diff)/ length(seconds_diff));
     
        y_holo = Holo_data.Angle + calibration_term_medium;

        
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+100);
        y_pol(more_rowsToDelete) = [];
        x_pol(more_rowsToDelete) = [];
        y_pol(rowsToDelete) = [];
        x_pol(rowsToDelete) = []; 
        
        %%% added for presentation 
%        
%         order = 3;
%         framelen = 93;
% 
%         sgf = sgolayfilt(y_pol,order,framelen);
%         
%         v_temp = zeros(length(pol_millis),1) ;
%         for i = 1:length(pol_millis)-1
%             v_temp(i) = abs((sgf(i+1)-sgf(i))/(pol_millis(i+1)-pol_millis(i)) * 1000000);
% %             v_temp(i) = abs((y_pol(i+1)-y_pol(i))/(pol_millis(i+1)-pol_millis(i)) * 1000000);
%         end
%         
%         v = sgolayfilt(v_temp ,order, framelen);
%       
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

        pol_dataframe = [x_pol y_pol];
        holo_data_comp = [x_holo y_holo];
        
        if end_ind < length(v)
            velocities = abs(v(start_ind:end_ind));
            avg_vel = mean(velocities);
            pol_comp = pol_dataframe(start_ind:end_ind, :);
            pol_comp_non_spline = pol_dataframe(start_ind:end, :);
%             
            
        elseif end_ind >= length(v)
            fprintf('end_ind out of length(v)')
            velocities = abs(v(start_ind:end-250));
            avg_vel = mean(velocities);
            pol_comp = pol_dataframe(start_ind:end-250, :);
            pol_comp_non_spline = pol_dataframe(start_ind:end, :);
        else
            avg_vel = 0;
            pol_comp = [0 0];
            fprintf('No avg vel data trial %i\n', trialnum)
        end
        
        % create spline!!
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));

        % removing duplicate data from y_holo
        [~, indexA, ~] = unique(y_holo);
        A = sort(indexA);
        y_holo_spline_temp = y_holo(A);
        x_holo_spline_temp = x_holo(A);
        % removing duplicate data from x_holo_spline
        [~, indexA, ~] = unique(x_holo_spline_temp);
        A = sort(indexA);
        y_holo_spline = y_holo_spline_temp(A);
        x_holo_spline = x_holo_spline_temp(A);
        
        %now create the spline
        steps_holo_spline = (x_holo_spline(length(x_holo_spline)) - x_holo_spline(1)) / sum(x_holo_spline);
        xx_holo_spline_post = x_holo_spline(1):steps_holo_spline:x_holo_spline(length(x_holo_spline));
        if length(y_holo_spline) > 1
            
            yy_holo_spline_post = spline(x_holo_spline,y_holo_spline,xx_holo_spline_post);
        
        % cut the spline data so that it perfectly matches pol_comp    
        index_holo_spline_temp = xx_holo_spline_post(:)>( pol_comp(1,1));
        spline_filtered_temp_x = xx_holo_spline_post((index_holo_spline_temp));
        spline_filtered_temp_y = yy_holo_spline_post((index_holo_spline_temp));
        index_holo_spline = spline_filtered_temp_x(:)<( pol_comp(end,1));
        xx_holo_spline_post = spline_filtered_temp_x((index_holo_spline));
        yy_holo_spline_post = spline_filtered_temp_y((index_holo_spline));
        
           
        % cut holo data 'around' the polh determined catch phase
        index_holo = holo_data_comp(:,1)>( pol_comp_non_spline(1,1));
        holo_filtered_temp = holo_data_comp((index_holo),1:2);
        diff_holo = diff(holo_filtered_temp(:,2));
        max_diff = (max(diff_holo));
        idx_diff = find(max_diff == diff_holo);
        if idx_diff + 3 < length(holo_filtered_temp)
            holo_filtered = holo_filtered_temp((1:idx_diff+3),1:2);
        else
                temp_idx_diff = max(diff_holo(diff_holo<max(diff_holo)));
                holo_filtered = holo_filtered_temp((1:temp_idx_diff+3),1:2);
        end
        
        % now need to make sure the timing is the same so cut polh data
        % around holo
        try
        pol_index = pol_comp_non_spline(:,1) > holo_filtered(1,1);
        pol_filtered_temp = pol_comp_non_spline((pol_index),1:2);
        idx_pol_end = pol_filtered_temp(:,1) < holo_filtered(end,1);
        pol_comp_non_spline = pol_filtered_temp((idx_pol_end),1:2);
        
        % bin the data
        holo_comp_length = length(holo_filtered);
        pol_comp_length_non_spline = length(pol_comp_non_spline(:,1));
        bins_raw = floor(pol_comp_length_non_spline/holo_comp_length);
        i = 0;

        % bin the holo data
        holo_repeat_bins = [];
        bool = 0;
        for n = 1:holo_comp_length
            if bool == 0
                bool = 1;
                holo_repeat_bins(n:(n)*bins_raw) = holo_filtered(n,2);
            else
                holo_repeat_bins((n-1)*bins_raw + 1:(n)*bins_raw) = holo_filtered(n,2);
            end
            if n == holo_comp_length
                holo_repeat_bins(end:pol_comp_length_non_spline) = holo_filtered(n,2);
            end
        end
        
        % calculate the onset time during catch phase when holo misses tags
        holo_diffs = diff(y_holo_spline(:));
        time_diffs = diff(x_holo_spline(:));
        result = max( holo_diffs (holo_diffs >= 0) );
        onset_time = time_diffs(find(result == holo_diffs));
        
%         comparing_diff = abs(pol_binned_data(:) - holo_filtered(:,2));
        comparing_diff = abs(pol_comp_non_spline(:,2) - holo_repeat_bins(:));
        
        if length(comparing_diff) > 0 & onset_time < 1.2
             
            rmse = sqrt((sum(comparing_diff).^2)/length(comparing_diff));
            if avg_vel < 240
            vels_cell_medium_ID_1{end+1, 1}  = pol_dynamic;
            vels_cell_medium_ID_1{end, 2} = avg_vel;
            vels_cell_medium_ID_1{end, 3} = rmse;
            vels_cell_medium_ID_1{end, 5} = pol_comp_non_spline(:,1:2);
            vels_cell_medium_ID_1{end, 6} = holo_repeat_bins(:);
                   
            
            %spline rmse work: .....>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
            spline_comp_length = length(yy_holo_spline_post);
            pol_comp_length_non_spline = length(pol_comp(:,1));
            bins = floor(spline_comp_length/pol_comp_length_non_spline);
            i = 0;
            spline_binned_data =[];

            for n = 1:pol_comp_length_non_spline
                i= i + 1;
                if i == 1
                    spline_binned_data(i) = mean(yy_holo_spline_post(1:(n)*bins));
                else
                    spline_binned_data(i) = mean(yy_holo_spline_post(bins*(n-1):(n)*bins));
                end
            end

            comparing_diff_spline = abs(pol_comp(:,2)-spline_binned_data(:) );

            rmse_spline = sqrt((sum(comparing_diff_spline).^2)/length(comparing_diff_spline));
            avg_vel_whole_trial = mean(abs(v));
            
            vels_cell_medium_ID_1{end, 4} = rmse_spline;
            vels_cell_medium_ID_1{end, 7} = pol_comp(:,2);
            vels_cell_medium_ID_1{end, 8} = spline_binned_data(:);
            vels_cell_medium_ID_1{end, 9 } = onset_time;
            vels_cell_medium_ID_1{end, 10} = avg_vel_whole_trial;
            vels_cell_medium_ID_1{end, 11} = holo_freq;
            vels_cell_medium_ID_1{end, 12} = velocities;
            
            end
%             figure(trialnum)
%             subplot(2,1,1)
% %             plot(holo_filtered(:,1) - pol_comp_non_spline(1,1), holo_filtered(:,2), 'x' )
%             plot( pol_comp_non_spline(:,1)- pol_comp_non_spline(1,1) ,holo_repeat_bins(:) )
%             hold on
%             plot(pol_comp_non_spline(:,1) - pol_comp_non_spline(1,1), pol_comp_non_spline(:,2))
%             title(['onset time: ' num2str(onset_time)], ['rmse with raw data: ' num2str(rmse)])
% %             title(['max v ' num2str(max_v)], ['start ind ' num2str(start_ind)])
%             hold off 
            if trialnum == 10
            figure(5)
            plot(x_holo_spline - x_pol(1), y_holo_spline)
            hold on
            plot(x_pol- x_pol(1), y_pol)
            hold off 
            end
% %             
%             subplot(2,1,2)
%             plot(xx_holo_spline_post-pol_comp(1,1), yy_holo_spline_post);
%             hold on
%             plot(pol_comp(:,1) - pol_comp(1,1), pol_comp(:,2))
%             title(['rmse with spline: ' num2str(rmse_spline)],['avg vel: ' num2str(avg_vel)])
% %             title(['end ind ' num2str(end_ind)],['max v ind ' num2str(max_v_ind)])
%             hold off 
 

        end
        catch me 
        end
        end
        
        catch me
        end
    
            else
        fprintf('No polhemus data for trial %i\n; medium trial \n',i)
            end
    end
    
    end
end

%% just plot
% close all;
% figure(1)
avg_vel_tot_medium = vels_cell_medium_ID_1(:,2);
rmse_tot_medium_raw = vels_cell_medium_ID_1(:,3);
rmse_tot_medium_spline = vels_cell_medium_ID_1(:,4);

% plot([avg_vel_tot_medium{:}], [rmse_tot_medium_raw{:}], 'o')
% hold on
% plot([avg_vel_tot_medium{:}], [rmse_tot_medium_spline{:}], 'X')
% hold off
% xlabel('Velocity (rad/s)')
% ylabel('RMSE error')
% legend('Raw data', 'Spline data')

%%
% close all;
% figure(2)
time_onset_medium = vels_cell_medium_ID_1(:,9);
rmse_tot_medium_raw = vels_cell_medium_ID_1(:,3);
rmse_tot_medium_spline = vels_cell_medium_ID_1(:,4);

% plot([time_onset_medium{:}], [rmse_tot_medium_raw{:}], 'o')
% hold on
% plot([time_onset_medium{:}], [rmse_tot_medium_spline{:}], 'X')
% hold off
% xlabel('Time onset (s)')
% ylabel('RMSE error')
% legend('Raw data', 'Spline data')

%% fast
namesFast = fieldnames( fast_filteredStruct );
subStrPol = '_POLGroundTruth';
Pol_filteredStruct = rmfield( fast_filteredStruct, namesFast(find(cellfun(@isempty, strfind( namesFast, subStrPol)))));
Polh_Fields = fieldnames(Pol_filteredStruct);
subStrHolo = '_HoloData';
Holo_filteredStruct_fast = rmfield( fast_filteredStruct, namesFast(find(cellfun(@isempty, strfind( namesFast, subStrHolo)))));
Holo_Fields = fieldnames(Holo_filteredStruct_fast);

%% edit ID number here !! and everywhere
% close all;
vels_cell_fast_ID_1 = cell(0, 12);
integer = 0;
for trialnum = 1:length(Polh_Fields) 
%     for trialnum = 4
       

    pol_dynamic = [string(Polh_Fields(trialnum + integer))]; 
    
    if trialnum < length(Holo_Fields)
        
    holo_dynamic = [string(Holo_Fields(trialnum))];
    newStr = erase(pol_dynamic,'_POLGroundTruth');
    newSubstr = erase(holo_dynamic, '_HoloData');
    
    if newStr ~= newSubstr
        integer = integer+1;
        
    elseif newStr == newSubstr

    if isfield(experiment_data,pol_dynamic) == 1
        Pol_data = experiment_data.(pol_dynamic);
        Holo_data = experiment_data.(holo_dynamic);

    
        try
        x_pol = seconds(Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
%         pol_millis = Pol_data.Milliseconds;
        t = (Pol_data{:,1});

        dt = diff(t);
        v = (lowpass(diff(y_pol)./seconds(dt), 5, 1/mean(seconds(dt))));
        
        
        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp) - lag_term_fast;
        seconds_diff = diff(seconds(Holo_data.Timestamp));
        holo_freq = 1/(sum(seconds_diff)/ length(seconds_diff));
     
        y_holo = Holo_data.Angle + calibration_term_fast;

        
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+100);
        y_pol(more_rowsToDelete) = [];
        x_pol(more_rowsToDelete) = [];
        y_pol(rowsToDelete) = [];
        x_pol(rowsToDelete) = []; 

        
        %%% added for presentation 
       
%         order = 3;
%         framelen = 93;
% 
%         y_pol = sgolayfilt(y_pol,order,framelen);
%         
%         v_temp = zeros(length(pol_millis),1) ;
%         for i = 1:length(pol_millis)-1
%             v_temp(i) = abs((y_pol(i+1)-y_pol(i))/(pol_millis(i+1)-pol_millis(i)) * 1000000);
% %             v(i) = abs((y_pol(i+1)-y_pol(i))/(pol_millis(i+1)-pol_millis(i)) * 1000000);
%         end
%         
%         v = sgolayfilt(v_temp ,order, framelen);

        
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

        pol_dataframe = [x_pol y_pol];
        holo_data_comp = [x_holo y_holo];
        
        if end_ind < length(v)
            velocities = abs(v(start_ind:end_ind));
            avg_vel = mean(velocities);
            pol_comp = pol_dataframe(start_ind:end_ind, :);
            pol_comp_non_spline = pol_dataframe(start_ind:end, :);
%             
            
        elseif end_ind >= length(v)
            fprintf('end_ind out of length(v)')
            velocities = abs(v(start_ind:end-250));
            avg_vel = mean(velocities);
            pol_comp = pol_dataframe(start_ind:end-250, :);
            pol_comp_non_spline = pol_dataframe(start_ind:end, :);
        else
            avg_vel = 0;
            pol_comp = [0 0];
            fprintf('No avg vel data trial %i\n', trialnum)
        end
        
        % create spline!!
        steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
        xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));

        % removing duplicate data from y_holo
        [~, indexA, ~] = unique(y_holo);
        A = sort(indexA);
        y_holo_spline_temp = y_holo(A);
        x_holo_spline_temp = x_holo(A);
        % removing duplicate data from x_holo_spline
        [~, indexA, ~] = unique(x_holo_spline_temp);
        A = sort(indexA);
        y_holo_spline = y_holo_spline_temp(A);
        x_holo_spline = x_holo_spline_temp(A);
        
        %now create the spline
        steps_holo_spline = (x_holo_spline(length(x_holo_spline)) - x_holo_spline(1)) / sum(x_holo_spline);
        xx_holo_spline_post = x_holo_spline(1):steps_holo_spline:x_holo_spline(length(x_holo_spline));
        if length(y_holo_spline) > 1
            
            yy_holo_spline_post = spline(x_holo_spline,y_holo_spline,xx_holo_spline_post);
        
        % cut the spline data so that it perfectly matches pol_comp    
        index_holo_spline_temp = xx_holo_spline_post(:)>( pol_comp(1,1));
        spline_filtered_temp_x = xx_holo_spline_post((index_holo_spline_temp));
        spline_filtered_temp_y = yy_holo_spline_post((index_holo_spline_temp));
        index_holo_spline = spline_filtered_temp_x(:)<( pol_comp(end,1));
        xx_holo_spline_post = spline_filtered_temp_x((index_holo_spline));
        yy_holo_spline_post = spline_filtered_temp_y((index_holo_spline));
        
           
        % cut holo data 'around' the polh determined catch phase
        index_holo = holo_data_comp(:,1)>( pol_comp_non_spline(1,1));
        holo_filtered_temp = holo_data_comp((index_holo),1:2);
        diff_holo = diff(holo_filtered_temp(:,2));
        max_diff = (max(diff_holo));
        idx_diff = find(max_diff == diff_holo);
        holo_filtered = holo_filtered_temp((1:idx_diff+3),1:2);
        
        % now need to make sure the timing is the same so cut polh data
        % around holo
        pol_index = pol_comp_non_spline(:,1) > holo_filtered(1,1);
        pol_filtered_temp = pol_comp_non_spline((pol_index),1:2);
        idx_pol_end = pol_filtered_temp(:,1) < holo_filtered(end,1);
        pol_comp_non_spline = pol_filtered_temp((idx_pol_end),1:2);
        
        % bin the data
        holo_comp_length = length(holo_filtered);
        pol_comp_length_non_spline = length(pol_comp_non_spline(:,1));
        bins_raw = floor(pol_comp_length_non_spline/holo_comp_length);
        i = 0;

        % bin the holo data
        holo_repeat_bins = [];
        bool = 0;
        for n = 1:holo_comp_length
            if bool == 0
                bool = 1;
                holo_repeat_bins(n:(n)*bins_raw) = holo_filtered(n,2);
            else
                holo_repeat_bins((n-1)*bins_raw + 1:(n)*bins_raw) = holo_filtered(n,2);
            end
            if n == holo_comp_length
                holo_repeat_bins(end:pol_comp_length_non_spline) = holo_filtered(n,2);
            end
        end
        
        % calculate the onset time during catch phase when holo misses tags
        holo_diffs = diff(y_holo_spline(:));
        time_diffs = diff(x_holo_spline(:));
        result = max( holo_diffs (holo_diffs >= 0) );
        onset_time = time_diffs(find(result == holo_diffs));
        
%         comparing_diff = abs(pol_binned_data(:) - holo_filtered(:,2));
        comparing_diff = abs(pol_comp_non_spline(:,2) - holo_repeat_bins(:));
        
        if length(comparing_diff) > 0 & onset_time < 1.2
             
            rmse = sqrt((sum(comparing_diff).^2)/length(comparing_diff));
            spline_comp_length = length(yy_holo_spline_post);
            if spline_comp_length > 0
            if avg_vel < 240
            vels_cell_fast_ID_1{end+1, 1}  = pol_dynamic;
            vels_cell_fast_ID_1{end, 2} = avg_vel;
            vels_cell_fast_ID_1{end, 3} = rmse;
            vels_cell_fast_ID_1{end, 5} = pol_comp_non_spline(:,1:2);
            vels_cell_fast_ID_1{end, 6} = holo_repeat_bins(:);
                   
            
            %spline rmse work: .....>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
            
            pol_comp_length_non_spline = length(pol_comp(:,1));
            bins = floor(spline_comp_length/pol_comp_length_non_spline);
            i = 0;
            spline_binned_data =[];

            for n = 1:pol_comp_length_non_spline
                i= i + 1;
                if i == 1
                    spline_binned_data(i) = mean(yy_holo_spline_post(1:(n)*bins));
                else
                    spline_binned_data(i) = mean(yy_holo_spline_post(bins*(n-1):(n)*bins));
                end
            end

            comparing_diff_spline = abs(pol_comp(:,2)-spline_binned_data(:) );

            rmse_spline = sqrt((sum(comparing_diff_spline).^2)/length(comparing_diff_spline));
            avg_vel_whole_trial = mean(abs(v));
            
            vels_cell_fast_ID_1{end, 4} = rmse_spline;
            vels_cell_fast_ID_1{end, 7} = pol_comp(:,2);
            vels_cell_fast_ID_1{end, 8} = spline_binned_data(:);
            vels_cell_fast_ID_1{end, 9 } = onset_time;
            vels_cell_fast_ID_1{end, 10} = avg_vel_whole_trial;
            vels_cell_fast_ID_1{end, 11} = holo_freq;
            vels_cell_fast_ID_1{end, 12} = velocities;
            
            end
%             figure(trialnum)
%             subplot(2,1,1)
% %             plot(holo_filtered(:,1) - pol_comp_non_spline(1,1), holo_filtered(:,2), 'x' )
%             plot( pol_comp_non_spline(:,1)- pol_comp_non_spline(1,1) ,holo_repeat_bins(:) )
%             hold on
%             plot(pol_comp_non_spline(:,1) - pol_comp_non_spline(1,1), pol_comp_non_spline(:,2))
%             title(['onset time: ' num2str(onset_time)], ['rmse with raw data: ' num2str(rmse)])
% %             title(['max v ' num2str(max_v)], ['start ind ' num2str(start_ind)])
%             hold off 
            if trialnum == 10
            figure(6)
            plot(x_holo_spline - x_pol(1), y_holo_spline)
            hold on
            plot(x_pol- x_pol(1), y_pol)
            hold off 
            end
% %             
%             subplot(2,1,2)
%             plot(xx_holo_spline_post-pol_comp(1,1), yy_holo_spline_post);
%             hold on
%             plot(pol_comp(:,1) - pol_comp(1,1), pol_comp(:,2))
%             title(['rmse with spline: ' num2str(rmse_spline)],['avg vel: ' num2str(avg_vel)])
% %             title(['end ind ' num2str(end_ind)],['max v ind ' num2str(max_v_ind)])
%             hold off 
            
        end
        end
        end
        catch me
        end
    
            else
        fprintf('No polhemus data for trial %i\n; fast trial \n',i)
            end
    end
    
    
    end
end


%% just plot
% close all;
% figure(1)
avg_vel_tot_fast = vels_cell_fast_ID_1(:,2);
rmse_tot_fast_raw = vels_cell_fast_ID_1(:,3);
rmse_tot_fast_spline = vels_cell_fast_ID_1(:,4);
% 
% plot([avg_vel_tot_fast{:}], [rmse_tot_fast_raw{:}], 'o')
% hold on
% plot([avg_vel_tot_fast{:}], [rmse_tot_fast_spline{:}], 'X')
% hold off
% xlabel('Velocity (rad/s)')
% ylabel('RMSE error')
% legend('Raw data', 'Spline data')

%%
% close all;
% figure(2)
time_onset_fast = vels_cell_fast_ID_1(:,9);
rmse_tot_fast_raw = vels_cell_fast_ID_1(:,3);
rmse_tot_fast_spline = vels_cell_fast_ID_1(:,4);

% plot([time_onset_fast{:}], [rmse_tot_fast_raw{:}], 'o')
% hold on
% plot([time_onset_fast{:}], [rmse_tot_fast_spline{:}], 'X')
% hold off
% xlabel('Time onset (s)')
% ylabel('RMSE error')
% legend('Raw data', 'Spline data')
% 

%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%% plot all
fname = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data\Data_MATLAB\VelocityErrorData\Plots\IDPlots';
% close all;
FigH = figure('Position', get(0, 'Screensize'));
x = [[avg_vel_tot_slow{:}] [avg_vel_tot_medium{:}] [avg_vel_tot_fast{:}]]';
y_raw = [[rmse_tot_slow_raw{:}] [rmse_tot_medium_raw{:}] [rmse_tot_fast_raw{:}]]';
y_spline = [[rmse_tot_slow_spline{:}] [rmse_tot_medium_spline{:}] [rmse_tot_fast_spline{:}]]';

% bls_raw = regress(y_raw,[ones(length(x),1) x]);
% bls_spline = regress(y_spline,[ones(length(x),1) x]);

[brob_raw,stats_raw] = robustfit(x,y_raw);
[brob_spline,stats_spline] = robustfit(x,y_spline);

outliers_ind_raw = find(abs(stats_raw.resid)>stats_raw.mad_s);
outliers_ind_spline = find(abs(stats_spline.resid)>stats_spline.mad_s);

leg_vel_raw = plot(x,y_raw,'s','color','red');
hold on 
outliers_raw = scatter(x(outliers_ind_raw),y_raw(outliers_ind_raw),[],'r','filled','s');
hold on
leg_raw_LR = plot(x,brob_raw(1)+brob_raw(2)*x,'r');
hold on

leg_vel_spline = plot(x,y_spline,'o','color','b');
hold on 
outliers_spline = scatter(x(outliers_ind_spline),y_spline(outliers_ind_spline),'filled','b');
hold on
leg_spline_LR = plot(x,brob_spline(1)+brob_spline(2)*x,'b');
hold on

% leg_vel_raw = plot([avg_vel_tot_slow{:}], [rmse_tot_slow_raw{:}], 'ko','color', 'red');
% hold on
% plot([avg_vel_tot_medium{:}], [rmse_tot_medium_raw{:}], 'ko','color','red');
% hold on
% plot([avg_vel_tot_fast{:}], [rmse_tot_fast_raw{:}], 'ko','color','red');
% hold on
% leg_raw_LR = plot(x,bls_raw(1)+bls_raw(2)*x,'r');
% hold on

% leg_vel_spline = plot([avg_vel_tot_slow{:}], [rmse_tot_slow_spline{:}], 'X','color', 'b');
% hold on
% plot([avg_vel_tot_medium{:}], [rmse_tot_medium_spline{:}], 'X','color','b');
% hold on
% plot([avg_vel_tot_fast{:}], [rmse_tot_fast_spline{:}], 'X','color','b');
% hold on
% leg_spline_LR = plot(x,bls_spline(1)+bls_spline(2)*x,'b');

hold off
clear ylim xlim
% y_top = max(y_spline)+250;
% x_top = max(x)+ 20;
% ylim([0 600])
% xlim([20 180])
yticks([0:100:1000])
legend([leg_vel_raw,outliers_raw, leg_raw_LR, leg_vel_spline, outliers_spline, leg_spline_LR], {'Raw data','Raw outliers'...
    'Raw robust linear model', 'Spline data','Spline outliers','Spline robust linear model'},'FontSize', 20,'Location', 'northwest');
xlim=get(gca,'XLim');
ylim=get(gca,'YLim');
if brob_raw(2) > 0 & brob_spline(2) > 0
    text(0.98*xlim(1)+0.02*xlim(2),0.28*ylim(1)+0.62*ylim(2),['y = ' num2str(brob_raw(1)) '+' num2str(brob_raw(2)) 'x'],'Color', 'r', 'FontSize', 20)
    text(0.98*xlim(1)+0.02*xlim(2),0.38*ylim(1)+0.52*ylim(2),['y = ' num2str(brob_spline(1)) '+' num2str(brob_spline(2)) 'x'],'Color', 'b', 'FontSize', 20)
elseif brob_raw(2) > 0 & brob_spline(2) < 0 
    text(0.98*xlim(1)+0.02*xlim(2),0.28*ylim(1)+0.62*ylim(2),['y = ' num2str(brob_raw(1)) '+' num2str(brob_raw(2)) 'x'],'Color', 'r', 'FontSize', 20)
    text(0.98*xlim(1)+0.02*xlim(2),0.38*ylim(1)+0.52*ylim(2),['y = ' num2str(brob_spline(1)) num2str(brob_spline(2)) 'x'],'Color', 'b', 'FontSize', 20)
elseif brob_raw(2) < 0 & brob_spline(2) > 0 
    text(0.98*xlim(1)+0.02*xlim(2),0.28*ylim(1)+0.62*ylim(2),['y = ' num2str(brob_raw(1)) num2str(brob_raw(2)) 'x'],'Color', 'r', 'FontSize', 20)
    text(0.98*xlim(1)+0.02*xlim(2),0.38*ylim(1)+0.52*ylim(2),['y = ' num2str(brob_spline(1)) '+' num2str(brob_spline(2)) 'x'],'Color', 'b', 'FontSize', 20)
else
    text(0.98*xlim(1)+0.02*xlim(2),0.28*ylim(1)+0.62*ylim(2),['y = ' num2str(brob_raw(1)) num2str(brob_raw(2)) 'x'],'Color', 'r', 'FontSize', 20)
    text(0.98*xlim(1)+0.02*xlim(2),0.38*ylim(1)+0.52*ylim(2),['y = ' num2str(brob_spline(1)) num2str(brob_spline(2)) 'x'],'Color', 'b', 'FontSize', 20)
end
    title(['Velocity against RMSE between Polhemus and Hololens angle readings for participant 1'],'FontSize', 18)
xlabel('Velocity (deg/s)','FontSize', 18)
ylabel('RMSE', 'FontSize', 18)
hold on


mkdir 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data\Data_MATLAB\VelocityErrorData\Plots\IDPlots'  '\ID1'
filename = ['ID' num2str(ID) '\VelErrorID' num2str(ID)];
% filename = ['\VelErrorID' num2str(ID)];
saveas(FigH, fullfile(fname, filename), 'fig');

%%
% close all;
FigHRaw = figure('Position', get(0, 'Screensize'));

x_time_onset = [[time_onset_slow{:}] [time_onset_medium{:}] [time_onset_fast{:}]]';

% bls_raw_onset = regress(y_raw,[ones(length(x_time_onset),1) x_time_onset]);
% bls_spline_onset = regress(y_spline,[ones(length(x_time_onset),1) x_time_onset]);

[brob_raw_onset,stats_raw_onset] = robustfit(x_time_onset,y_raw);
[brob_spline_onset,stats_spline_onset] = robustfit(x_time_onset,y_spline);

outliers_ind_raw_onset = find(abs(stats_raw_onset.resid)>stats_raw_onset.mad_s);
outliers_ind_spline_onset = find(abs(stats_spline_onset.resid)>stats_spline_onset.mad_s);

leg_vel_raw_onset = plot(x_time_onset,y_raw,'s','color','red');
hold on 
outliers_raw_onset = scatter(x_time_onset(outliers_ind_raw_onset),y_raw(outliers_ind_raw_onset),[],'r','filled','s');
hold on
leg_raw_LR_onset = plot(x_time_onset,brob_raw_onset(1)+brob_raw_onset(2)*x_time_onset,'r');
hold on

leg_vel_spline_onset = plot(x_time_onset,y_spline,'o','color','b');
hold on 
outliers_spline_onset = scatter(x_time_onset(outliers_ind_spline_onset),y_spline(outliers_ind_spline_onset),'filled','b');
hold on
leg_spline_LR_onset = plot(x_time_onset,brob_spline_onset(1)+brob_spline_onset(2)*x_time_onset,'b');
hold on

% 
% leg_onset_raw = plot([time_onset_slow{:}], [rmse_tot_slow_raw{:}], 'o', 'color','r');
% hold on
% plot([time_onset_medium{:}], [rmse_tot_medium_raw{:}], 'o', 'color','r');
% hold on
% plot([time_onset_fast{:}], [rmse_tot_fast_raw{:}], 'o', 'color','r');
% hold on
% leg_raw_LR_onset = plot(x_time_onset,bls_raw_onset(1)+bls_raw_onset(2)*x_time_onset,'r');
% hold on
% 
% leg_onset_spline = plot([time_onset_slow{:}], [rmse_tot_slow_spline{:}], 'x', 'color','b');
% hold on
% plot([time_onset_medium{:}], [rmse_tot_medium_spline{:}], 'x', 'color','b');
% hold on
% plot([time_onset_fast{:}], [rmse_tot_fast_spline{:}], 'x', 'color','b');
% hold on
% leg_spline_LR_onset = plot(x_time_onset,bls_spline_onset(1)+bls_spline_onset(2)*x_time_onset,'b');

hold off
clear ylim xlim
% y_top = max(y_spline)+250;
ylim([0 600])
xlim([0 1.2])
yticks([0:100:1000])
legend([leg_vel_raw_onset,outliers_raw_onset, leg_raw_LR_onset, leg_vel_spline_onset, outliers_spline_onset, leg_spline_LR_onset], {'Raw data','Raw outliers'...
    'Raw robust linear model', 'Spline data','Spline outliers','Spline robust linear model'},'FontSize', 20,'Location', 'northwest')
xlim=get(gca,'XLim');
ylim=get(gca,'YLim');
if brob_raw_onset(2) > 0 & brob_spline_onset(2) > 0
    text(0.98*xlim(1)+0.02*xlim(2),0.28*ylim(1)+0.62*ylim(2),['y = ' num2str(brob_raw_onset(1)) '+' num2str(brob_raw_onset(2)) 'x'],'Color', 'r', 'FontSize', 20)
    text(0.98*xlim(1)+0.02*xlim(2),0.38*ylim(1)+0.52*ylim(2),['y = ' num2str(brob_spline_onset(1)) '+' num2str(brob_spline_onset(2)) 'x'],'Color', 'b', 'FontSize', 20)
elseif brob_raw_onset(2) > 0 & brob_spline_onset(2) < 0 
    text(0.98*xlim(1)+0.02*xlim(2),0.28*ylim(1)+0.62*ylim(2),['y = ' num2str(brob_raw_onset(1)) '+' num2str(brob_raw_onset(2)) 'x'],'Color', 'r', 'FontSize', 20)
    text(0.98*xlim(1)+0.02*xlim(2),0.38*ylim(1)+0.52*ylim(2),['y = ' num2str(brob_spline_onset(1)) num2str(brob_spline_onset(2)) 'x'],'Color', 'b', 'FontSize', 20)
elseif brob_raw_onset(2) < 0 & brob_spline_onset(2) > 0 
    text(0.98*xlim(1)+0.02*xlim(2),0.28*ylim(1)+0.62*ylim(2),['y = ' num2str(brob_raw_onset(1)) num2str(brob_raw_onset(2)) 'x'],'Color', 'r', 'FontSize', 20)
    text(0.98*xlim(1)+0.02*xlim(2),0.38*ylim(1)+0.52*ylim(2),['y = ' num2str(brob_spline_onset(1)) '+' num2str(brob_spline_onset(2)) 'x'],'Color', 'b', 'FontSize', 20)
else
    text(0.98*xlim(1)+0.02*xlim(2),0.28*ylim(1)+0.62*ylim(2),['y = ' num2str(brob_raw_onset(1)) num2str(brob_raw_onset(2)) 'x'],'Color', 'r', 'FontSize', 20)
    text(0.98*xlim(1)+0.02*xlim(2),0.38*ylim(1)+0.52*ylim(2),['y = ' num2str(brob_spline_onset(1)) num2str(brob_spline_onset(2)) 'x'],'Color', 'b', 'FontSize', 20)
end

title('Time onset against RMSE between Polhemus and Hololens angle recordings for participant 1', 'FontSize', 18)
xlabel('Time onset (s)', 'FontSize',18)
ylabel('RMSE', 'FontSize', 18)


filename = ['ID' num2str(ID) '\TimeOnsetErrorID' num2str(ID)];
% filename = ['\TimeOnsetErrorID' num2str(ID)];
saveas(FigHRaw, fullfile(fname, filename), 'fig');


%%
% FigHFastTraj = figure('Position', get(0, 'Screensize'));
% 
% length_fast = length(vels_cell_fast_ID_9{1, 7});
% % length_medium = length(vels_cell_medium_ID_9{1, 7});
% 
% angle_pol_fast = reshape(cell2mat(vels_cell_fast_ID_9(:,7)), [length_fast,length(vels_cell_fast_ID_9)]);
% angle_holo_fast = reshape(cell2mat(vels_cell_fast_ID_9(:,8)), [length_fast,length(vels_cell_fast_ID_9)]);
% angular_velocity_fast = reshape(cell2mat(vels_cell_fast_ID_9(:,12)), [length_fast,length(vels_cell_fast_ID_9)]);
% 
% % angle_pol_medium = reshape(cell2mat(vels_cell_medium_ID_9(:,7)), [length_medium,length(vels_cell_medium_ID_9)]);
% % angle_holo_medium = reshape(cell2mat(vels_cell_medium_ID_9(:,8)), [length_medium, length(vels_cell_medium_ID_9)]);
% % angular_velocity_medium = reshape(cell2mat(vels_cell_medium_ID_9(:,12)), [length_medium, length(vels_cell_medium_ID_9)]);
% 
% % angle_pol_slow = reshape(cell2mat(vels_cell_slow_ID_9(:,7)), [91,28]);
% % angle_holo_slow = reshape(cell2mat(vels_cell_slow_ID_9(:,8)), [91,28]);
% % angular_velocity = reshape(cell2mat(vels_cell_slow_ID_9(:,12)), [91,28]);
% % surf(angle_pol_fast,angle_holo_fast,angular_velocity)
% plot3(angle_pol_fast,angle_holo_fast,angular_velocity_fast);
% % plot3(angle_pol_medium,angle_holo_medium,angular_velocity);
% xlabel('Angle Polhemus (deg)')
% ylabel('Angle Hololens (deg)')
% zlabel('Angular velocity (deg/s)')
% 
% filename = ['ID' num2str(ID) '\FastTraj' num2str(ID)];
% % filename = ['\VelErrorID' num2str(ID)];
% saveas(FigHFastTraj, fullfile(fname, filename), 'fig');


%%
slow_ID_1 = 'VelSlow_ID_1';
medium_ID_1 = 'VelMedium_ID_1';
fast_ID_1 = 'VelFast_ID_1';
VelErrorData1.(slow_ID_1) = cell2table(vels_cell_slow_ID_1);
VelErrorData1.(medium_ID_1) = cell2table(vels_cell_medium_ID_1) ;
VelErrorData1.(fast_ID_1) = cell2table(vels_cell_fast_ID_1);
foldersave = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data\Data_MATLAB\VelocityErrorData';
filesave = 'VelErrorData1';
save(fullfile(foldersave, filesave), 'VelErrorData1')

