clc; close all;
clear all;
%% Input the ID of data you want to analyse here. The .mat file will then be auto-loaded.

chk = exist('Nodes','var');
if ~chk
     
    ID = 8;
    ID = num2str(ID);
    ID_folder = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data_MATLAB\UnprocessedData';
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
calibration_term = 8;
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

% 
%% slow

namesSlow = fieldnames( slow_filteredStruct );
subStrPol = '_POLGroundTruth';
Pol_filteredStruct = rmfield( slow_filteredStruct, namesSlow(find(cellfun(@isempty, strfind( namesSlow, subStrPol)))));

Polh_Fields = fieldnames(Pol_filteredStruct);
subStrHolo = '_HoloData';
Holo_filteredStruct = rmfield( slow_filteredStruct, namesSlow(find(cellfun(@isempty, strfind( namesSlow, subStrHolo)))));
Holo_Fields = fieldnames(Holo_filteredStruct);


vels_cell_slow_ID_10 = cell(length(Polh_Fields), 3);
integer = 0;
for trialnum = 1:length(Polh_Fields)-1
% for trialnum = 2
   pol_dynamic = [string(Polh_Fields(trialnum + 1))] ;
    
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
        pol_millis = Pol_data.Milliseconds;
        
        
        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        x_holo_no_lag = x_holo - 0.2;
        y_holo = Holo_data.Angle + calibration_term;

        
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+1000);
        y_pol(more_rowsToDelete) = [];
        x_pol(more_rowsToDelete) = [];
        y_pol(rowsToDelete) = [];
        x_pol(rowsToDelete) = []; 
        pol_millis(more_rowsToDelete) = [];
        pol_millis(rowsToDelete) = [];
        
        order = 3;
        framelen = 93;

        sgf = sgolayfilt(y_pol,order,framelen);
        
        v = zeros(length(pol_millis),1) ;
        for i = 1:length(pol_millis)-1
            v(i) = abs((sgf(i+1)-sgf(i))/(pol_millis(i+1)-pol_millis(i)) * 1000000);
        end
        
        length_v_half = round(length(v)/2);
        
        max_inst_vel = find(v==max(v(length_v_half:end)));
        start_ind = max_inst_vel - 100;
        end_ind = max_inst_vel + 370;
        pol_dataframe = [x_pol sgf];
        holo_data_comp = [x_holo_no_lag y_holo];
        
        if end_ind < length(v)
            avg_vel = mean(v(start_ind:end_ind));
            pol_comp = pol_dataframe(start_ind:end_ind, :);
            
            
        elseif end_ind > length(v)
            avg_vel = mean(v(start_ind:end));
            pol_comp = pol_dataframe(end-470:end, :);
        else
            avg_vel = 0;
            pol_comp = [0 0];
            fprintf('No avg vel data trial %i\n', trialnum)
        end
        
        index_holo = holo_data_comp(:,1)>pol_comp(1,1);
        holo_filtered_temp = holo_data_comp(index_holo,1:2);
        index_temp_holo = holo_filtered_temp(:,1)<pol_comp(end,1);
        holo_filtered = holo_filtered_temp(index_temp_holo ,1:2);
        
        holo_comp_length = length(holo_filtered);
        pol_comp_length = length(pol_comp(:,1));
        bins = floor(pol_comp_length/holo_comp_length);
        i = 0;
        pol_binned_data =[];
        
        for n = 1:holo_comp_length
            i= i + 1;
            if i == 1
                pol_binned_data(i) = mean(pol_comp(1:(n)*bins,2));
            else
                pol_binned_data(i) = mean(pol_comp(bins*(n-1):(n)*bins,2));
            end
        end
        

        comparing_diff = abs(pol_binned_data(:) - holo_filtered(:,2));
        if length(comparing_diff)>0
            rmse = sqrt((sum(comparing_diff).^2)/(length(comparing_diff)));
            if rmse > 80
                pol_dynamic = 0;
                avg_vel = 0;
                rmse = 0;
            end
        else 
                pol_dynamic = 0;
                avg_vel = 0;
                rmse = 0;
        end
        
        vels_cell_slow_ID_10{trialnum, 1}  = pol_dynamic;
        vels_cell_slow_ID_10{trialnum,2} = avg_vel;
        vels_cell_slow_ID_10{trialnum,3} = rmse;
        cathch me
        fprintf('no data')
        end
