clear;
clc;

%-------------%
P_total=1;
Eb_N0_dB=20;
T_slot=2;
B=5e6;
N_path=6;
N_channel=1;
user_set=8:8:72;
N_user_set=length(user_set);
N_user_max=user_set(N_user_set);
N_sc=512;
N_slot=2000;
N_service_type=4;
N_packet=N_slot*T_slot;
U=[100 400 1000];
U_voice=U(1);
U_video=U(2);
U_BE=U(3);
N_service=[100 400 1000];
N_voice=N_service(1);
N_video=N_service(2);
N_BE=N_service(3);
QoS=[1024 512 1];
G=1;

Delta=[0.05,0.05,0.77];
% %_____________%
MLWDF_delay_voice_avg=zeros(1,N_user_set);
MLWDF_delay_video_avg=zeros(1,N_user_set);
MLWDF_delay_BE_avg=zeros(1,N_user_set);
MLWDF_capacity_MWC_eq=zeros(1,N_user_set);
MLWDF_capacity_MWC_WWF=zeros(1,N_user_set);
MLWDF_pkt_drop_rate_voice=zeros(1,N_user_set);
MLWDF_pkt_drop_rate_video=zeros(1,N_user_set);
MLWDF_pkt_drop_rate_BE=zeros(1,N_user_set);
% Raw_data_temp=Raw_data;
for user_set_index=1:N_user_set
    N_user=user_set(user_set_index);
    %-------------%
    T_duration_mean=160;
    Raw_data=zeros(N_service_type*N_user,N_packet);
    % Assumption
    % Voice in bits
    Packet_voice=64;
    Raw_data(1:N_service_type:end,:)=Packet_voice;
    % Video in bits
    Packet_video_max=420;
    Packet_video_min=120;
    Packet_video_avg=239;
    pd=makedist('Exponential','mu',Packet_video_avg);
    Video_dist=truncate(pd,Packet_video_min,Packet_video_max);
    for user_index=1:N_user
        N_packet_left=N_slot*T_slot;
        Position=1;
        while (N_packet_left>0)
            Duration=fix(exprnd(T_duration_mean));
            if Duration<N_packet_left
                Raw_data(N_service_type*(user_index-1)+2,Position:Position+Duration-1)=random(Video_dist);
                N_packet_left=N_packet_left-Duration;
                Position=Position+Duration;
            else
                Raw_data(N_service_type*(user_index-1)+2,Position:Position+N_packet_left-1)=random(Video_dist);
                Position=Position+N_packet_left;
                N_packet_left=0;
            end
        end
    end
    % BE in bits
    Packet_BE=500;
    Raw_data(3:N_service_type:end,:)=Packet_BE;
    %-------------%
    Raw_data_voice=Raw_data(1:N_service_type:end,:);
    Raw_data_video=Raw_data(2:N_service_type:end,:);
    Raw_data_BE=Raw_data(3:N_service_type:end,:);
    Raw_data_slot=Raw_data_voice+Raw_data_video+Raw_data_BE;
    Raw_data_delay=zeros(N_user*N_service_type,N_packet);
    Data_slot=zeros(N_user,N_slot);
    buffer=0;
    delay_voice=ones(N_user,N_packet)*U_voice;
    delay_video=ones(N_user,N_packet)*U_video;
    delay_BE=ones(N_user,N_packet)*U_BE;
    delay_voice_buf=zeros(N_user,N_packet);
    delay_video_buf=zeros(N_user,N_packet);
    delay_BE_buf=zeros(N_user,N_packet);
    pkt_voice=0;
    pkt_video=0;
    pkt_BE=0;
    d_voice=0;
    d_video=0;
    d_BE=0;
    pkt_voice_status=zeros(N_user,N_packet);
    pkt_video_status=zeros(N_user,N_packet);
    pkt_BE_status=zeros(N_user,N_packet);
    for Slot_current=1:N_slot
        [R_MWC_eq_user(:,:,Slot_current),R_RD_eq_user(:,:,Slot_current),R_MWC_WWF_user(:,:,Slot_current)...
            ,R_RD_WWF_user(:,:,Slot_current),Data_queue,W_voice,W_video,W_BE]=PHY_MLWDF_user_basic...
            (Slot_current,Raw_data,B,N_sc,N_user,T_slot,N_slot,Eb_N0_dB,P_total,N_path,N_channel,U,Delta...
            ,user_set_index,N_service_type,N_user_set,N_user_max);
        %         [R_MWC_eq_user,R_RD_eq_user,R_MWC_WWF_user,R_RD_WWF_user,Data_MLWDF,...
        %     W_voice,W_video,W_BE]...
        %     =MWC_MLWDF_func_example(Slot_current,Raw_data,B,N_sc,N_user,T_slot,N_slot,Eb_N0_dB,P_total,N_path,N_channel,U,Delta,QoS)
        MLWDF_capacity_MWC_eq_slot(user_set_index,Slot_current)=sum(R_MWC_eq_user(user_set_index,:,Slot_current));
        MLWDF_capacity_MWC_WWF_slot(user_set_index,Slot_current)=sum(R_MWC_WWF_user(user_set_index,:,Slot_current));
        Data_slot(:,Slot_current)=Raw_data_slot(:,2*Slot_current-1)+Raw_data_slot(:,2*Slot_current);
        W_voice_temp=W_voice(:,Slot_current);
        W_video_temp=W_video(:,Slot_current);
        W_BE_temp=W_BE(:,Slot_current);
