%%%%%%%%%%%% File used for statistical analysis of temporal EMG data

%% LOAD
clc; clear all; close all;
IDs = [6,7,8,9,10,11,12,13, 14, 15, 16, 17];
chk = exist('Nodes','var');
total_power = zeros(102,6);
individual_power = zeros(102,6,12);
if ~chk
for ID = IDs
    ID = num2str(ID);
    folderload = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data\Data_MATLAB\EMG_Frequency';
    fileload = ['\Frequency_EMG_ID_' ID];
    load([folderload fileload]);
    fn = fieldnames(EMG_Frequency);
    %%% could do something to filter the velocites first and then calc mean
    %%% IEMG and smoothness...
    ID = str2num(ID);
    temp_power_flex =zeros(1,200);temp_power_extend=zeros(1,200);temp_freq =zeros(1,200); velocity =[];
    n = 200;
    %%%% filter according to actual velocity
    for speed = 0:2
        a_flex = (EMG_Frequency.(fn{1+2*speed}));
        a_bis_flex = [a_flex zeros(n - length(a_flex),length(a_flex(:,1)))'];
        temp_power_flex = [temp_power_flex; a_bis_flex];
%         temp_power_flex = [temp_power_flex; ];
        a_extend = (EMG_Frequency.(fn{2+2*speed}));
        a_bis_extend = [a_extend zeros(n - length(a_extend),length(a_extend(:,1)))'];
        temp_power_extend = [temp_power_extend; a_bis_extend];
        
        a_freq = (EMG_Frequency.(fn{13+speed}));
        a_bis_freq = [a_freq zeros(n - length(a_freq),length(a_freq(:,1)))'];
        temp_freq = [temp_freq; a_bis_freq];
        velocity = [velocity; EMG_Frequency.(fn{16+speed})];
    
    end
    
    temp_power_flex(1,:) = [];
    temp_power_extend(1,:) = [];
    temp_freq(1,:) = [];
    
    % index according to these actual velocities
    slow_idx = velocity < 64.4;
    med_idx = velocity >=64.4 & velocity < 141;
    fast_idx = velocity > 141;
    
    power_flex_slow = temp_power_flex(slow_idx, :);
    power_flex_med = temp_power_flex(med_idx, :);
    power_flex_fast = temp_power_flex(fast_idx, :);
    
    power_extend_slow = temp_power_extend(slow_idx,: );
    power_extend_med = temp_power_extend(med_idx, :);
    power_extend_fast = temp_power_extend(fast_idx, :);
    
    freq_slow = temp_freq(slow_idx, :);
    freq_med = temp_freq(med_idx, :);
    freq_fast = temp_freq(fast_idx, :);
    for speed = 1 : 3
        if speed== 1
    
        for trials = 1: length(freq_slow(:,1))
            freq_no_zeros = (nonzeros(freq_slow(trials,:)));
            power_no_zeros_flex = (nonzeros(power_flex_slow(trials,2:end)));
            power_no_zeros_extend = (nonzeros(power_extend_slow(trials,2:end)));
            % bin the spectral data into 1Hz categories
            [B,idx] = histc(freq_no_zeros,0:1:100);
            idx_filt= idx(idx<=100);
            temp_flex = accumarray(idx_filt(:),power_no_zeros_flex(idx<=100),[],@mean);
            temp_extend = accumarray(idx_filt(:),power_no_zeros_extend(idx<=100),[],@mean);
            binned_power_flex(1:length(temp_flex),trials) = temp_flex;
            binned_power_extend(1:length(temp_flex),trials) = temp_extend;
        end
        elseif speed ==2
            for trials = 1: length(freq_med(:,1))
            freq_no_zeros = (nonzeros(freq_med(trials,:)));
            power_no_zeros_flex = (nonzeros(power_flex_med(trials,2:end)));
            power_no_zeros_extend = (nonzeros(power_extend_med(trials,2:end)));
            % bin the spectral data into 1Hz categories
            [B,idx] = histc(freq_no_zeros,0:1:100);
            idx_filt= idx(idx<=100);
            temp_flex = accumarray(idx_filt(:),power_no_zeros_flex(idx<=100),[],@mean);
            temp_extend = accumarray(idx_filt(:),power_no_zeros_extend(idx<=100),[],@mean);
            binned_power_flex(1:length(temp_flex),trials) = temp_flex;
            binned_power_extend(1:length(temp_extend),trials) = temp_extend;
            end
        elseif speed ==3
            for trials = 1: length(freq_fast(:,1))
            freq_no_zeros = (nonzeros(freq_fast(trials,:)));
            power_no_zeros_flex = (nonzeros(power_flex_fast(trials,2:end)));
            power_no_zeros_extend = (nonzeros(power_extend_fast(trials,2:end)));
            % bin the spectral data into 1Hz categories
            [B,idx] = histc(freq_no_zeros,0:1:100);
            idx_filt= idx(idx<=100);
            temp_flex = accumarray(idx_filt(:),power_no_zeros_flex(idx<=100),[],@mean);
            temp_extend = accumarray(idx_filt(:),power_no_zeros_extend(idx<=100),[],@mean);
            binned_power_flex(1:length(temp_flex),trials) = temp_flex;
            binned_power_extend(1:length(temp_extend),trials) = temp_extend;
            end
        else
            fprintf('error')
        end
    
    total_power(:, speed) = total_power(:,speed) + [0; (mean(binned_power_flex, 2)); 0];
    total_power(:, speed+3) = total_power(:,speed+3) + [0; (mean(binned_power_extend, 2)); 0];
    individual_power(:, speed, ID-5) = [0; (mean(binned_power_flex, 2)); 0];
    individual_power(:, speed+3, ID-5) = [0; (mean(binned_power_extend, 2)); 0];
    end
    
end

    total_power(:,:) = total_power(:,:) / length(IDs);
    %%% plotted mean spectral analysis for 1Hz binned data over all IDs
    freqs = 0:1:100;
%     power = [0; (mean(binned_power, 2)); 0];
    freqs(end+1) = 100;

%     if speed == 0
    figure(1)
%     subplot(2,1,1)
    h1 = patch(freqs,total_power(:,1),'r');
    
    hold on
%     elseif speed == 1
    h2 = patch(freqs,total_power(:,2),'g');
    hold on
%     else speed == 2
    h3 = patch(freqs,total_power(:,3),'b');
    hold on
    
%     end
    % Choose a number between 0 (invisible) and 1 (opaque) for facealpha.  
    set(h1,'facealpha',0.5)
    set(h2,'facealpha',0.5)
    set(h3,'facealpha',0.5)
    legend('Slow','Medium','Fast','Location','best', 'FontSize',16 )
    xlabel('Frequency (Hz)', 'FontSize',16 )
    ylabel('Power spectral density (nV^2/Hz)', 'FontSize',16 )
%     title('Flexor')
%     ylim([0 15000])
    hold off
    
    figure(2)
%     subplot(2,1,2)
    h1 = patch(freqs,total_power(:,4),'r');
    hold on
%     elseif speed == 1
    h2 = patch(freqs,total_power(:,5),'g');
    hold on
%     else speed == 2
    h3 = patch(freqs,total_power(:,6),'b');
    hold on
%     end
    % Choose a number between 0 (invisible) and 1 (opaque) for facealpha.  
    set(h1,'facealpha',0.5)
    set(h2,'facealpha',0.5)
    set(h3,'facealpha',0.5)
    legend('Slow','Medium','Fast','Location','best', 'FontSize',16 )
    xlabel('Frequency (Hz)', 'FontSize',16 )
    ylabel('Power spectral density (nV^2/Hz)', 'FontSize',16 )
%     title('Extensor')
    hold off
   
%%%%>>>>>>>>>>>>> DO STUFF
end

%% Running integral - cant find the source i used before?? Normalised

figure(2)
%     subplot(2,1,1)
    Q_slow_flex = cumtrapz(total_power(2:101,1));
    norm_slow_flex = Q_slow_flex/ Q_slow_flex(end);
    below = max(norm_slow_flex(norm_slow_flex < 0.5));
    below_ind = find(below == norm_slow_flex);
    above = min(norm_slow_flex(norm_slow_flex > 0.5));
    above_ind = find(above == norm_slow_flex);
    interp_freq_slow_flex = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5)
    plot(norm_slow_flex)
    
    hold on
    Q_med_flex = cumtrapz(total_power(2:101,2));
    norm_med_flex = Q_med_flex/ Q_med_flex(end);
    below = max(norm_med_flex(norm_med_flex < 0.5));
    below_ind = find(below == norm_med_flex);
    above = min(norm_med_flex(norm_med_flex > 0.5));
    above_ind = find(above == norm_med_flex);
    interp_freq_med_flex = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5)
    plot(norm_med_flex)
    hold on
%     else speed == 2
    Q_fast_flex = cumtrapz(total_power(2:101,3));
    
    norm_fast_flex = Q_fast_flex/ Q_fast_flex(end);
    below = max(norm_fast_flex(norm_fast_flex < 0.5));
    below_ind = find(below == norm_fast_flex);
    above = min(norm_fast_flex(norm_fast_flex > 0.5));
    above_ind = find(above == norm_fast_flex);
    interp_freq_fast_flex = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5)
    plot(norm_fast_flex)
    hold on