%         figure(trialnum)
%         plot(holo_filtered(:,1), holo_filtered(:,2) )
%         hold on
%         plot(pol_comp(:,1), pol_comp(:,2))
%         hold off 
        
        end
    end
    else
        fprintf('No polhemus data for trial %i\n; slow trial \n',trialnum)
        end
        
end
%% just plot
figure(1)
avg_vel_tot_slow = vels_cell_slow_ID_10(:,2);
rmse_tot_slow = vels_cell_slow_ID_10(:,3);
avg_vel_tot_slow = avg_vel_tot_slow(all(cell2mat(avg_vel_tot_slow) ~= 0,2),:);
rmse_tot_slow = rmse_tot_slow(all(cell2mat(rmse_tot_slow) ~= 0,2),:);


plot([avg_vel_tot_slow{:}], [rmse_tot_slow{:}], 'o')
xlabel('Velocity (rad/s)')
ylabel('RMSE error')
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
vels_cell_medium_ID_10 = cell(length(Polh_Fields), 3);
integer = 0;
for trialnum = 1:length(Polh_Fields)-1
    
% for trialnum = 2
    pol_dynamic = [string(Polh_Fields(trialnum + 1 +integer))]; 
    
    if trialnum < length(Holo_Fields)
        
    holo_dynamic = [string(Holo_Fields(trialnum))];
    newStr = erase(pol_dynamic,'_POLGroundTruth');
    newSubstr = erase(holo_dynamic, '_HoloData');
    
    if newStr ~= newSubstr
        integer = integer+1;
%         pol_dynamic
%         holo_dynamic
        
    elseif newStr == newSubstr

        if isfield(experiment_data,pol_dynamic) == 1
            Pol_data = experiment_data.(pol_dynamic);
            Holo_data = experiment_data.(holo_dynamic);
            
        try
        x_pol = seconds(Pol_data.Timestamp);
        y_pol = Pol_data.Angle;
        pol_millis = Pol_data.Milliseconds;
        
        
        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        x_holo_no_lag = x_holo - 0.2;
        y_holo = Holo_data.Angle + calibration_term;

        
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+1000);
        y_pol(more_rowsToDelete) = [];
        x_pol(more_rowsToDelete) = [];
        y_pol(rowsToDelete) = [];
        x_pol(rowsToDelete) = []; 
        pol_millis(more_rowsToDelete) = [];
        pol_millis(rowsToDelete) = [];
        
        order = 3;
        framelen = 93;

        sgf = sgolayfilt(y_pol,order,framelen);
        
        v = zeros(length(pol_millis),1) ;
        for i = 1:length(pol_millis)-1
            v(i) = abs((sgf(i+1)-sgf(i))/(pol_millis(i+1)-pol_millis(i)) * 1000000);
        end
        
        length_v_half = round(length(v)/2);
        
        max_inst_vel = find(v==max(v(length_v_half:end)));
        start_ind = max_inst_vel - 70;
        end_ind = max_inst_vel + 150;
        pol_dataframe = [x_pol sgf];
        holo_data_comp = [x_holo_no_lag y_holo];
        
        if end_ind < length(v)
            avg_vel = mean(v(start_ind:end_ind));
            pol_comp = pol_dataframe(start_ind:end_ind, :);
            
            
        elseif end_ind > length(v)
            avg_vel = mean(v(start_ind:end));
            pol_comp = pol_dataframe(end-220:end, :);
        else
            avg_vel = 0;
            pol_comp = [0 0];
            fprintf('No avg vel data trial %i\n', trialnum)
        end
            
        
        index_holo = holo_data_comp(:,1)> (pol_comp(1,1) - 0.05);
        holo_filtered_temp = holo_data_comp(index_holo,1:2);
        index_temp_holo = holo_filtered_temp(:,1)< (pol_comp(end,1) + 0.05);
        holo_filtered = holo_filtered_temp(index_temp_holo,1:2);
        
        holo_comp_length = length(holo_filtered);
        pol_comp_length = length(pol_comp(:,1));
        bins = floor(pol_comp_length/holo_comp_length);
        i = 0;
        pol_binned_data =[];
        
        for n = 1:holo_comp_length
            i= i + 1;
            if i == 1
                pol_binned_data(i) = mean(pol_comp(1:(n)*bins,2));
            else
                pol_binned_data(i) = mean(pol_comp(bins*(n-1):(n)*bins,2));
            end
        end
        

        comparing_diff = abs(pol_binned_data(:) - holo_filtered(:,2));
        if length(comparing_diff)>0
            rmse = sqrt((sum(comparing_diff).^2)/length(comparing_diff));
             if rmse > 80
                pol_dynamic = 0;
                avg_vel = 0;
                rmse = 0;
            end
        else
            
                pol_dynamic = 0;
                avg_vel = 0;
                rmse = 0;
        end
       
        
        vels_cell_medium_ID_10{trialnum, 1}  = pol_dynamic;
        vels_cell_medium_ID_10{trialnum,2} = avg_vel;
        vels_cell_medium_ID_10{trialnum,3} = rmse;
        
