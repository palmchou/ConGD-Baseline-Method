function con_cal_center
clear;clc;
list_path = '/data2/szhou/gesture/baseline/congd/con_list/single_label_train.list';
MFSK_train_features_dir = '/data2/szhou/gesture/baseline/MFSK_features_CON/train/';  % path to dir of features of train set
code_size = 5000; 
cell_num = 2;
oribin_num = 8;
% save the center in case that we dont need to calculate it again.
center_dir = './center_con'; 
if ~exist(center_dir,'dir')
    mkdir(center_dir);
end

[video_names] = textread(list_path, '%s');


center_file = [center_dir '/' 'center.mat'];
file_exist = exist(center_file,'file');
if file_exist
    disp('Found center file, no need to recalculate. Please use ...');
else
    % check if we saved the selected features
    train_desc_file_path = [center_dir '/' 'train_desc.mat'];
    if exist(train_desc_file_path,'file')
        disp('Found features file, loading it.');
        load(train_desc_file_path);
        disp('Features file loaded.');
    else
        disp('Read features:');
        max_rows = 1000 * 10 * 249;
        train_desc = zeros(max_rows, 1024);

        start_row = 1;
        for i=1:length(video_names)
            feature_path = [video_names{i} '.mfsk'];
            fprintf('%d/%d: %s\n', i, length(video_names), feature_path);
            [~, ~, tmp_desc]=readmosift_hoghofmbh([MFSK_train_features_dir feature_path], oribin_num,cell_num);
            [tmp_rows, ~] = size(tmp_desc);
            end_row = start_row + tmp_rows -1;
            train_desc(start_row:end_row, :) = tmp_desc;
            start_row = end_row + 1;
            fprintf('%d rows\n', end_row);
        end
        train_desc(start_row:end, :) = []; % shrink 
        save(train_desc_file_path, 'train_desc');
        disp('train_desc saved'); 
    end

    % choose x rows from train_desc randomly
    x = 200000;
    [tmp_r, tmp_c] = size(train_desc);
    train_desc = train_desc(randperm(tmp_r, x), :);
    disp('Calculating center');
    run('../vlfeat-0.9.20/toolbox/vl_setup.m')
    [center, train_idx] =vl_kmeans(train_desc', code_size, 'distance', 'l1', 'algorithm', 'elkan');
    train_idx = train_idx';
    center=center';
    save(center_file, 'center', 'train_idx');
    disp('Center file saved');
end