%     end
    % Choose a number between 0 (invisible) and 1 (opaque) for facealpha.  
    legend('Slow','Medium','Fast','Location','best','FontSize', 16)
    xlabel('Frequency (Hz)','FontSize', 16)
    ylabel('Spectral distribution function','FontSize', 16)
%     title('Flexor')
    hold off
    
%     subplot(2,1,2)
figure(3)
    Q_slow_extensor = cumtrapz(total_power(2:101,4));
    norm_slow_extensor = Q_slow_extensor/ Q_slow_extensor(end);
    below = max(norm_slow_extensor(norm_slow_extensor < 0.5));
    below_ind = find(below == norm_slow_extensor);
    above = min(norm_slow_extensor(norm_slow_extensor > 0.5));
    above_ind = find(above == norm_slow_extensor);
    interp_freq_slow_extensor = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5)
    plot(norm_slow_extensor)
    
    hold on
    Q_med_extensor = cumtrapz(total_power(2:101,5));
    norm_med_extensor = Q_med_extensor/ Q_med_extensor(end);
    below = max(norm_med_extensor(norm_med_extensor < 0.5));
    below_ind = find(below == norm_med_extensor);
    above = min(norm_med_extensor(norm_med_extensor > 0.5));
    above_ind = find(above == norm_med_extensor);
    interp_freq_med_extensor = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5)
    plot(norm_med_extensor)
    hold on