%         figure(trialnum)
%         plot(holo_filtered(:,1), holo_filtered(:,2) )
%         hold on
%         plot(pol_comp(:,1), pol_comp(:,2))
%         hold off 
        catch me
            fprintf('no data')
        end
    else
        fprintf('No polhemus data for trial %i\n; slow trial \n',i)
        end
    end
    else 
        break
    end
    
    
end

%% just plot
figure(1)
avg_vel_tot_medium = vels_cell_medium_ID_10(:,2);
rmse_tot_medium = vels_cell_medium_ID_10(:,3);
avg_vel_tot_medium = avg_vel_tot_medium(all(cell2mat(avg_vel_tot_medium) ~= 0,2),:);
rmse_tot_medium = rmse_tot_medium(all(cell2mat(rmse_tot_medium) ~= 0,2),:);

plot([avg_vel_tot_medium{:}], [rmse_tot_medium{:}], 'o')
xlabel('Velocity (rad/s)')
ylabel('RMSE error')

%% fast
namesFast = fieldnames( fast_filteredStruct );
subStrPol = '_POLGroundTruth';
Pol_filteredStruct = rmfield( fast_filteredStruct, namesFast(find(cellfun(@isempty, strfind( namesFast, subStrPol)))));
Polh_Fields = fieldnames(Pol_filteredStruct);
subStrHolo = '_HoloData';
Holo_filteredStruct_fast = rmfield( fast_filteredStruct, namesFast(find(cellfun(@isempty, strfind( namesFast, subStrHolo)))));
Holo_Fields = fieldnames(Holo_filteredStruct_fast);

