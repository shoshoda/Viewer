%%%%%%%%%%%% File used for statistical analysis of temporal EMG data
%%% new addition of smoothness metrics as well as IEMG!

%% LOAD
clc; clear all; close all;
IDs = [6,7,8,9,10,11,12,13, 14, 15, 16, 17];
chk = exist('Nodes','var');
if ~chk
for ID = IDs
    ID = num2str(ID);
    folderload = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data\Data_MATLAB\EMG_Temporal';
    fileload = ['\Temporal_EMG_ID_' ID];
    load([folderload fileload]);
    fn = fieldnames(EMG_Temporal);
    %%% could do something to filter the velocites first and then calc mean
    %%% IEMG and smoothness...
    ID = str2num(ID);
    for i = 1:6
        mean_IEMG(ID-5, i) = mean(EMG_Temporal.(fn{i}));
    end
    
    for i = 7:12
        mean_smoothness(ID-5, i - 6) = mean(EMG_Temporal.(fn{i}));
    end
    
    z_flex_slow = EMG_Temporal.signal_flex_slow;
    z_extend_slow = EMG_Temporal.signal_extend_slow;
    z_flex_med = EMG_Temporal.signal_flex_medium;
    z_extend_med = EMG_Temporal.signal_extend_medium;
    z_flex_fast = EMG_Temporal.signal_flex_fast;
    z_extend_fast = EMG_Temporal.signal_extend_fast;
    
    for x = 1:length(z_flex_slow(:,1))
        z_flex_temp = nonzeros(z_flex_slow(x,:));
        z_extend_temp = nonzeros(z_flex_slow(x,:));
        t = 0:0.005:(length(z_flex_temp) - 1) * 0.005;
        IEMG_flex(x) = trapz(t, z_flex_temp);
        IEMG_extend(x) = trapz(t, z_extend_temp);
        smoothness_flex(x) = var(z_flex_temp);
        smoothness_extend(x) = var(z_extend_temp);
        
    end
    
    for y = 1:length(z_flex_med(:,1))
        z_flex_temp = nonzeros(z_flex_med(y,:));
        z_extend_temp = nonzeros(z_extend_med(y,:));
        t = 0:0.005:(length(z_flex_temp) - 1) * 0.005;
        IEMG_flex(x+y) = trapz(t, z_flex_temp);
        IEMG_extend(x+y) = trapz(t, z_extend_temp);
        smoothness_flex(x+y) = var(z_flex_temp);
        smoothness_extend(x+y) = var(z_extend_temp);
    end
    
    for z = 1:length(z_flex_fast(:,1))
        z_flex_temp = nonzeros(z_flex_fast(z,:));
        z_extend_temp = nonzeros(z_flex_fast(z,:));
        t = 0:0.005:(length(z_flex_temp) - 1) * 0.005;
        IEMG_flex(x+y+z) = trapz(t, z_flex_temp);
        IEMG_extend(x+y+z) = trapz(t, z_extend_temp);
        smoothness_flex(x+y+z) = var(z_flex_temp);
        smoothness_extend(x+y+z) = var(z_extend_temp);
    end
    
    velocities = [EMG_Temporal.velocities_slow; EMG_Temporal.velocities_medium; EMG_Temporal.velocities_fast];
    
    slow_idx = velocities < 64.4;
    med_idx = velocities >=64.4 & velocities < 141;
    fast_idx = velocities > 141;
    
    Time = [EMG_Temporal.time_slow;EMG_Temporal.time_medium; EMG_Temporal.time_fast];
        
    IEMG_flex_slow(ID - 5) = nanmean(IEMG_flex(slow_idx));
    IEMG_flex_med(ID - 5) = nanmean(IEMG_flex(med_idx));
    IEMG_flex_fast(ID - 5) = nanmean(IEMG_flex(fast_idx));
    
    IEMG_extend_slow(ID - 5) = nanmean(IEMG_extend(slow_idx));
    IEMG_extend_med(ID - 5) = nanmean(IEMG_extend(med_idx));
    IEMG_extend_fast(ID - 5) = nanmean(IEMG_extend(fast_idx));
    
    IEMG_flex_slow_norm(ID - 5) = nanmean(IEMG_flex(slow_idx)./Time(slow_idx)');
    IEMG_flex_med_norm(ID - 5) = nanmean(IEMG_flex(med_idx)./Time(med_idx)');
    IEMG_flex_fast_norm(ID - 5) = nanmean(IEMG_flex(fast_idx)./Time(fast_idx)');
    
    IEMG_extend_slow_norm(ID - 5) = nanmean(IEMG_extend(slow_idx)./Time(slow_idx)');
    IEMG_extend_med_norm(ID - 5) = nanmean(IEMG_extend(med_idx)./Time(med_idx)');
    IEMG_extend_fast_norm(ID - 5) = nanmean(IEMG_extend(fast_idx)./Time(fast_idx)');
    
    smoothness_flex_slow(ID - 5) = nanmean(smoothness_flex(slow_idx));
    smoothness_flex_med(ID - 5) = nanmean(smoothness_flex(med_idx));
    smoothness_flex_fast(ID - 5) = nanmean(smoothness_flex(fast_idx));
    
    smoothness_extend_slow(ID - 5) = nanmean(smoothness_extend(slow_idx));
    smoothness_extend_med(ID - 5) = nanmean(smoothness_extend(med_idx));
    smoothness_extend_fast(ID - 5) = nanmean(smoothness_extend(fast_idx));
    
    calibLoad = ['\Temporal_EMG_Calib' num2str(ID)];
    load([folderload calibLoad]);
    
%%%%>>>>>>>>>>>>> DO STUFF
end
end

mean_IEMG(:,1) = IEMG_flex_slow;
mean_IEMG(:,2) = IEMG_extend_slow;
mean_IEMG(:,3) =  IEMG_flex_med;
mean_IEMG(:,4) =  IEMG_extend_med;
mean_IEMG(:,5) = IEMG_flex_fast;
mean_IEMG(:,6) = IEMG_extend_fast;


%% plot raw IEMG 

slow_flex = plot(abs(mean_IEMG(:,1)))
hold on
slow_extend = plot(abs(mean_IEMG(:,2)))
hold on

medium_flex = plot(abs(mean_IEMG(:,3)))
hold on
medium_extend = plot(abs(mean_IEMG(:,4)))
hold on

fast_flex = plot(abs(mean_IEMG(:,5)))
hold on
fast_extend = plot(abs(mean_IEMG(:,6)))
hold on
% 
% calib_flex = plot(Calib_Temporal.Int_calib_flex)
% hold on
% calib_extend = plot(Calib_Temporal.Int_calib_extend)
% hold on

xlabel('ID')
ylabel('Mean IEMG (mVs)')
legend('Slow flex', 'Slow extend', 'Medium flex', 'Medium extend',...
         'Fast flex', 'Fast extend', 'Calib flex','Calib extend')
     
%% Try normalising in time 
% norm_slow_flex = abs(mean_IEMG(:,1))./ 1.8;
% norm_medium_flex = abs(mean_IEMG(:,3)) ./ 0.75;
% norm_fast_flex = abs(mean_IEMG(:,5)) ./ 0.45;
% 
% norm_slow_extend = abs(mean_IEMG(:,2))./ 1.8;
% norm_medium_extend = abs(mean_IEMG(:,4)) ./ 0.75;
% norm_fast_extend = abs(mean_IEMG(:,6)) ./ 0.45;

norm_slow_flex = IEMG_flex_slow_norm;
norm_medium_flex = IEMG_flex_med_norm;
norm_fast_flex = IEMG_flex_fast_norm;

norm_slow_extend = IEMG_extend_slow_norm;
norm_medium_extend = IEMG_extend_med_norm;
norm_fast_extend = IEMG_extend_fast_norm;

norm_calib_flex = Calib_Temporal.Int_calib_flex ./ Calib_Temporal.time_calib;
norm_calib_extend = Calib_Temporal.Int_calib_extend ./ Calib_Temporal.time_calib;

slow_flex = plot(norm_slow_flex)
hold on
slow_extend = plot(norm_slow_extend)
hold on

medium_flex = plot(norm_medium_flex)
hold on
medium_extend = plot(norm_medium_extend)
hold on

fast_flex = plot(norm_fast_flex)
hold on
fast_extend = plot(norm_fast_extend)
hold on

% calib_flex = plot(norm_calib_flex)
% hold on
% calib_extend = plot(norm_calib_extend)
% hold on

xlabel('ID')
ylabel('Mean EMG (mV)')
legend('Slow flex', 'Slow extend', 'Medium flex', 'Medium extend',...
         'Fast flex', 'Fast extend', 'Calib flex','Calib extend')
title('Normalised')
     
%% Flex raw

Anova_flex_IEMG = [mean_IEMG(:,1) mean_IEMG(:,3) mean_IEMG(:,5)];
[p,tbl,stats] = anova1(Anova_flex_IEMG)
multcompare(stats)
%% Extend raw
Anova_extend_IEMG = [mean_IEMG(:,2) mean_IEMG(:,4) mean_IEMG(:,6)];
[p,tbl,stats] = anova1(Anova_extend_IEMG)
multcompare(stats)
%% All raw
Anova_all_IEMG = [mean_IEMG(:,1) mean_IEMG(:,2) mean_IEMG(:,3) mean_IEMG(:,4) mean_IEMG(:,5) mean_IEMG(:,6)];
[p,tbl,stats] = anova1(Anova_all_IEMG)
multcompare(stats)
%% Flex normalised
Anova_flex_IEMG_norm = [norm_slow_flex; norm_medium_flex; norm_fast_flex ]';
[p,tbl,stats] = anova1(Anova_flex_IEMG_norm)

%% Extend normalised
Anova_extend_IEMG_norm = [norm_slow_extend; norm_medium_extend; norm_fast_extend ]';
[p,tbl,stats] = anova1(Anova_extend_IEMG_norm)
multcompare(stats)
%% All normalised
Anova_all_IEMG_norm = [norm_slow_flex; norm_medium_flex; norm_fast_flex;  ...
    norm_slow_extend; norm_medium_extend; norm_fast_extend  ]';
[p,tbl,stats] = anova1(Anova_all_IEMG_norm)
multcompare(stats)

%% Try some boxplots

figure(1)
boxplot(mean_IEMG)
% xlabel('Condition','FontSize', 16)
ylabel('Mean IEMG (mVs)','FontSize', 16)

figure(2)
boxplot(Anova_all_IEMG_norm)
% xlabel('Condition')
ylabel('Mean IEMG normalised in time (mV)','FontSize', 16)

%%%%%%%%%%%%%%%%%%>>>>>>>>>>>>>>>>>>>>>>>>>>>
%% Smoothness
%% plot raw smoothness 
mean_smoothness(:,1) = smoothness_flex_slow;
mean_smoothness(:,2) = smoothness_extend_slow;
mean_smoothness(:,3) =  smoothness_flex_med;
mean_smoothness(:,4) =  smoothness_extend_med;
mean_smoothness(:,5) = smoothness_flex_fast;
mean_smoothness(:,6) = smoothness_extend_fast;

slow_flex = plot(abs(mean_smoothness(:,1)))
hold on
slow_extend = plot(abs(mean_smoothness(:,2)))
hold on

medium_flex = plot(abs(mean_smoothness(:,3)))
hold on
medium_extend = plot(abs(mean_smoothness(:,4)))
hold on

fast_flex = plot(abs(mean_smoothness(:,5)))
hold on
fast_extend = plot(abs(mean_smoothness(:,6)))
hold on

% calib_flex = plot(Calib_Temporal.smoothness_flex_calib)
% hold on
% calib_extend = plot(Calib_Temporal.smoothness_extend_calib)
% hold on

xlabel('ID')
ylabel('Mean smoothness / variance')
legend('Slow flex', 'Slow extend', 'Medium flex', 'Medium extend',...
         'Fast flex', 'Fast extend', 'Calib flex','Calib extend')
     
%% Try normalizing ID 10 (15)
% mean_smoothness(10,:) = mean_smoothness(10,:)* 0.1;

% norm_calib_flex = Calib_Temporal.smoothness_flex_calib ./ Calib_Temporal.time_calib;
% norm_calib_extend = Calib_Temporal.smoothness_extend_calib ./ Calib_Temporal.time_calib;

slow_flex = plot(abs(mean_smoothness(:,1)))
hold on
slow_extend = plot(abs(mean_smoothness(:,2)))
hold on

medium_flex = plot(abs(mean_smoothness(:,3)))
hold on
medium_extend = plot(abs(mean_smoothness(:,4)))
hold on

fast_flex = plot(abs(mean_smoothness(:,5)))
hold on
fast_extend = plot(abs(mean_smoothness(:,6)))
hold on

% calib_flex = plot(norm_calib_flex)
% hold on
% calib_extend = plot(norm_calib_extend)
% hold on

xlabel('ID')
ylabel('Mean smoothness / variance')
legend('Slow flex', 'Slow extend', 'Medium flex', 'Medium extend',...
         'Fast flex', 'Fast extend', 'Calib flex','Calib extend')
title('Normalised')
     
%% Flex raw

Anova_flex_smoothness = [mean_smoothness(:,1) mean_smoothness(:,3) mean_smoothness(:,5) ];
[p,tbl,stats] = anova1(Anova_flex_smoothness)

%% Extend raw
Anova_extend_smoothness = [mean_smoothness(:,2) mean_smoothness(:,4) mean_smoothness(:,6)];
[p,tbl,stats] = anova1(Anova_extend_smoothness)
multcompare(stats)
%% All raw
Anova_all_smoothness = [mean_smoothness(:,1) mean_smoothness(:,2) mean_smoothness(:,3) mean_smoothness(:,4) mean_smoothness(:,5) mean_smoothness(:,6)];
[p,tbl,stats] = anova1(Anova_all_smoothness)
multcompare(stats)
%% Flex normalised
Anova_flex_smoothness_norm = [norm_slow_flex norm_medium_flex norm_fast_flex ];
[p,tbl,stats] = anova1(Anova_flex_smoothness_norm)

%% Extend normalised
Anova_extend_smoothness_norm = [norm_slow_extend norm_medium_extend norm_fast_extend ];
[p,tbl,stats] = anova1(Anova_extend_smoothness_norm)

%% All normalised
Anova_all_smoothness_norm = [norm_slow_flex norm_medium_flex norm_fast_flex  ...
    norm_slow_extend norm_medium_extend norm_fast_extend  ];
[p,tbl,stats] = anova1(Anova_all_smoothness_norm)

%%
figure(1)
boxplot(Anova_all_smoothness)
% xlabel('Condition','FontSize', 16)
ylabel('Smoothness (mV^2)','FontSize', 16)

% figure(2)
% boxplot(Anova_all_smoothness_norm)
% % xlabel('Condition')
% ylabel('Smoothness (mV^2)','FontSize', 16)