%     else speed == 2
    Q_fast_extensor = cumtrapz(total_power(2:101,6));
    
    norm_fast_extensor = Q_fast_extensor/ Q_fast_extensor(end);
    below = max(norm_fast_extensor(norm_fast_extensor < 0.5));
    below_ind = find(below == norm_fast_extensor);
    above = min(norm_fast_extensor(norm_fast_extensor > 0.5));
    above_ind = find(above == norm_fast_extensor);
    interp_freq_fast_extensor = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5)
    plot(norm_fast_extensor)
    hold on
%     end
    % Choose a number between 0 (invisible) and 1 (opaque) for facealpha.  
    legend('Slow','Medium','Fast','Location','best','FontSize', 16)
    xlabel('Frequency (Hz)','FontSize', 16)
    ylabel('Spectral distribution function','FontSize', 16)
%     title('Extensor')
    hold off
    
%% Running integral mean spectral power

figure(5)
%     subplot(2,1,1)
    Q_slow_flex = cumtrapz(total_power(2:101,1));
    mean_power_flex_slow = mean(total_power(2:101,1))
    max_power_flex_slow = max(total_power(2:101,1))
    plot(Q_slow_flex )
    
    hold on
    Q_med_flex = cumtrapz(total_power(2:101,2));
    mean_power_flex_med = mean(total_power(2:101,2))
    max_power_flex_med = max(total_power(2:101,2))
    plot(Q_med_flex)
    hold on
%     else speed == 2
    Q_fast_flex = cumtrapz(total_power(2:101,3));
    mean_power_flex_fast = mean(total_power(2:101,3))
    max_power_flex_fast = max(total_power(2:101,3))
    plot(Q_fast_flex)
    hold on
%     end
    % Choose a number between 0 (invisible) and 1 (opaque) for facealpha.  
    legend('Slow','Medium','Fast','Location','best','FontSize', 16)
    xlabel('Frequency (Hz)','FontSize', 16)
    ylabel('Power (W)','FontSize', 16)
%     title('Flexor')
    hold off
    