%% edit ID number here !! and everywhere
vels_cell_fast_ID_10 = cell(length(Polh_Fields), 3);
integer = 0;
for trialnum = 1:length(Polh_Fields)
    
    pol_dynamic = [string(Polh_Fields(trialnum ))] ;
    
    if trialnum < length(Holo_Fields)
        
    holo_dynamic = [string(Holo_Fields(trialnum+integer))];
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
        pol_millis = Pol_data.Milliseconds;
        
        
        % % plot holo data with points and a spline overlaid
        x_holo = seconds(Holo_data.Timestamp);
        x_holo_no_lag = x_holo - 0.2;
        y_holo = Holo_data.Angle + calibration_term;

        
        rowsToDelete = y_pol < 0 | y_pol > 180;
        more_rowsToDelete = x_pol > (x_pol(1)+1000);
        y_pol(more_rowsToDelete) = [];
        x_pol(more_rowsToDelete) = [];
        y_pol(rowsToDelete) = [];
        x_pol(rowsToDelete) = []; 
        pol_millis(more_rowsToDelete) = [];
        pol_millis(rowsToDelete) = [];
        
        order = 3;
        framelen = 93;

        sgf = sgolayfilt(y_pol,order,framelen);
        
        v = zeros(length(pol_millis),1) ;
        for i = 1:length(pol_millis)-1
            v(i) = abs((sgf(i+1)-sgf(i))/(pol_millis(i+1)-pol_millis(i)) * 1000000);
        end
        
        length_v_half = round(length(v)/3);
        length_v_end_part = round(length(v) * 0.9);
        
        max_inst_vel = find(v==max(v(length_v_half:length_v_end_part)));
        start_ind = max_inst_vel - 50;
        end_ind = max_inst_vel +120;
        pol_dataframe = [x_pol sgf];
        holo_data_comp = [x_holo_no_lag y_holo];
        
        if end_ind < length(v)
            avg_vel = mean(v(start_ind:end_ind));
            pol_comp = pol_dataframe(start_ind:end_ind, :);
            
            
        elseif end_ind > length(v)
            avg_vel = mean(v(start_ind:end));
            pol_comp = pol_dataframe(end-220:end, :);
        else
            avg_vel = 0;
            pol_comp = [0 0];
            fprintf('No avg vel data trial %i\n', trialnum)
        end
           
        
        index_holo = holo_data_comp(:,1)>( pol_comp(1,1) -0.05);
        holo_filtered_temp = holo_data_comp(index_holo,1:2);
        index_temp_holo = holo_filtered_temp(:,1)< (pol_comp(end,1)+0.05);
        holo_filtered = holo_filtered_temp(index_temp_holo,1:2);
        
        holo_comp_length = length(holo_filtered);
        pol_comp_length = length(pol_comp(:,1));
        bins = floor(pol_comp_length/holo_comp_length);
        i = 0;
        pol_binned_data =[];
        
        for n = 1:holo_comp_length
            i= i + 1;
            if i == 1
                pol_binned_data(i) = mean(pol_comp(1:(n)*bins,2));
            else
                pol_binned_data(i) = mean(pol_comp(bins*(n-1):(n)*bins,2));
            end
        end
        

        comparing_diff = abs(pol_binned_data(:) - holo_filtered(:,2));
        if length(comparing_diff)>0
            rmse = sqrt((sum(comparing_diff).^2)/length(comparing_diff));
             if rmse > 100
                pol_dynamic = 0;
                avg_vel = 0;
                rmse = 0;
            end
        else
            pol_dynamic = 0;
            avg_vel = 0;
            rmse = 0;
        end
        
        vels_cell_fast_ID_10{trialnum, 1}  = pol_dynamic;
        vels_cell_fast_ID_10{trialnum,2} = avg_vel;
        vels_cell_fast_ID_10{trialnum,3} = rmse;
        catch me
            fprintf('no data')
        end
%         figure(trialnum)
%         plot(holo_filtered(:,1), holo_filtered(:,2) )
%         hold on
%         plot(pol_comp(:,1), pol_comp(:,2))
%         hold off 
        end
    end
    else
        fprintf('No polhemus data for trial %i\n; fast trial \n',i)
        end
        
end

%% just plot
figure(1)
avg_vel_tot_fast = vels_cell_fast_ID_10(:,2);
rmse_tot_fast = vels_cell_fast_ID_10(:,3);
avg_vel_tot_fast = avg_vel_tot_fast(all(cell2mat(avg_vel_tot_fast) ~= 0,2),:);
rmse_tot_fast = rmse_tot_fast(all(cell2mat(rmse_tot_fast) ~= 0,2),:);

