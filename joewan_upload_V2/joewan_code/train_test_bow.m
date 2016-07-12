function [train_hist, All_hist, video_gestures]= train_test_bow(descr_dir,segment_inf,...
    train_label,data_num,codebook_size,set_name,center_dir,feature_type,coding_type)

video_gestures = zeros(length(segment_inf),1);
for i=1:length(segment_inf)
    video_gestures(i) = size(segment_inf{i},1);
end

train_num = length(train_label);
[train_desc, train_desc_num]=extract_all_train_descriptor...
    (descr_dir,train_num,feature_type);
% save train_data.mat train_desc train_desc_num
% load train_data

train_len = size(train_desc,1);
code_size = floor(codebook_size*train_len);
name = [center_dir '\' set_name '_center.mat'];
file_exist = exist(name,'file');
if file_exist
    load(name);
else
        [center, train_idx] =vl_kmeans(train_desc', code_size, 'distance', 'l1', 'algorithm', 'elkan');
        train_idx = train_idx'; center=center';
        save(name, 'center', 'train_idx');
end

if strcmp(coding_type,'VQ')
    [train_hist, All_hist]=get_hist(descr_dir,train_desc_num,data_num,...
        train_num,code_size,video_gestures,train_idx,center,feature_type);
elseif strcmp(coding_type,'SOMP')
    [train_hist, All_hist]=get_hist_SOMP(descr_dir,data_num,train_num,...
        code_size,video_gestures,center',feature_type);
else
    error('please define the coding_type: VQ, SOMP;');
end   




%  save hist_inf.mat train_hist All_hist
% load hist_inf

function [train_hist, All_hist]=get_hist(descr_dir,train_desc_num,data_num,...
    train_num,codebook_size,video_gestures,train_idx,center,feature_type)
train_cum = cumsum(train_desc_num);
train_cum = [0; train_cum];
train_hist = zeros(train_num,codebook_size);
All_hist = zeros(sum(video_gestures),codebook_size);
count=1;
for i=1:data_num
    if i<=train_num %train data
        idx = train_idx(train_cum(i)+1:train_cum(i+1));
        tmp_hist = kmeans2d_hist(codebook_size,idx);
        train_hist(i,:) = tmp_hist;
        All_hist(count,:) = tmp_hist;
        count = count + 1;
    else% testing data
        gesture_num =  video_gestures(i);
        if gesture_num==1
            mosiftname = [descr_dir '\K_' num2str(i) '.csv'];
            
            if strcmp(feature_type,'MFSK')
                cell_num = 2;
                oribin_num = 8;
                [~, ~, tmp_desc]=readmosift_hoghofmbh(mosiftname,oribin_num,cell_num);
            else
                [~,~,tmp_desc]=readmosift(mosiftname,feature_type);
            end
            
            hist = calhist_from_centers(tmp_desc, center,codebook_size);
            All_hist(count,:) = hist;
            count = count + 1;
        elseif gesture_num>1
            for j=1:gesture_num
                mosiftname = [descr_dir '\K_' num2str(i) '_' num2str(j) '.csv'];
                if strcmp(feature_type,'MFSK')
                    cell_num = 2;
                    oribin_num = 8;
                    [~, ~, tmp_desc]=readmosift_hoghofmbh(mosiftname,oribin_num,cell_num);
                else
                    [~,~,tmp_desc]=readmosift(mosiftname,feature_type);
                end
                hist = calhist_from_centers(tmp_desc, center,codebook_size);
                All_hist(count,:) = hist;
                count = count + 1;
            end
        else
        end  
    end
end

%%
function [train_hist, All_hist]=get_hist_SOMP(descr_dir,data_num,train_num,...
    codebook_size,video_gestures,center,feature_type)
% parameter of the optimization procedure are chosen
%param.L=10; % not more than 10 non-zeros coefficients
nonzero_num=10;
param.L= nonzero_num;
param.eps=0.000001; % squared norm of the residual should be less than 0.1
param.numThreads=-1; % number of processors/cores to use; the default choice is -1
                    % and uses all the cores of the machine            
                    
train_hist = zeros(train_num,codebook_size);
All_hist = zeros(sum(video_gestures),codebook_size);
count=1;

center = center - repmat(mean(center),[size(center,1) 1]);

center=center./repmat(sqrt(sum(center.^2)),[size(center,1) 1]);
cc = descr_dir(end-6:end);
for i=1:data_num
    if i<=train_num %train data
        mosiftname = [descr_dir '\K_' num2str(i) '.csv'];
        if strcmp(feature_type,'MFSK')
            cell_num = 2;
            oribin_num = 8;
            [~, ~, tmp_desc]=readmosift_hoghofmbh(mosiftname,oribin_num,cell_num);
        else
            [~,~,tmp_desc]=readmosift(mosiftname,feature_type);
        end
%         mosiftname = [descr_dir '\K_' num2str(i) '.mat'];
%         load(mosiftname); tmp_desc=descr;
        if strcmp(cc,'devel05')
            tmp_desc = tmp_desc(1:10:end,:);
        end
        if strcmp(cc,'devel16')
            tmp_desc = tmp_desc(1:2:end,:);
        end
        if strcmp(cc,'devel08')
            tmp_desc = tmp_desc(1:2:end,:);
        end
        tmp_desc = tmp_desc' ; 
        tmp_desc = tmp_desc - repmat(mean(tmp_desc),[size(tmp_desc,1) 1]);
        tmp_desc=tmp_desc./repmat(sqrt(sum(tmp_desc.^2)),[size(tmp_desc,1) 1]);
        ind_groups = int32(0:1:(size(tmp_desc,2)-1)); % indices of the first signals in each group
        alpha=mexSOMP(tmp_desc,center,ind_groups,param);
        tmp_hist = hist_SC(alpha);
        train_hist(i,:) = tmp_hist;
        All_hist(count,:) = tmp_hist;
        count = count + 1;
    else% testing data
        gesture_num =  video_gestures(i);
        if gesture_num==1
            mosiftname = [descr_dir '\K_' num2str(i) '.csv'];
            if strcmp(feature_type,'MFSK')
                cell_num = 2;
                oribin_num = 8;
                [~, ~, tmp_desc]=readmosift_hoghofmbh(mosiftname,oribin_num,cell_num);
            else
                [~,~,tmp_desc]=readmosift(mosiftname,feature_type);
            end
%             mosiftname = [descr_dir '\K_' num2str(i) '.mat'];
%             load(mosiftname); tmp_desc=descr;
            if strcmp(cc,'devel05')
                tmp_desc = tmp_desc(1:10:end,:);
            end
            if strcmp(cc,'devel16')
                tmp_desc = tmp_desc(1:2:end,:);
            end
            if strcmp(cc,'devel08')
                tmp_desc = tmp_desc(1:2:end,:);
            end
            tmp_desc = tmp_desc' ;
            tmp_desc = tmp_desc - repmat(mean(tmp_desc),[size(tmp_desc,1) 1]);
            tmp_desc=tmp_desc./repmat(sqrt(sum(tmp_desc.^2)),[size(tmp_desc,1) 1]);
            ind_groups = int32(0:1:(size(tmp_desc,2)-1)); % indices of the first signals in each group
            alpha=mexSOMP(tmp_desc,center,ind_groups,param);
            hist = hist_SC(alpha);
            All_hist(count,:) = hist;
            count = count + 1;
        elseif gesture_num>1
            for j=1:gesture_num
                mosiftname = [descr_dir '\K_' num2str(i) '_' num2str(j) '.csv'];
                if strcmp(feature_type,'MFSK')
                    cell_num = 2;
                    oribin_num = 8;
                    [~, ~, tmp_desc]=readmosift_hoghofmbh(mosiftname,oribin_num,cell_num);
                else
                    [~,~,tmp_desc]=readmosift(mosiftname,feature_type);
                end
%                  mosiftname = [descr_dir '\K_' num2str(i) '_' num2str(j) '.mat'];
%                 load(mosiftname); tmp_desc=descr;
                if strcmp(cc,'devel05')
                    tmp_desc = tmp_desc(1:10:end,:);
                end
                if strcmp(cc,'devel16')
                    tmp_desc = tmp_desc(1:2:end,:);
                end
                if strcmp(cc,'devel08')
                    tmp_desc = tmp_desc(1:2:end,:);
                end
                tmp_desc = tmp_desc' ; 
                tmp_desc = tmp_desc - repmat(mean(tmp_desc),[size(tmp_desc,1) 1]);
                tmp_desc=tmp_desc./repmat(sqrt(sum(tmp_desc.^2)),[size(tmp_desc,1) 1]);
                ind_groups = int32(0:1:(size(tmp_desc,2)-1)); % indices of the first signals in each group
                alpha=mexSOMP(tmp_desc,center,ind_groups,param);
                hist = hist_SC(alpha);
                All_hist(count,:) = hist;
                count = count + 1;
            end
        else
        end  
    end
end

%sc_codes:m*n; m:dictionary size; n: feature length
%hist: 1*n
function hist = hist_SC(sc_codes)
hist = full( mean(sc_codes,2)) ;
hist = hist';
hist = hist/norm(hist,2);

%%
function [train_desc, train_desc_num]=extract_all_train_descriptor...
    (descr_dir,train_num,feature_type)
train_desc = [];
train_desc_num = zeros(train_num,1);
for i=1:train_num
    mosiftname = [descr_dir '\K_' num2str(i) '.csv'];
    if strcmp(feature_type,'MFSK')
        cell_num = 2;
        oribin_num = 8;
        [~, ~, tmp_desc]=readmosift_hoghofmbh(mosiftname,oribin_num,cell_num);
    else
        [~,~,tmp_desc]=readmosift(mosiftname,feature_type);
    end
    train_desc = [train_desc ; tmp_desc];
    train_desc_num(i) = size(tmp_desc,1);
end

%% calcuate histogram
function hist = kmeans2d_hist(cluster_number,idx)
hist = zeros(1,cluster_number);
for i=1:length(idx)
    hist(idx(i)) = hist(idx(i)) +1;
end
hist = hist/norm(hist,2);


function hist = calhist_from_centers(descr, center,codebook_size)
distance = eucliddist(descr,center);
[c idx] = min(distance,[],2);
hist = kmeans2d_hist(codebook_size,idx);