%     subplot(2,1,2)
figure(6)
    Q_slow_extensor = cumtrapz(total_power(2:101,4));
    mean_power_extensor_slow = mean(total_power(2:101,4))
    max_power_extensor_slow = max(total_power(2:101,4))
    plot(Q_slow_extensor)
    
    hold on
    Q_med_extensor = cumtrapz(total_power(2:101,5));
    mean_power_extensor_med = mean(total_power(2:101,5))
    max_power_extensor_med = max(total_power(2:101,5))
    plot(Q_med_extensor)
    hold on
%     else speed == 2
    Q_fast_extensor = cumtrapz(total_power(2:101,6));
    mean_power_extensor_fast = mean(total_power(2:101,6))
    max_power_extensor_fast = max(total_power(2:101,6))
    plot(Q_fast_extensor)
    hold on
%     end
    % Choose a number between 0 (invisible) and 1 (opaque) for facealpha.  
    legend('Slow','Medium','Fast','Location','best','FontSize', 16)
    xlabel('Frequency (Hz)','FontSize', 16)
    ylabel('Power (W)','FontSize', 16)
%     title('Extensor')
    hold off

%% Find integral etc for individual powers

for participant = 1:12
% figure(4)
    figure(1)
    Q_slow_flex = cumtrapz(individual_power(2:101,1, participant));
    norm_slow_flex = Q_slow_flex/ Q_slow_flex(end);
    below = max(norm_slow_flex(norm_slow_flex < 0.5));
    below_ind = find(below == norm_slow_flex);
    above = min(norm_slow_flex(norm_slow_flex > 0.5));
    above_ind = find(above == norm_slow_flex);
    slow_flex_list(participant) = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5);
    t1 = plot(norm_slow_flex, 'Color','r')
    
%     legend
    xlabel('Frequency (Hz)', 'FontSize', 16)
    ylabel('Spectral distribution function', 'FontSize', 16)
    title('Slow Flexors', 'FontSize', 16)
    hold on
    
    figure(2)
    Q_med_flex = cumtrapz(individual_power(2:101,2, participant));
    norm_med_flex = Q_med_flex/ Q_med_flex(end);
    below = max(norm_med_flex(norm_med_flex < 0.5));
    below_ind = find(below == norm_med_flex);
    above = min(norm_med_flex(norm_med_flex > 0.5));
    above_ind = find(above == norm_med_flex);
    med_flex_list(participant) = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5);
    t2 = plot(norm_med_flex, 'Color','r')
%     legend
    xlabel('Frequency (Hz)', 'FontSize', 16)
    ylabel('Spectral distribution function', 'FontSize', 16)
    title('Medium Flexors', 'FontSize', 16)
    hold on

    figure(3)
    Q_fast_flex = cumtrapz(individual_power(2:101,3, participant));
    norm_fast_flex = Q_fast_flex/ Q_fast_flex(end);
    below = max(norm_fast_flex(norm_fast_flex < 0.5));
    below_ind = find(below == norm_fast_flex);
    above = min(norm_fast_flex(norm_fast_flex > 0.5));
    above_ind = find(above == norm_fast_flex);
    fast_flex_list(participant) = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5);
    t3 = plot(norm_fast_flex, 'Color','r')
%     legend
    xlabel('Frequency (Hz)', 'FontSize', 16)
    ylabel('Spectral distribution function', 'FontSize', 16)
    title('Fast Flexors', 'FontSize', 16)
    hold on

    
    figure(4)
    Q_slow_extensor = cumtrapz(individual_power(2:101,4, participant));
    norm_slow_extensor = Q_slow_extensor/ Q_slow_extensor(end);
    below = max(norm_slow_extensor(norm_slow_extensor < 0.5));
    below_ind = find(below == norm_slow_extensor);
    above = min(norm_slow_extensor(norm_slow_extensor > 0.5));
    above_ind = find(above == norm_slow_extensor);
    slow_ext_list(participant) = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5);
    t4 = plot(norm_slow_extensor, 'Color','r')
    