plot([avg_vel_tot_fast{:}], [rmse_tot_fast{:}], 'o')
xlabel('Velocity (rad/s)')
ylabel('RMSE error')

%% plot all
figure(1)
x = [[avg_vel_tot_slow{:}] [avg_vel_tot_medium{:}] [avg_vel_tot_fast{:}]]';
y = [[rmse_tot_slow{:}] [rmse_tot_medium{:}] [rmse_tot_fast{:}]]';

mdl = fitlm(x,y)

plot([avg_vel_tot_slow{:}], [rmse_tot_slow{:}], 'o')
xlabel('Velocity (rad/s)')
ylabel('RMSE error')

hold on

plot([avg_vel_tot_medium{:}], [rmse_tot_medium{:}], 'o')

hold on

plot([avg_vel_tot_fast{:}], [rmse_tot_fast{:}], 'o')

hold on

plot(mdl)

legend('Slow', 'Medium', 'Fast')

title('Velocity against error between hololens and polhemus recordings for participant', ID)
xlabel('Velocity')
ylabel('RMSE error')

hold off


%%
slow_ID_10 = 'VelSlow_ID_10';
medium_ID_10 = 'VelMedium_ID_10';
fast_ID_10 = 'VelFast_ID_10';
VelErrorData10.(slow_ID_10) = cell2table(vels_cell_slow_ID_10);
VelErrorData10.(medium_ID_10) = cell2table(vels_cell_medium_ID_10) ;
VelErrorData10.(fast_ID_10) = cell2table(vels_cell_fast_ID_10);
save('VelErrorData10', 'VelErrorData10')
%% Code only used to troubleshoot/ plot the data=> put above 'index_holo' if required

%         %%%% CODE ONLY USED FOR PLOTTING HOLO SPLINE 
%         x_holo = x_holo_no_lag;
%         steps_holo = (x_holo(length(x_holo)) - x_holo(1)) / sum(x_holo);
%         xx_holo = x_holo(1):steps_holo:x_holo(length(x_holo));
%         
%         % removing duplicate data
%         [~, indexA, ~] = unique(y_holo);
%         A = sort(indexA);
%         y_holo_spline = y_holo(A);
%         x_holo_spline = x_holo(A);
%         steps_holo_spline = (x_holo_spline(length(x_holo_spline)) - x_holo_spline(1)) / sum(x_holo_spline);
%         xx_holo_spline = x_holo_spline(1):steps_holo_spline:x_holo_spline(length(x_holo_spline));
%         if length(y_holo_spline) > 1
%             yy_holo_spline = spline(x_holo_spline,y_holo_spline,xx_holo_spline);
%         end
%         
%         figure(trialnum)
% %         %%% with all holo data
% %         plot(x_holo_spline ,y_holo_spline,'o',xx_holo_spline,yy_holo_spline);
% %         hold on
%         
%         %%% without all holo data
%         index_start = x_holo_spline > pol_comp(1,1);
%         index_end = x_holo_spline < pol_comp(end,1);
%         index_start_spline = xx_holo_spline > pol_comp(1,1);
%         index_end_spline = xx_holo_spline < pol_comp(end,1);
%         plot(x_holo_spline(index_start) ,y_holo_spline(index_start),'o',xx_holo_spline(index_start_spline),yy_holo_spline(index_start_spline));
%         hold on
%         
%         plot(pol_comp(:,1), pol_comp(:,2));
% % 
%         xlabel('Time')
%         ylabel('Angle')
%         title('Medium trial')
%         legend('Holo Data','Holo Spline','Polh Data')
%         
%         hold off

% %%
% figure(1)
% plot(holo_filtered(:,1), holo_filtered(:,2) )
% hold on
% plot(pol_comp(:,1), pol_comp(:,2))
% hold off 
