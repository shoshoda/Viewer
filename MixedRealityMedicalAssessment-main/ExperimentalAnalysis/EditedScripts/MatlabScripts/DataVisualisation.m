clc; close all;
clear all;
%% Input the ID of data you want to analyse here. The .mat file will then be auto-loaded.
IDs = [1,4,5,6,7,8,9,10,11,12,13, 14, 15, 16, 17];
chk = exist('Nodes','var');
if ~chk
    for ID = IDs
%     ID = 11;
    ID = num2str(ID);
    ID_folder = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data\Data_MATLAB\VelocityErrorData\';
    mat_data = ['VelErrorData' ID];
    load([ID_folder mat_data])
    end
end
% mergeVelErrors = cell2struct([struct2cell(VelErrorData11), fieldname(VelErrorData11));
mergeVelErrors = cell2struct([struct2cell(VelErrorData1);struct2cell(VelErrorData4);...
    struct2cell(VelErrorData5);struct2cell(VelErrorData6);...
    struct2cell(VelErrorData7);struct2cell(VelErrorData8);...
    struct2cell(VelErrorData9);struct2cell(VelErrorData10);...
    struct2cell(VelErrorData11);...
    struct2cell(VelErrorData12);struct2cell(VelErrorData13);...
    struct2cell(VelErrorData14); struct2cell(VelErrorData15);...
    struct2cell(VelErrorData16); struct2cell(VelErrorData17)],...
[fieldnames(VelErrorData1);fieldnames(VelErrorData4);...
    fieldnames(VelErrorData5);fieldnames(VelErrorData6);...
    fieldnames(VelErrorData7);fieldnames(VelErrorData8);fieldnames(VelErrorData9);...
    fieldnames(VelErrorData10);...
    fieldnames(VelErrorData11);fieldnames(VelErrorData12);fieldnames(VelErrorData13);...
    fieldnames(VelErrorData14);fieldnames(VelErrorData15);...
    fieldnames(VelErrorData16);fieldnames(VelErrorData17)]);

%%
x = [];
y_raw = [];
y_spline = [];
fields = fieldnames(mergeVelErrors);
mergeSlow_vel = [];
mergeMed_vel = [];
mergeFast_vel = [];
mergeSlow_RMSE_raw = [];
mergeMed_RMSE_raw = [];
mergeFast_RMSE_raw = [];
mergeSlow_RMSE_spline = [];
mergeMed_RMSE_spline = [];
mergeFast_RMSE_spline = [];
% fields = fieldnames(VelErrorData11);
counter = 0;
for i = 1:numel(fields)

temp = table2cell(mergeVelErrors.(fields{i}));
% temp = table2cell(VelErrorData11.(fields{i}));

vel = temp(:,2);
rmse_raw = temp(:,3);
rmse_spline = temp(:,4);

if counter == 0
    mergeSlow_vel = [mergeSlow_vel; vel];
    mergeSlow_RMSE_raw = [mergeSlow_RMSE_raw; rmse_raw];
    mergeSlow_RMSE_spline = [mergeSlow_RMSE_spline; rmse_spline];
    counter = 1;
    
elseif counter == 1
    mergeMed_vel = [mergeMed_vel; vel];
    mergeMed_RMSE_raw = [mergeMed_RMSE_raw; rmse_raw];
    mergeMed_RMSE_spline = [mergeMed_RMSE_spline; rmse_spline];
    counter = 2;
elseif counter == 2
    mergeFast_vel = [mergeFast_vel; vel];
    mergeFast_RMSE_raw = [mergeFast_RMSE_raw; rmse_raw];
    mergeFast_RMSE_spline = [mergeFast_RMSE_spline; rmse_spline];
    counter = 0;
end
    
    

vel = vel(all(cell2mat(vel) ~= 0,2),:);
rmse_raw = rmse_raw(all(cell2mat(rmse_raw) ~= 0,2),:);
rmse_spline = rmse_spline(all(cell2mat(rmse_spline) ~= 0,2),:);
x = [x; vel];
y_raw = [y_raw; rmse_raw];
y_spline = [y_spline; rmse_spline];

end


fname = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data\Data_MATLAB\VelocityErrorData\Plots\';
% close all;
FigH = figure('Position', get(0, 'Screensize'));

x = cell2mat(x);
y_raw = cell2mat(y_raw);
y_spline = cell2mat(y_spline);


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
ylim([0 800])
% xlim([20 180])
yticks([0:100:1000])
legend([leg_vel_raw,outliers_raw, leg_raw_LR, leg_vel_spline, outliers_spline, leg_spline_LR], {'Raw data','Raw outliers'...
    'Raw robust linear model', 'Spline data','Spline outliers','Spline robust linear model'},'FontSize', 20,'Location', 'northwest');
xlim=get(gca,'XLim');
ylim=get(gca,'YLim');
if brob_raw(2) > 0 & brob_spline(2) > 0
    text(0.98*xlim(1)+0.02*xlim(2),0.28*ylim(1)+0.62*ylim(2),['y = ' num2str(brob_raw(1),'%.3g') '+' num2str(brob_raw(2),'%.2f') 'x'],'Color', 'r', 'FontSize', 20)
    text(0.98*xlim(1)+0.02*xlim(2),0.38*ylim(1)+0.52*ylim(2),['y = ' num2str(brob_spline(1),'%.3g') '+' num2str(brob_spline(2),'%.3f') 'x'],'Color', 'b', 'FontSize', 20)
elseif brob_raw(2) > 0 & brob_spline(2) < 0 
    text(0.98*xlim(1)+0.02*xlim(2),0.28*ylim(1)+0.62*ylim(2),['y = ' num2str(brob_raw(1),'%.3g') '+' num2str(brob_raw(2),'%.3g') 'x'],'Color', 'r', 'FontSize', 20)
    text(0.98*xlim(1)+0.02*xlim(2),0.38*ylim(1)+0.52*ylim(2),['y = ' num2str(brob_spline(1),'%.3g') num2str(brob_spline(2),'%.3g') 'x'],'Color', 'b', 'FontSize', 20)
elseif brob_raw(2) < 0 & brob_spline(2) > 0 
    text(0.98*xlim(1)+0.02*xlim(2),0.28*ylim(1)+0.62*ylim(2),['y = ' num2str(brob_raw(1),'%.3g') num2str(brob_raw(2),'%.3g') 'x'],'Color', 'r', 'FontSize', 20)
    text(0.98*xlim(1)+0.02*xlim(2),0.38*ylim(1)+0.52*ylim(2),['y = ' num2str(brob_spline(1),'%.3g') '+' num2str(brob_spline(2),'%.3g') 'x'],'Color', 'b', 'FontSize', 20)
else
    text(0.98*xlim(1)+0.02*xlim(2),0.28*ylim(1)+0.62*ylim(2),['y = ' num2str(brob_raw(1),'%.3g') num2str(brob_raw(2),'%.3g') 'x'],'Color', 'r', 'FontSize', 20)
    text(0.98*xlim(1)+0.02*xlim(2),0.38*ylim(1)+0.52*ylim(2),['y = ' num2str(brob_spline(1),'%.3g') num2str(brob_spline(2),'%.3g') 'x'],'Color', 'b', 'FontSize', 20)
end
%     title(['Velocity against RMSE between Polhemus and Hololens angle readings for all participants'],'FontSize', 18)
xlabel('Velocity (deg/s)','FontSize', 24)
ylabel('RMSE', 'FontSize', 24)
ax = gca;
ax.FontSize = 16;
hold off

mkdir 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data\Data_MATLAB\VelocityErrorData\Plots\IDPlots'  '\ID1'
filename = ['OverallPlot'];
% filename = ['\VelErrorID' num2str(ID)];
% saveas(FigH, fullfile(fname, filename), 'fig');

% A = Slow_tot(mergeSlow_RsMSE~=0);

%% Histogram to investigate distribution of data
figure(1)
hist_raw = histogram(y_raw)
% hist_raw = histogram2(x,y_raw)
ylabel('Frequency')
xlabel('Raw RMSE')
% zlabel('Frequency')

figure(2)
% hist_spline = histogram2(x,y_spline)
hist_raw = histogram(y_spline)
ylabel('Frequency')
xlabel('Spline RMSE')
% zlabel('Frequency')

figure(3)
% hist_spline = histogram2(x,y_spline)
hist_vel = histogram(x)
ylabel('Frequency')
xlabel('Velocity (deg/s)')
% zlabel('Frequency')
%% robust fit just spline
% bls = regress(y,[ones(length(x),1) x]);
% [brob,stats] = robustfit(x,y);
fname = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data\Data_MATLAB\VelocityErrorData\Plots\';
% close all;
FigH_spline = figure('Position', get(0, 'Screensize'));

outliers_ind_spline = find(abs(stats_spline.resid)>stats_spline.mad_s);

scatter(x,y_spline,'filled');

hold on 
plot(x(outliers_ind_spline),y_spline(outliers_ind_spline),'mo','LineWidth',1)


% plot(x,bls(1)+bls(2)*x,'r')
plot(x,brob_spline(1)+brob_spline(2)*x,'LineWidth',2,'color','b')
hold off
xlabel('Velocity (deg/s)', 'FontSize', 20)
ylabel('RMSE', 'FontSize', 20)
title({'Velocity against RMSE between Polhemus and Hololens angle readings for' ;'all participants using the spline and robust regression'}, 'FontSize',20)
clear ylim
ylim([0 300])
xlim=get(gca,'XLim');
ylim=get(gca,'YLim');
% text(0.8*xlim(1)+0.2*xlim(2),0.2*ylim(1)+0.8*ylim(2),['y = ' num2str(bls(1)) '+' num2str(bls(2)) 'x'],'Color', 'r', 'FontSize', 20)
text(0.2*xlim(1)+0.8*xlim(2),0.6*ylim(1)+0.4*ylim(2),['y = ' num2str(brob_spline(1)) '+' num2str(brob_spline(2)) 'x'],'Color', 'b', 'FontSize', 20)
% ylim([0 100])
legend('Data','Outlier','Robust Regression', 'FontSize', 20)
grid on
mkdir 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data\Data_MATLAB\VelocityErrorData\Plots\IDPlots'  '\ID1'
filename = ['SplinePlot'];
% filename = ['\VelErrorID' num2str(ID)];
% saveas(FigH_spline, fullfile(fname, filename), 'fig');
%% Linear model statistics:
[brob_raw,stats_raw] = robustfit(x,y_raw)
[brob_spline,stats_spline] = robustfit(x,y_spline)
rsquare_robustfit_raw = corr(y_raw,brob_raw(1)+brob_raw(2)*x)^2
rsquare_robustfit_spline = corr(y_spline,brob_spline(1)+brob_spline(2)*x)^2

mdl_raw = fitlm(x,y_raw)
mdl_spline = fitlm(x,y_spline)
%%
x_onset = [];
x_freq =[];
mergeSlow_onset = [];
mergeMed_onset = [];
mergeFast_onset = [];
for i = 1:numel(fields)

temp = table2cell(mergeVelErrors.(fields{i}));
% temp = table2cell(VelErrorData11.(fields{i}));

time_onset = temp(:,9);
rmse_raw = temp(:,3);
rmse_spline = temp(:,4);
freq = temp(:,11);

if counter == 0
    mergeSlow_onset = [mergeSlow_onset; time_onset];
    counter = 1;
    
elseif counter == 1
    mergeMed_onset = [mergeMed_onset; time_onset];
    counter = 2;
elseif counter == 2
    mergeFast_onset = [mergeFast_onset; time_onset];
    counter = 0;
end
x_onset = [x_onset; time_onset];
x_freq = [x_freq; freq];

end
% close all;
FigHOnset = figure('Position', get(0, 'Screensize'));
x_onset = cell2mat(x_onset);
x_freq = cell2mat(x_freq);

[brob_raw_onset,stats_raw_onset] = robustfit(x_onset,y_raw);
[brob_spline_onset,stats_spline_onset] = robustfit(x_onset,y_spline);

outliers_ind_raw_onset = find(abs(stats_raw_onset.resid)>stats_raw_onset.mad_s);
outliers_ind_spline_onset = find(abs(stats_spline_onset.resid)>stats_spline_onset.mad_s);

leg_onset_raw_onset = plot(x_onset,y_raw,'s','color','red');
hold on 
outliers_raw_onset = scatter(x_onset(outliers_ind_raw_onset),y_raw(outliers_ind_raw_onset),[],'r','filled','s');
hold on
leg_raw_LR_onset = plot(x_onset,brob_raw_onset(1)+brob_raw_onset(2)*x_onset,'r');
hold on

leg_onset_spline_onset = plot(x_onset,y_spline,'o','color','b');
hold on 
outliers_spline_onset = scatter(x_onset(outliers_ind_spline_onset),y_spline(outliers_ind_spline_onset),'filled','b');
hold on
leg_spline_LR_onset = plot(x_onset,brob_spline_onset(1)+brob_spline_onset(2)*x_onset,'b');
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
% ylim([0 600])
% xlim([0 1.2])
yticks([0:100:1000])
legend([leg_onset_raw_onset,outliers_raw_onset, leg_raw_LR_onset, leg_onset_spline_onset, outliers_spline_onset, leg_spline_LR_onset], {'Raw data','Raw outliers'...
    'Raw robust linear model', 'Spline data','Spline outliers','Spline robust linear model'},'FontSize', 20,'Location', 'northwest')
xlim=get(gca,'XLim');
ylim=get(gca,'YLim');
if brob_raw_onset(2) > 0 & brob_spline_onset(2) > 0
    text(0.98*xlim(1)+0.02*xlim(2),0.28*ylim(1)+0.62*ylim(2),['y = ' num2str(brob_raw_onset(1), '%.3g') '+' num2str(brob_raw_onset(2), '%.3g') 'x'],'Color', 'r', 'FontSize', 20)
    text(0.98*xlim(1)+0.02*xlim(2),0.38*ylim(1)+0.52*ylim(2),['y = ' num2str(brob_spline_onset(1), '%.3g') '+' num2str(brob_spline_onset(2), '%.3g') 'x'],'Color', 'b', 'FontSize', 20)
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

% title('Time onset against RMSE between Polhemus and Hololens angle recordings for participant 1', 'FontSize', 18)
xlabel('Time onset (s)', 'FontSize', 24)
ylabel('RMSE', 'FontSize', 24)
ax = gca;
ax.FontSize = 16;

filename = ['ID' num2str(ID) '\TimeOnsetErrorID' num2str(ID)];
% filename = ['\TimeOnsetErrorID' num2str(ID)];
% saveas(FigHOnset, fullfile(fname, filename), 'fig');

%%
figure(3)
% hist_spline = histogram2(x,y_spline)
hist_vel = histogram(x_onset)
ylabel('Frequency')
xlabel('Time onset (s)')

%% x-onset, y-spline data. Calculating the percentage of missed data

missed_data = [x_onset x x_freq];
[Xsorted,I] = sort(x);
missed_data_sort = missed_data(I,:);
sort_slow = missed_data_sort(1:(0.333*length(x)),:);
sort_medium = missed_data_sort(0.333*length(x):(0.666*length(x)),:);
sort_fast = missed_data_sort(0.666*length(x):end,:);

slow_time = 1./sort_slow(:,3);
medium_time = 1./sort_medium(:,3);
fast_time = 1./sort_fast(:,3);

slow_time_catch = sort_slow(:,1);
medium_time_catch = sort_medium(:,1);
fast_time_catch = sort_fast(:,1);
y_bar= [mean(slow_time) mean(slow_time_catch);mean(medium_time) mean(medium_time_catch);mean(fast_time) mean(fast_time_catch);];
x_bar = [1; 2; 3];
x_bar_names = {'Slow'; 'Medium'; 'Fast'};
y_err = [std(slow_time) std(slow_time_catch);std(medium_time) std(medium_time_catch);std(fast_time) std(fast_time_catch);];
for i = 1:3
y_percent(i) = round(((y_bar(i,2))/ y_bar(i,1)), 2)
end
figure(2)
bar(x_bar,y_bar ,'stacked');
hold on
errorbar(cumsum(y_bar')',y_err,'.k');
set(gca,'xtick',[1:3],'xticklabel',x_bar_names)
ylabel('Time between Hololens 2 readings (s)','FontSize', 16)
xlabel('Velocity bands','FontSize', 16)
legend('During whole trial', 'During catch phase', 'Location', 'Northwest','FontSize', 16)
% sort_slow_missed = sum(ceil(sort_slow(:,1)/framerate_seconds));
% sort_medium_missed = sum(ceil(sort_medium(:,1)/framerate_seconds));
% sort_fast_missed = sum(ceil(sort_fast(:,1)/framerate_seconds));

%% Linear model statistics:
[brob_raw_onset,stats_raw_onset] = robustfit(x_onset,y_raw)
[brob_spline_onset,stats_spline_onset] = robustfit(x_onset,y_spline)
rsquare_robustfit_raw = corr(y_raw,brob_raw_onset(1)+brob_raw_onset(2)*x_onset)^2
rsquare_robustfit_spline = corr(y_spline,brob_spline_onset(1)+brob_spline_onset(2)*x_onset)^2


mdl_raw_onset = fitlm(x_onset,y_raw)
mdl_spline_onset = fitlm(x_onset,y_spline)


%% new sec
close all;
Slow_tot= cell2mat([mergeSlow_vel mergeSlow_RMSE_spline]);
Med_tot= cell2mat([mergeMed_vel mergeMed_RMSE_spline]);
Fast_tot= cell2mat([mergeFast_vel mergeFast_RMSE_spline]);

merge_all_vels = [Slow_tot; Med_tot; Fast_tot];

vel_bel_60 = merge_all_vels((merge_all_vels(:,1) < 60),:);
vel_bel_60 = vel_bel_60((vel_bel_60(:,1) > 0),:);
vel_bel_60 = vel_bel_60((vel_bel_60(:,2) < 300 ),:);

vel_60_90 = merge_all_vels((merge_all_vels(:,1) > 60),:);
vel_60_90 = vel_60_90((vel_60_90(:,1) < 90 ),:);
vel_60_90 = vel_60_90((vel_60_90(:,2) < 300 ),:);

vel_90_120 = merge_all_vels((merge_all_vels(:,1) > 90),:);
vel_90_120 = vel_90_120((vel_90_120(:,1) < 120 ),:);
vel_90_120 = vel_90_120((vel_90_120(:,2) < 300 ),:);


vel_120_150 = merge_all_vels((merge_all_vels(:,1) > 120),:);
vel_120_150 = vel_120_150((vel_120_150(:,1) < 150 ),:);
vel_120_150 = vel_120_150((vel_120_150(:,2) < 300 ),:);

vel_150_180 = merge_all_vels((merge_all_vels(:,1) > 150),:);
vel_150_180 = vel_150_180((vel_150_180(:,1) < 180 ),:);
vel_150_180 = vel_150_180((vel_150_180(:,2) < 300 ),:);

vel_above_180 = merge_all_vels((merge_all_vels(:,1) > 180),:);
vel_above_180 = vel_above_180((vel_above_180(:,2) < 300 ),:);

%%
close all;
clear xlim;
clear ylim;
FigH_boxplots = figure('Position', get(0, 'Screensize'));


subplot(3,2,1)
boxplot(vel_bel_60(:,2))
ylim([0 300])
yticks([0:50:300])
hold on
ylabel('RMSE', 'FontSize', 20)
xlabel('Below 60 deg/s', 'FontSize', 20)
TF = isoutlier( vel_bel_60(:,2) , 'mean' );
sum(TF(:) == 1)

subplot(3,2,2)
boxplot(vel_60_90(:,2))
ylim([0 300])
yticks([0:50:300])
hold on
% ylabel('RMSE')
xlabel('60-90 deg/s','FontSize', 20)
TF = isoutlier( vel_60_90(:,2) , 'mean' );
sum(TF(:) == 1)

subplot(3,2,3)
boxplot(vel_90_120(:,2))
ylim([0 300])
yticks([0:50:300])
hold on
% ylabel('RMSE')
ylabel('RMSE', 'FontSize', 20)
xlabel('90-120 deg/s', 'FontSize', 20)
TF = isoutlier( vel_90_120(:,2) , 'mean' );
sum(TF(:) == 1)

subplot(3,2,4)
boxplot(vel_120_150(:,2))
ylim([0 300])
yticks([0:50:300])
hold on
xlabel('120-150 deg/s', 'FontSize', 20)
TF = isoutlier( vel_120_150(:,2) , 'mean' );
sum(TF(:) == 1)

subplot(3,2,5)
boxplot(vel_150_180(:,2))
ylim([0 300])
yticks([0:50:300])
hold on
% ylabel('RMSE')
ylabel('RMSE', 'FontSize', 20)
xlabel('150-180 deg/s', 'FontSize', 20)
TF = isoutlier( vel_150_180(:,2) , 'mean' );
sum(TF(:) == 1)

subplot(3,2,6)
boxplot(vel_above_180(:,2))
ylim([0 300])
yticks([0:50:300])
hold on
% ylabel('RMSE')
xlabel('Above 180 deg/s', 'FontSize', 20)
TF = isoutlier( vel_above_180(:,2) , 'mean' );
sum(TF(:) == 1)


sgtitle({'Boxplot of RMSE between Hololens and Polhemus angle recordings against velocity for different velocity bands'}, 'FontSize', 20)

filename = ['BoxPlots'];
% filename = ['\VelErrorID' num2str(ID)];
% saveas(FigH_boxplots, fullfile(fname, filename), 'fig');


%% new section
clear ylim 
clear xlim
FigH_boxplot_myAssess = figure('Position', get(0, 'Screensize'));

Slow_tot = Slow_tot((Slow_tot(:,2) < 300 ),:);
Med_tot = Med_tot((Med_tot(:,2) < 300 ),:);
Fast_tot = Fast_tot((Fast_tot(:,2) < 300 ),:);


subplot(1,3,1)
boxplot(Slow_tot(:,2))
ylim([0 300])
yticks([0:30:300])
ylabel('RMSE', 'FontSize', 20)
xlabel('Slow', 'FontSize', 20)
hold on


subplot(1,3,2)
boxplot(Med_tot(:,2))
ylim([0 300])
yticks([0:30:300])
xlabel('Medium',  'FontSize', 20)
hold on


subplot(1,3,3)
boxplot(Fast_tot(:,2))
ylim([0 300])
yticks([0:30:300])
xlabel('Fast',  'FontSize', 20)
hold on

sgtitle({'Boxplot of RMSE between Hololens and Polhemus angle recordings', 'against velocity for different velocity bands using my assessment criteria'}, 'FontSize', 15)

filename = ['BoxPlots_MyAssess'];
% filename = ['\VelErrorID' num2str(ID)];
% saveas(FigH_boxplot_myAssess, fullfile(fname, filename), 'fig');