%     legend
    xlabel('Frequency (Hz)', 'FontSize', 16)
    ylabel('Spectral distribution function', 'FontSize', 16)
    title('Slow Extensors', 'FontSize', 16)
    hold on
    
    figure(5)
    Q_med_extensor = cumtrapz(individual_power(2:101,5, participant));
    norm_med_extensor = Q_med_extensor/ Q_med_extensor(end);
    below = max(norm_med_extensor(norm_med_extensor < 0.5));
    below_ind = find(below == norm_med_extensor);
    above = min(norm_med_extensor(norm_med_extensor > 0.5));
    above_ind = find(above == norm_med_extensor);
    med_ext_list(participant) = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5);
    t5 = plot(norm_med_extensor, 'Color','r')
%     legend
    xlabel('Frequency (Hz)', 'FontSize', 16)
    ylabel('Spectral distribution function', 'FontSize', 16)
    title('Medium Extensors', 'FontSize', 16)
    hold on
%     else speed == 2

    figure(6)
    Q_fast_extensor = cumtrapz(individual_power(2:101,6, participant));
    
    norm_fast_extensor = Q_fast_extensor/ Q_fast_extensor(end);
    below = max(norm_fast_extensor(norm_fast_extensor < 0.5));
    below_ind = find(below == norm_fast_extensor);
    above = min(norm_fast_extensor(norm_fast_extensor > 0.5));
    above_ind = find(above == norm_fast_extensor);
    fast_ext_list(participant) = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5);
    t6 = plot(norm_fast_extensor, 'Color','r')
%     legend
    xlabel('Frequency (Hz)', 'FontSize', 16)
    ylabel('Spectral distribution function', 'FontSize', 16)
    title('Fast Extensors', 'FontSize', 16)
    hold on
    
end

figure(1)
Q_slow_flex = cumtrapz(total_power(2:101,1));
norm_slow_flex = Q_slow_flex/ Q_slow_flex(end);
below = max(norm_slow_flex(norm_slow_flex < 0.5));
below_ind = find(below == norm_slow_flex);
above = min(norm_slow_flex(norm_slow_flex > 0.5));
above_ind = find(above == norm_slow_flex);
interp_freq_slow_flex = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5)
a1 = plot(norm_slow_flex,'LineWidth',2, 'Color','b')
hold on
legend([t1, a1],{'Individual Participants', 'Mean'}, 'Location','best', 'FontSize', 16)

figure(2)
Q_med_flex = cumtrapz(total_power(2:101,2));
norm_med_flex = Q_med_flex/ Q_med_flex(end);
below = max(norm_med_flex(norm_med_flex < 0.5));
below_ind = find(below == norm_med_flex);
above = min(norm_med_flex(norm_med_flex > 0.5));
above_ind = find(above == norm_med_flex);
interp_freq_med_flex = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5)
a2 = plot(norm_med_flex,'LineWidth',2, 'Color','b')
hold on
legend([t2, a2],{'Individual Participants', 'Mean'}, 'Location','best', 'FontSize', 16)

figure(3)
%     else speed == 2
Q_fast_flex = cumtrapz(total_power(2:101,3));
norm_fast_flex = Q_fast_flex/ Q_fast_flex(end);
below = max(norm_fast_flex(norm_fast_flex < 0.5));
below_ind = find(below == norm_fast_flex);
above = min(norm_fast_flex(norm_fast_flex > 0.5));
above_ind = find(above == norm_fast_flex);
interp_freq_fast_flex = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5)
a3 = plot(norm_fast_flex,'LineWidth',2, 'Color','b')
hold on
legend([t3, a3],{'Individual Participants', 'Mean'}, 'Location','best', 'FontSize', 16)

    
%     subplot(2,1,2)
figure(4)
Q_slow_extensor = cumtrapz(total_power(2:101,4));
norm_slow_extensor = Q_slow_extensor/ Q_slow_extensor(end);
below = max(norm_slow_extensor(norm_slow_extensor < 0.5));
below_ind = find(below == norm_slow_extensor);
above = min(norm_slow_extensor(norm_slow_extensor > 0.5));
above_ind = find(above == norm_slow_extensor);
interp_freq_slow_extensor = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5)
a4 = plot(norm_slow_extensor,'LineWidth',2, 'Color','b')
hold on
legend([t4, a4],{'Individual Participants', 'Mean'}, 'Location','best', 'FontSize', 16)

