clear;
load('MLWDF_outage_probability.mat');
load('PD_outage_probability.mat');

figure('name','Voice-Delay outage probability');
plot(sort(PD_delay_voice_temp), linspace(1-1/length(PD_delay_voice_temp), 0, length(PD_delay_voice_temp)),'k-');
hold on;
plot(sort(MLWDF_delay_voice_temp), linspace(1-1/length(MLWDF_delay_voice_temp), 0, length(MLWDF_delay_voice_temp)),'r-');
xlabel('Voice packet delay (ms)');
ylabel('Delay outage probability');
legend('PD','M-LWDF','location','NorthEast');
grid on;

figure('name','Video-Delay outage probability');
plot(sort(PD_delay_video_temp), linspace(1-1/length(PD_delay_video_temp), 0, length(PD_delay_video_temp)),'k-');
hold on;
plot(sort(MLWDF_delay_video_temp), linspace(1-1/length(MLWDF_delay_video_temp), 0, length(MLWDF_delay_video_temp)),'r-');
xlabel('Video packet delay (ms)');
ylabel('Delay outage probability');
legend('PD','M-LWDF','location','NorthEast');
grid on;

figure('name','BE packet delay');
plot(sort(PD_delay_BE_temp), linspace(1-1/length(PD_delay_BE_temp), 0, length(PD_delay_BE_temp)),'k-');
hold on;
plot(sort(MLWDF_delay_BE_temp), linspace(1-1/length(MLWDF_delay_BE_temp), 0, length(MLWDF_delay_BE_temp)),'r-');
xlabel('BE packet delay (ms)');
ylabel('Delay outage probability');
legend('PD','M-LWDF','location','NorthEast');
grid on;

flag=1;