%         Data(:,Slot_current)=Data_slot(:,Slot_current);
        buffer=buffer+Data_slot(:,Slot_current);
        capability=(T_slot*1e-3)*R_MWC_WWF_user(user_set_index,:,Slot_current)';
%         flag=buffer-capability;
        throughput_user=zeros(1,N_user);
        for user_index=1:N_user
            data_pkt_temp=0;
            throughput_temp=0;
            Weight_max=0;
            while (R_MWC_WWF_user(user_set_index,user_index,Slot_current)>B*throughput_temp)
                Weight_max=max([W_voice_temp(user_index),W_video_temp(user_index),W_BE_temp(user_index)]);
                if isnan(Weight_max)
                    break;
                end
                if Weight_max==W_voice_temp(user_index)
                    pkt_index=find(Raw_data((user_index-1)*N_service_type+1,1:Slot_current*T_slot)~=0,1,'first');
                    if isempty(pkt_index)
                        W_voice_temp(user_index)=NaN;
                        continue;
                    end
                    data_pkt_temp=data_pkt_temp+Raw_data((user_index-1)*N_service_type+1,pkt_index);
                    throughput_temp=data_pkt_temp/(B*T_slot*1e-3);
                    delay_voice_temp=Slot_current*T_slot-pkt_index;
                    if R_MWC_WWF_user(user_set_index,user_index,Slot_current)>B*throughput_temp && delay_voice_temp<U_voice
                        pkt_voice_status(user_index,pkt_index)=1;
                        buffer(user_index)=buffer(user_index)-Raw_data((user_index-1)*N_service_type+1,pkt_index);
                        Raw_data((user_index-1)*N_service_type+1,pkt_index)=0;
                        delay_voice(user_index,pkt_index)=delay_voice_temp;
                        pkt_voice=pkt_voice+1;
                        throughput_user(user_index)=throughput_temp;
                    end
                    if delay_voice_temp>=U_voice
                        buffer(user_index)=buffer(user_index)-Raw_data((user_index-1)*N_service_type+1,pkt_index);
                        Raw_data((user_index-1)*N_service_type+1,pkt_index)=0;
                        pkt_voice_status(user_index,pkt_index)=NaN;
                    end
                elseif Weight_max==W_video_temp(user_index)
                    pkt_index=find(Raw_data((user_index-1)*N_service_type+2,1:Slot_current*T_slot)~=0,1,'first');
                    if isempty(pkt_index)
                        W_video_temp(user_index)=NaN;
                        continue;
                    end
                    data_pkt_temp=data_pkt_temp+Raw_data((user_index-1)*N_service_type+2,pkt_index);
                    throughput_temp=data_pkt_temp/(B*T_slot*1e-3);
                    delay_video_temp=Slot_current*T_slot-pkt_index;
                    if R_MWC_WWF_user(user_set_index,user_index,Slot_current)>B*throughput_temp && delay_video_temp<U_video
                        pkt_video_status(user_index,pkt_index)=1;
                        buffer(user_index)=buffer(user_index)-Raw_data((user_index-1)*N_service_type+2,pkt_index);
                        Raw_data((user_index-1)*N_service_type+2,pkt_index)=0;
                        delay_video(user_index,pkt_index)=delay_video_temp;
                        pkt_video=pkt_video+1;
                        throughput_user(user_index)=throughput_temp;
                    end
                    if delay_video_temp>=U_video
                        buffer(user_index)=buffer(user_index)-Raw_data((user_index-1)*N_service_type+2,pkt_index);
                        Raw_data((user_index-1)*N_service_type+2,pkt_index)=0;
                        pkt_video_status(user_index,pkt_index)=NaN;
                    end
                elseif Weight_max==W_BE_temp(user_index)
                    pkt_index=find(Raw_data((user_index-1)*N_service_type+3,1:Slot_current*T_slot)~=0,1,'first');
                    if isempty(pkt_index)
                        W_BE_temp(user_index)=NaN;
                        continue;
                    end
                    data_pkt_temp=data_pkt_temp+Raw_data((user_index-1)*N_service_type+3,pkt_index);
                    throughput_temp=data_pkt_temp/(B*T_slot*1e-3);
                    delay_BE_temp=Slot_current*T_slot-pkt_index;
                    if R_MWC_WWF_user(user_set_index,user_index,Slot_current)>B*throughput_temp && delay_BE_temp<U_BE
                        pkt_BE_status(user_index,pkt_index)=1;
                        buffer(user_index)=buffer(user_index)-Raw_data((user_index-1)*N_service_type+3,pkt_index);
                        Raw_data((user_index-1)*N_service_type+3,pkt_index)=0;
                        delay_BE(user_index,pkt_index)=delay_BE_temp;
                        pkt_BE=pkt_BE+1;
                        throughput_user(user_index)=throughput_temp;
                    end
                    if delay_BE_temp>=U_BE
                        buffer(user_index)=buffer(user_index)-Raw_data((user_index-1)*N_service_type+3,pkt_index);
                        Raw_data((user_index-1)*N_service_type+3,pkt_index)=0;
                        pkt_BE_status(user_index,pkt_index)=NaN;
                    end
                end
            end
        end
        
        MLWDF_throughput_slot(user_set_index,Slot_current)=sum(throughput_user);
        %         delay_voice_temp=~pkt_voice_status*T_slot;
        %         delay_voice_temp(:,Slot_current*T_slot+1:N_packet)=0;
        %         delay_voice_buf=delay_voice_buf+delay_voice_temp;
        %         delay_video_temp=~pkt_video_status*T_slot;
        %         delay_video_temp(:,Slot_current*T_slot+1:N_packet)=0;
        %         delay_video_buf=delay_video_buf+delay_video_temp;
        %         delay_BE_temp=~pkt_BE_status*T_slot;
        %         delay_BE_temp(:,Slot_current*T_slot+1:N_packet)=0;
        %         delay_BE_buf=delay_BE_buf+delay_BE_temp;
        
        %         delay_voice(~pkt_voice_status)=delay_voice(~pkt_voice_status)+T_slot;
        %         delay_voice(:,Slot_current*T_slot+1:U_voice)=0;
        %         delay_video(~pkt_video_status)=delay_video(~pkt_video_status)+T_slot;
        %         delay_video(:,Slot_current*T_slot+1:U_video)=0;
        %         delay_BE(~pkt_BE_status)=delay_BE(~pkt_BE_status)+T_slot;
        %         delay_BE(:,Slot_current*T_slot+1:U_BE)=0;
        
    end
    %     delay_voice_slot(isnan(delay_voice_slot))=U_voice;
    %     delay_video_slot(isnan(delay_video_slot))=U_video;
    %     delay_BE_slot(isnan(delay_BE_slot))=U_BE;
    
    %     delay_voice_temp=delay_voice;
    %     delay_voice_temp(delay_voice_temp==U_voice)=0;
    %     delay_voice_pos=find(delay_voice_temp(:)~=0);
    %     pkt_voice_final=length(delay_voice_pos);
    
    
    delay_voice_buffer=delay_voice(:,1:N_slot*T_slot-U_voice);
    MLWDF_delay_voice_avg(user_set_index)=sum(delay_voice_buffer(:))/(N_slot*T_slot-U_voice)/N_user;
    pkt_drop_voice=length(find(delay_voice_buffer(:)==U_voice));
    MLWDF_pkt_drop_rate_voice(user_set_index)=pkt_drop_voice/numel(delay_voice_buffer);
    
    %     delay_video_temp=delay_video;
    %     delay_video_temp(delay_video_temp==U_video)=0;
    %     delay_video_pos=find(delay_video_temp(:)~=0);
    %     pkt_video_final=length(delay_video_pos);
    delay_video_buffer=delay_video(:,1:N_slot*T_slot-U_video);
    MLWDF_delay_video_avg(user_set_index)=sum(delay_video_buffer(:))/(N_slot*T_slot-U_video)/N_user;
    pkt_drop_video=length(find(delay_video_buffer(:)==U_video));
    MLWDF_pkt_drop_rate_video(user_set_index)=pkt_drop_video/numel(delay_video_buffer);
    
    %     delay_BE_temp=delay_BE;
    %     delay_BE_temp(delay_BE_temp==U_BE)=0;
    %     delay_BE_pos=find(delay_BE_temp(:)~=0);
    %     pkt_BE_final=length(delay_BE_pos);
    delay_BE_buffer=delay_BE(:,1:N_slot*T_slot-U_BE);
    MLWDF_delay_BE_avg(user_set_index)=sum(delay_BE_buffer(:))/(N_slot*T_slot-U_BE)/N_user;
    pkt_drop_BE=length(find(delay_BE_buffer(:)==U_BE));
    MLWDF_pkt_drop_rate_BE(user_set_index)=pkt_drop_BE/numel(delay_BE_buffer);
    
    %         delay_voice_avg(user_set_index)=delay_voice_avg(user_set_index)+sum(sum(delay_voice(:,1:N_packet-U_voice)))/(N_packet-U_voice)/N_user;
    %         delay_video_avg(user_set_index)=delay_video_avg(user_set_index)+sum(sum(delay_video(:,1:N_packet-U_video)))/(N_packet-U_video)/N_user;
    %         delay_BE_avg(user_set_index)=delay_BE_avg(user_set_index)+sum(sum(delay_BE(:,1:N_packet-U_BE)))/(N_packet-U_BE)/N_user;
    
    %     delay_voice_avg(user_set_index)=delay_voice_sum(user_set_index)/N_user;
    %     delay_video_avg(user_set_index)=delay_video_sum(user_set_index)/N_user;
    %     delay_BE_avg(user_set_index)=delay_BE_sum(user_set_index)/N_user;
    
    %      delay_voice_avg(user_set_index)=mean(delay_voice_slot(:));
    %      delay_video_avg(user_set_index)=mean(delay_video_slot(:));
    %      delay_BE_avg(user_set_index)=mean(delay_BE_slot(:));
    %      throughput(user_set_index)=mean(throughput_slot(user_set_index,:));
    
    %     delay_voice_avg(user_set_index)=d_voice/pkt_voice;
    %     delay_video_avg(user_set_index)=d_video/pkt_video;
    %     delay_BE_avg(user_set_index)=d_BE/pkt_BE;
    MLWDF_throughput(user_set_index)=mean(MLWDF_throughput_slot(user_set_index,:));
    MLWDF_capacity_MWC_eq(user_set_index)=mean(MLWDF_capacity_MWC_eq_slot(user_set_index,:));
    MLWDF_capacity_MWC_WWF(user_set_index)=mean(MLWDF_capacity_MWC_WWF_slot(user_set_index,:));
end
testflag=1;
save MLWDF_user_basic.mat Eb_N0_dB MLWDF_delay_voice_avg MLWDF_delay_video_avg MLWDF_delay_BE_avg...
    MLWDF_pkt_drop_rate_voice MLWDF_pkt_drop_rate_video MLWDF_pkt_drop_rate_BE...
    MLWDF_throughput user_set
% copyfile(sourcePath1,targetPath1);


Save_MLWDF;

disp("=================== Result_MLWDF_user_basic::finish===================");