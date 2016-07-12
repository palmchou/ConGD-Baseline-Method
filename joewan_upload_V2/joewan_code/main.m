function main()

%% --------------- CHALEARN Gesture Challenge 2   ---------------------
% code version: v2.0
% date: Sep, 2012
% modified: Sep, 2013
% modified date: Sep, 2015
% You can use this software for academical research. 
% Before you use this code, you should download and install the next matlab toolbox.
% 1)spams-matlab
%  This toolbox can be downloaded: http://spams-devel.gforge.inria.fr/
% 2£© vlfeat matlab toolbox 
% This toolbox can be downloaded: http://www.vlfeat.org/; 

% If you use this software, you should cite these two papers:
% ==================================================================================================
% 1) Jun Wan, Qiuqi Ruan, Shuang Deng, Wei Li, "One-shot learning gesture recognition from rgb-d data using 
%    bag of features", journal of machine learning research, Vol 14, pp. 2549-2582, 2013.
%    This paper introduces the 3D EMoSIFT features and also use SOMP to replace VQ for coding descriptors. 
% ==================================================================================================
% 2) Jun Wan et al.,  "3D SMoSIFT: 3D Sparse Motion Scale Invariant Feature Transform for 
%    Activity Recognition from RGB-D Videos", Journal of Electronic Imaging, 23(2), 023017, 2014.
%    This paper introduces the 3D SMoSIFT features. The significant merit is that this new feature is almost 
%    real-time. And 3D SMoSIFT can get higher performance than 3D MoSIFT and 3D EMoSIFT features.
% ==================================================================================================
% 3) Jun Wan, Guodong Guo and Stan Z Li, "Explore Efficient Local Features form RGB-D Data for One-shot 
%    Learning Gesture Recognition", under review, 2015.
%    In this paper, Mixed features around sparse keypoints (MFSK) is proposed. The MFSK feature can outperform 
%    all the published approaches on the challenging data of CGD, such as translated, scaled and occludeed subsets.
% ==================================================================================================

% This software is written by Jun Wan; If you have any question, please contact me:
% Jun Wan (personal page: http://joewan.weebly.com (under construction))
% email: joewan10@gmail.com

%% This example is used for chalearn gesture dataset.
features_types = {'3D MoSIFT', '3D EMoSIFT', '3D SMoSIFT','MFSK'};
coding_type = {'VQ','SOMP'}; 
data_type ={'devel','valid','final'};  % devel01~20 batches; valid01~20 batches; final21~40 batches
data_dir = 'D:\JoeWan\chaLearn\Data'; %data directory  
resu_file = 'D:\JoeWan\joewan\test.csv';% the final predictioan results for each video.
parameters.feature_type = features_types{4};
parameters.coding_type = coding_type{1};
parameters.data_type = data_type{3}; 

prepare_final_resut(data_dir, resu_file,parameters);


