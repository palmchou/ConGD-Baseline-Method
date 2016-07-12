
% gesture segmentation from sample code (Isabelle Guyon)

function [segment_inf dtw_label]= segmenta_dtw(tain_movie_data,test_movie_data,...
                    train_label,data_num,motion_num,with_rest_position)
vocabulary_size = length(train_label);
segment_inf = cell(data_num,1);
dtw_label = cell(data_num,1);
% motion_num=9;
[MOTION_tr L]= train_dtw(tain_movie_data,motion_num,with_rest_position);

for i=1:data_num
    if i<=vocabulary_size
        movie_K = tain_movie_data{i};
    else
        movie_K = test_movie_data{i-vocabulary_size};
    end
    [auto_tempo_segment recognized_labels]= test_dtw(MOTION_tr,train_label,L,movie_K,motion_num,with_rest_position);
    segment_inf{i} = auto_tempo_segment;
    dtw_label{i} = recognized_labels;
end

function [MOTION_tr L]= train_dtw(Ktr,motion_num,with_rest_position)
% Number of features in the motion data representation

% PREPROCESSING TRAINING DATA
n=length(Ktr);
L=zeros(n,1);
MOTION_tr=[];
for k=1:n
    % Note: this is similar to motion_histograms, just coarser
    motion_tr=motion(Ktr{k}, motion_num);
    if with_rest_position
        motion_tr=trim(motion_tr); % remove still frames at beginning and end
    end
    L(k)=size(motion_tr,1); % This is the length of each example video
    MOTION_tr=[MOTION_tr; motion_tr];
end           
if with_rest_position
    % Add the zero motion as transition model
    MOTION_tr=[MOTION_tr; zeros(1, size(MOTION_tr,2))];
end


function [auto_tempo_segment recognized_labels] = test_dtw(MOTION_tr,train_label,L,K0,motion_num,with_rest_position)
% Motion representation for the test example
MOTION_te=motion(K0, motion_num);

% COMPUTATION OF LOCAL SCORES (using Euclidean distance)
% We make frame-by-frame comparisons between
% all training examples and the test video
local_scores=euclid_simil(MOTION_tr, MOTION_te);

% FORWARD HMM MODEL
% We create a "model" with the training data.
% Note that we use as parameters onle the length of the
% training gestures. We add or not an extra model for the rest
% position.
[parents, local_start, local_end] = simple_forward_model( L , with_rest_position);

% Computation of the best elastic match
debug=0; % Show the matching path
[~, ~, ~, cut, label_idx]=viterbi(local_scores, parents, local_start, local_end, debug);
if debug
    ylabel('Training examples', 'FontSize', 14, 'FontWeight', 'bold');
    set(gcf, 'Name', 'DYNAMIC TIME WARPING (DTW) TEMPORAL SEGMENTATION');
end

% Cleanup labels and create a list of begining and end of gestures.
% Remove 0 labels and eventual transition model labels 
transition_model_label=length(L)+1;
idxg=find(label_idx~=transition_model_label & label_idx>0);
label_idx=label_idx(idxg);
auto_tempo_segment=[cut(1:end-1)'+1, cut(2:end)'];
auto_tempo_segment=auto_tempo_segment(idxg,:);
recognized_labels=train_label(label_idx);
 