clear;
load('PD_user_advanced.mat');
load('MLWDF_user_advanced.mat');

figure('name','Average voice packet delay');
plot(user_set,PD_delay_voice_avg,'k^--');
hold on;
plot(user_set,MLWDF_delay_voice_avg,'ro-');
xlabel('The number of users');
ylabel('Average voice packet delay (ms)');
legend('PD','M-LWDF','location','NorthWest');
grid on;

figure('name','Average video packet delay');
plot(user_set,PD_delay_video_avg,'k^--');
hold on;
plot(user_set,MLWDF_delay_video_avg,'ro-');
xlabel('The number of users');
ylabel('Average video packet delay (ms)');
legend('PD','M-LWDF','location','NorthWest');
grid on;

figure('name','Average video packet delay');
plot(user_set,PD_pkt_drop_rate_BE,'k^--');
hold on;
plot(user_set,MLWDF_pkt_drop_rate_BE,'ro-');
xlabel('The number of users');
ylabel('BE packet drop rate');
legend('PD','M-LWDF','location','NorthWest');
grid on;

flag=1;