figure(5)
Q_med_extensor = cumtrapz(total_power(2:101,5));
norm_med_extensor = Q_med_extensor/ Q_med_extensor(end);
below = max(norm_med_extensor(norm_med_extensor < 0.5));
below_ind = find(below == norm_med_extensor);
above = min(norm_med_extensor(norm_med_extensor > 0.5));
above_ind = find(above == norm_med_extensor);
interp_freq_med_extensor = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5)
a5 = plot(norm_med_extensor,'LineWidth',2, 'Color','b')
hold on
legend([t5, a5],{'Individual Participants', 'Mean'}, 'Location','best', 'FontSize', 16)

figure(6)
Q_fast_extensor = cumtrapz(total_power(2:101,6));

norm_fast_extensor = Q_fast_extensor/ Q_fast_extensor(end);
below = max(norm_fast_extensor(norm_fast_extensor < 0.5));
below_ind = find(below == norm_fast_extensor);
above = min(norm_fast_extensor(norm_fast_extensor > 0.5));
above_ind = find(above == norm_fast_extensor);
interp_freq_fast_extensor = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5)
a6 = plot(norm_fast_extensor,'LineWidth',2, 'Color','b')
hold on
legend([t6, a6],{'Individual Participants', 'Mean'}, 'Location','best', 'FontSize', 16)



hold off


%% Flex raw

Anova_flex_freq = [slow_flex_list(:) med_flex_list(:) fast_flex_list(:)];
[p,tbl,stats] = anova1(Anova_flex_freq)
multcompare(stats)

%% temp my_list stuff

[p,tbl,stats] = anova2(my_list)
multcompare(stats)
%%
boxplot(Anova_flex_freq)
xlabel('Participant','FontSize',20)
ylabel('Mean frequency from spectral density function','FontSize',20)
title('Flexor','FontSize',20)
%% Extend raw
Anova_extensor_freq = [slow_ext_list(:) med_ext_list(:) fast_ext_list(:)];
[p,tbl,stats] = anova1(Anova_extensor_freq)
multcompare(stats)
mean(slow_ext_list(:))
mean(med_ext_list(:))
mean(fast_ext_list(:))
%% All raw
Anova_all_freq = [slow_flex_list(:) med_flex_list(:) fast_flex_list(:) slow_ext_list(:) med_ext_list(:) fast_ext_list(:)];
[p,tbl,stats] = anova1(Anova_all_freq)
multcompare(stats)



%% Now check relaxed phase,is there stat diff there?
individual_power_flex = zeros(102,12);
individual_power_extend = zeros(102,12);
for ID = IDs
    ID = num2str(ID);
    folderload = 'C:\MixedRealityDevelopment\CV4Holo\Hololens2ArUcoDetection\ExperimentalAnalysis\EditedScripts\Data\Data_MATLAB\EMG_Frequency';
    filecalib = ['\Frequency_EMG_Calib' ID];
    load([folderload filecalib]);
    fn = fieldnames(EMG_Frequency);
    %%% could do something to filter the velocites first and then calc mean
    %%% IEMG and smoothness...
    ID = str2num(ID);
    
    temp_power_flex = Calib_Frequency.Power_flex_calib;
    temp_power_extend = Calib_Frequency.Power_extend_calib;
    temp_freq = Calib_Frequency.freqs_calib;
    
    
    
    % bin the spectral data into 1Hz categories
    [B,idx] = histc(temp_freq,0:1:100);
    idx_filt= idx(idx<=100);
    temp_flex = accumarray(idx_filt(:),temp_power_flex(idx<=100),[],@mean);
    temp_extend = accumarray(idx_filt(:),temp_power_extend(idx<=100),[],@mean);
%     plot(0:1:99, temp_flex)
%     hold on

    individual_power_flex(:, ID-5) = [0; temp_flex; 0];
    individual_power_extend(:, ID-5) = [0; temp_extend; 0];
    
end

%%
for calib_part = 1:12
    
    Q_calib_flex = cumtrapz(individual_power_flex(2:101, calib_part));
    norm_calib_flex = Q_calib_flex/ Q_calib_flex(end);
    below = max(norm_calib_flex(norm_calib_flex < 0.5));
    below_ind = find(below == norm_calib_flex);
    above = min(norm_calib_flex(norm_calib_flex > 0.5));
    above_ind = find(above == norm_calib_flex);
    calib_flex_list(calib_part) = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5);
    
    Q_calib_extensor = cumtrapz(individual_power_extend(2:101, calib_part));
    norm_calib_extensor = Q_calib_extensor/ Q_calib_extensor(end);
    below = max(norm_calib_extensor(norm_calib_extensor < 0.5));
    below_ind = find(below == norm_calib_extensor);
    above = min(norm_calib_extensor(norm_calib_extensor > 0.5));
    above_ind = find(above == norm_calib_extensor);
    calib_extensor_list(calib_part) = above_ind - (above_ind - below_ind)/(above - below) * (above - 0.5);
    
