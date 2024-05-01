function [reverb_power] = add_reverb(reverb_type,reverb_power,far_fft_buf,freq_resp_buf,filter_quality,far_vad)
    global aec_config;
    global aec_inst;
    global fft_size;
    echo_path_gain=1;
    linear_subband_range=[1:aec_inst.linear_subused_num];
    bi            = hamming(9);
    bi            = bi./sum(bi);
    win_len       = (length(bi) - 1) / 2;
    if  strcmp(reverb_type ,'linear')
        tail_reverb_index=aec_inst.tap_start0;
    else
        %todo
    end;
    %find the base far power for the reverb
    reverb_base_pow(:,1)=far_fft_buf(:,tail_reverb_index).*conj(far_fft_buf(:,tail_reverb_index));
    tail_freq_resp(:,1)=freq_resp_buf(:,1).*conj(freq_resp_buf(:,1));
    %update the reverb estimate
    if  strcmp(reverb_type ,'linear') & far_vad
        %0.83 means a decay value, webrtc default value,but in linear or nonlinear case,we can 
        %use different value, even adaptive;
%         reverb_power(linear_subband_range,1)=(reverb_power(linear_subband_range,1)+reverb_base_pow(linear_subband_range,1).*tail_freq_resp(linear_subband_range,1))*0.73;
         reverb_power(linear_subband_range,1)=(reverb_power(linear_subband_range,1)+reverb_base_pow(linear_subband_range,1).*tail_freq_resp(linear_subband_range,1))*0.73;
    else
%         reverb_power(:,1)=(reverb_power(:,1)+reverb_base_pow(:,1).*echo_path_gain)*0.83;
    end;
    
    reverb_power_smoothed=zeros(fft_size/2,1);
    for jj = 1 : aec_inst.linear_subused_num
        start_jj = jj  - win_len;
        start_jj = max(start_jj,1);
        end_jj   = jj  + win_len;
        end_jj   = min(end_jj, aec_inst.linear_subused_num);
        for w = start_jj : end_jj
            reverb_power_smoothed(jj,1) = reverb_power_smoothed(jj,1) + reverb_power(w,1) * bi(w - jj + win_len + 1);
        end
    end
    reverb_power_smoothed(aec_inst.linear_subused_num+1:end,1)=reverb_power(aec_inst.linear_subused_num+1:end,1);
end