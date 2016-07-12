%% --------------- CHALEARN Gesture Challenge 2   ---------------------
% This software is written by Joewan; If you have any question, please contact me;
% email: joewan10@gmail.com
% code version: v1.0
% date: september 2012
%modified: Sep, 2013
%% for example:
% features_types = {'3D MoSIFT', '3D EMoSIFT', '3D SMoSIFT','MFSK'};
% coding_type = {'VQ','SOMP'};
% data_type ={'devel','valid','final'};    
% data_dir = 'D:\JoeWan\chaLen\Data';
% resu_file = 'D:\JoeWan\joewan\test.csv';
% parameters.feature_type = features_types{1};
% parameters.coding_type = coding_type{1};
% parameters.data_type = data_type{3}; 
% prepare_final_resut(data_dir, resu_file,parameters);

function prepare_final_resut(data_dir, resu_file,parameters)
feature_type = parameters.feature_type;
coding_type = parameters.coding_type;
type = parameters.data_type;
%%only one parameters can be changle;
codebook_size_tatio = 0.5;% the ratio of the total number of  the descriptors (trained data) 
%
% type ={'valid','final'};                 
num=1:20;
data_size = 47;
type1 = 'K';
motion_num = 9; 
with_rest_position = 0;

this_dir=pwd;
my_root     = this_dir(1:end-12);   % Change that to the directory of your project
resu_dir    = [my_root '\tmpResults']; % Where the results will end up.  
feature_dir = [my_root '\tmpfeature_results'];% save  feature results
center_dir =  [my_root '\tmpcenter_results'];% save  clustering centers by kmeans
vlfeat_path_setup = [my_root '\vlfeat\toolbox\vl_setup.m'];
code_dir    =pwd; 
run(vlfeat_path_setup);
warning off; 
addpath(genpath(code_dir)); 
warning on;
round = 2;
makedir(resu_dir);
makedir(center_dir);
tt=clock;

fprintf('\n==========================================\n');
fprintf('============    %s DATA', type);
if strcmp(type, 'final') && round==2, num=num+20; fprintf('%d', round); else fprintf(' '); end
fprintf('   ============\n==========================================\n');
for i=1:length(num)
    set_name=sprintf('%s%02d', type, num(i));
    fprintf('%s\t', set_name);

    % Load training and test data
    dt=sprintf('%s\\%s', data_dir, set_name);
    if ~exist(dt),fprintf('No data for %s\n', set_name); continue; end

    train_label=read_file([dt '\' set_name '_train.csv']);
    vocabulary_size = length(train_label);
    test_number = data_size - vocabulary_size;

    save_dir = [feature_dir '\' set_name];
    makedir(save_dir);
    gesture_seg_inf_name = [save_dir '\information.mat'];
    file_exist = exist(gesture_seg_inf_name,'file');
    if ~file_exist
        fprintf('=======  read movie data  ============\n');
        tic
        [tain_movie_data, test_movie_data] = batch_read_avi(dt,type1,vocabulary_size,test_number);
%             save movie_data.mat tain_movie_data test_movie_data
%             load movie_data.mat
        t0=toc;
        fprintf('\n read data time for %s: %f s \n',set_name, t0);

        fprintf('=======  segment (including extract movies data) ============\n');
        tic
        motion_num = 9; with_rest_position=0;
        segment_inf= segmenta_dtw(tain_movie_data,test_movie_data,...
            train_label,data_size,motion_num,with_rest_position);
%             save segment_inf.mat segment_inf
%             load segment_inf.mat
        t1=toc;
        fprintf('\n split gesture time for %s: %f s \n',set_name, t1);
        save(gesture_seg_inf_name, 'segment_inf','train_label');
    else
        load(gesture_seg_inf_name);
    end

    fprintf('================== mosift descriptors =====================\n');
    save_dir_ = [save_dir '\' feature_type];
    if ~exist(save_dir_,'dir')
        mkdir(save_dir_);
    end
    tic 
    extract_motion_sift(dt,save_dir_,segment_inf,feature_type);
    t2=toc;
    fprintf('extract mosift descriptors time for %s: %f s \n',set_name, t2);

    fprintf('=========== train and test by bag of words model =========\n');
    center_dir_ = [center_dir '\' feature_type];
    if ~exist(center_dir_,'dir')
        mkdir(center_dir_);
    end
    tic
    [train_hist, All_hist, video_gestures]= train_test_bow(save_dir_,segment_inf,...
         train_label,data_size,codebook_size_tatio,set_name,center_dir_,feature_type,coding_type);
    predict_result = recognition_knn(train_hist, All_hist,data_size,train_label,video_gestures);
    t3=toc;
    fprintf('train and test by bag of words model time for %s: %f s \n',set_name, t3);

    prefix=[set_name '_'];mode='w';
    write_file([resu_dir '\' set_name '_predict.csv'], 1:data_size, predict_result, prefix,mode);
end
prepare4submit_joewan(resu_file, resu_dir);
disp(['The total processing time:  ', num2str(etime(clock,tt)/3600)  ' hours.']);
disp(['Testing is over! The fina result is saved in: ' resu_file ]);

function prepare4submit_joewan(predict_file, dirname)
%prepare4submit(submitname, dirname)
% Prepare the challenge submission by concatenating the files in the
% directory dirname and calling it submitname.predict.
% Remove all the old files upon completion.

% Isabelle Guyon -- isabelle@clopinet.com -- October 2011
%modify by joewan -- joewan@gmail.com -- Sempeter 2012

direc = dir([dirname '/valid*_predict.csv']); filenames1 = {};
[filenames1{1:length(direc),1}] = deal(direc.name);
direc = dir([dirname '/final*_predict.csv']); filenames2 = {};
[filenames2{1:length(direc),1}] = deal(direc.name);
filenames=[filenames1; filenames2];

submitname = predict_file;
if exist(submitname, 'file')
    delete(submitname);
end
        
fp=fopen(submitname, 'a');
for k=1:length(filenames)
    fid=fopen([dirname '/' filenames{k}], 'r');
    while 1
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        fprintf(fp, '%s\n', tline);
    end
    fclose(fid);
end
fclose(fp);

for k=1:length(filenames)
    delete([dirname '/' filenames{k}]);
end