end

%% stat tests with calibration
Anova_flex_freq_calib = [slow_flex_list(:) med_flex_list(:) fast_flex_list(:) calib_flex_list(:)];
[p,tbl,stats] = anova1(Anova_flex_freq_calib)
multcompare(stats)
%% Extend raw
Anova_extensor_freq_calib = [slow_ext_list(:) med_ext_list(:) fast_ext_list(:) calib_extensor_list(:)];
[p,tbl,stats] = anova1(Anova_extensor_freq_calib)
multcompare(stats)
%% All raw
Anova_all_freq_calib = [slow_flex_list(:) med_flex_list(:) fast_flex_list(:) slow_ext_list(:) med_ext_list(:) fast_ext_list(:) calib_flex_list(:) calib_extensor_list(:)];
[p,tbl,stats] = anova1(Anova_all_freq_calib)
multcompare(stats)

%% Also plot with the calibration rest phase

%% Running integral mean spectral power

figure(5)
    subplot(2,1,1)
    plot(norm_slow_flex )
    hold on
    plot(norm_med_flex)
    hold on
    plot(norm_fast_flex)
    hold on
    plot(norm_calib_flex)
    hold on
%     end
    % Choose a number between 0 (invisible) and 1 (opaque) for facealpha.  
    legend('Slow','Medium','Fast','Calib','Location','best','FontSize',16)
    xlabel('Frequency (Hz)')
    ylabel('Power (W)')
    title('Flexor')
    hold off
    
    subplot(2,1,2)
    plot(norm_slow_extensor)
    hold on
    plot(norm_med_extensor)
    hold on
    plot(norm_fast_extensor)
    hold on
    plot(norm_calib_extensor)
    hold on
%     end
    % Choose a number between 0 (invisible) and 1 (opaque) for facealpha.  
    legend('Slow','Medium','Fast','Calib','Location','best','FontSize',16)
    xlabel('Frequency (Hz)')
    ylabel('Power (W)')
    title('Extensor')
    hold off
    
%% spectral analysis plots with the calibration rest phase
individual_power_flex_mean = mean(individual_power_flex,2);
individual_power_extensor_mean = mean(individual_power_extend,2);
figure(6)
    subplot(2,1,1)
    h1 = patch(freqs,total_power(:,1),'r');
    hold on
%     elseif speed == 1
    h2 = patch(freqs,total_power(:,2),'y');
    hold on
%     else speed == 2
    h3 = patch(freqs,total_power(:,3),'b');
    hold on
    
    h4 = patch(freqs, individual_power_flex_mean(:), 'g')
    hold on
    
%     end
    % Choose a number between 0 (invisible) and 1 (opaque) for facealpha.  
    set(h1,'facealpha',0.5)
    set(h2,'facealpha',0.5)
    set(h3,'facealpha',0.5)
    set(h4,'facealpha',0.5)
    legend('Slow','Medium','Fast','Rest','Location','best')
    xlabel('Frequency (Hz)')
    ylabel('Spectral Power (W/Hz)')
    title('Flexor')
%     ylim([0 15000])
    hold off
    
%     figure(2)
    subplot(2,1,2)
    h1 = patch(freqs,total_power(:,4),'r');
    hold on
%     elseif speed == 1
    h2 = patch(freqs,total_power(:,5),'y');
    hold on
%     else speed == 2
    h3 = patch(freqs,total_power(:,6),'b');
    hold on
%     end
    % Choose a number between 0 (invisible) and 1 (opaque) for facealpha.  
    set(h1,'facealpha',0.5)
    set(h2,'facealpha',0.5)
    set(h3,'facealpha',0.5)
    legend('Slow','Medium','Fast','Location','best')
    xlabel('Frequency (Hz)')
    ylabel('Spectral Power (W/Hz)')
    title('Extensor')
    hold off
