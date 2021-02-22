user_set=8:8:72;
Eb_N0_dB=20;
PD_delay_voice_avg=[1.2982 1.5760 4.3942 5.4381 7.1031 8.5788 9.8595 11.0639 12.7200];
PD_delay_video_avg=[1.4258 3.9098 7.1031 12.9987 21.1444 37.0639 77.4927 181.0575 351.7972];
PD_pkt_drop_rate_voice=[0 0 0 0 0 0 0 0 0];
PD_pkt_drop_rate_video=[0 0 0 0 0 0 1.0417e-04 0.0027 0.0083]; %modified
PD_pkt_drop_rate_BE=[0 0 0 0.3826 0.6439 0.7991	0.8819	0.9401	0.9739];
PD_throughput=[1.3152 2.3776 3.1913	3.4383	3.5861	3.7603	3.8541 3.9212 4.0157];


save PD_user_advanced.mat user_set Eb_N0_dB PD_delay_voice_avg PD_delay_video_avg PD_pkt_drop_rate_voice...
    PD_pkt_drop_rate_video PD_pkt_drop_rate_BE PD_throughput