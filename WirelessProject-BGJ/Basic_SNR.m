clear;

load('PD_SNR_final.mat');
load('MLWDF_SNR_final.mat');

figure('name','Average voice packet delay-SNR');
plot(Eb_N0_dB,PD_delay_voice_avg,'k^--');
hold on;
plot(Eb_N0_dB,MLWDF_delay_voice_avg,'ro-');
xlabel('SNR (dB)');
ylabel('Average voice packet delay (ms)');
legend('PD','M-LWDF','location','NorthEast');
grid on;

figure('name','Average video packet delay-SNR');
plot(Eb_N0_dB,PD_delay_video_avg,'k^--');
hold on;
plot(Eb_N0_dB,MLWDF_delay_video_avg,'ro-');
xlabel('SNR (dB)');
ylabel('Average video packet delay (ms)');
legend('PD','M-LWDF','location','NorthEast');
grid on;

figure('name','Video packet drop rate-SNR');
plot(Eb_N0_dB,PD_pkt_drop_rate_video,'k^--');
hold on;
plot(Eb_N0_dB,MLWDF_pkt_drop_rate_video,'ro-');
xlabel('SNR (dB)');
ylabel('Video packet drop rate');
legend('PD','M-LWDF','location','NorthEast');
grid on;

figure('name','BE packet drop rate-SNR');
plot(Eb_N0_dB,PD_pkt_drop_rate_BE,'k^--');
hold on;
plot(Eb_N0_dB,MLWDF_pkt_drop_rate_BE,'ro-');
xlabel('SNR (dB)');
ylabel('BE packet drop rate');
legend('PD','M-LWDF','location','NorthEast');
grid on;

flag=1;