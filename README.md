ConGD baseline
---
This is the source code of the baseline method of [ConGD](http://www.cbsr.ia.ac.cn/users/jwan/database/congd.html), a large-scale continous gesture dataset.  
Baseline method: MFSK features -> Sliding Window segmentation -> Kmeans -> SVM

## ChaLearn Challenage and Data downloading
The [ChaLearn LAP Large-scale Continous Gesture Recognition Challenge](https://competitions.codalab.org/competitions/10341)
is in progress, please feel free to participate!  
You can gain access to the ChaLearn LAP ConGD dataset from http://www.cbsr.ia.ac.cn/users/jwan/database/congd.html.

## Notes
This code was tested on Ubuntu 14.04 OS, with MATLAB 2013b and Python 2.7. There is a compiled MFSK binary program for Ubuntu 14.04.  
Please double check the paths in code before your run it.

##Steps in detail of baseline method:

####Step 1. Extract MFSK features.
For both `train.txt` and `valid.txt` use `congd/batch_MFSK_feature_congd.m` program to extract and save MFSK for all videos.

####Step 2. Get list of videos who only contains one gesture
In this baseline method, we randomly select 10 videos for each class, and each video should only comtain one gesture.
program `congd/get_single_label_train_list.py` can help you to selected videos and save the list.

####Step 3. Calculate Kmeans center
Excute `joewan_upload_V2/joewan_code/con_cal_center.m` program to do all the works. Check paths before run it.
It first read features of selected train videos in step2, and then uses them to calculate and save the center.
This cost a lot time to process, but you can move to step 4 while waiting for it.

####Step 4. Segment validation videos and split features
First, run `congd/segment_videos.py` to use sliding window method to segment videos.
The output `congd/con_list/valid_segmented.list` file saved segmentation points.
Then use `congd/split_MFSK_features.py` to split both train and validation features.
This step will generate `train_split.list` and `valid_split.list` files.

####Step 5. Generate hist files
Run `joewan_upload_V2/joewan_code/create_hist.m` with generated `train_split.list` and `valid_split.list` file to get
hist files for train set and validation set.

####Step 6. Use Lib-SVM to Train SVM Model and Predict the Label of Validation Hists.
First scale both `train.hist` and `valid.hist` to range `[-1, 1]`, using command`svm-scale`. Then train svm with linear kernel type `svm-train -t 0`. At last, use trained model to generate labels for `valid.hist`.

####Step 7. Format svm prediction
Run `congd/joint_list.py` to get formatted result for evaluation.

##Citation
If you use this code in your research, please cite the following two papers:

**MFSK feature:**  
Jun Wan, Guogong Guo, Stan Z. Li, "Explore Efficient Local Features form RGB-D Data for One-shot Learning
Gesture Recognition", IEEE TPAMI, 2015 (accepted)

**ConGD result:**  
Jun Wan, Yibing Zhao, Shuai Zhou, Isabelle Guyon, Sergio Escalera and Stan Z. Li, "ChaLearn Looking at People RGB-D Isolated and Continuous Datasets for Gesture Recognition", CVPR workshop, 2016.

Should you have any question, please contact:  
Shuai Zhou: shuaizhou.palm@gmail.com, or  
Jun Wan: jun.wan@ia.ac.cn

##License
### VLFeat
The kmeans algorithm we used is implemented by VLFeat toolbox.
> **VLFeat** is distributed under the BSD license:
> Copyright (C) 2007-11, Andrea Vedaldi and Brian Fulkerson
> Copyright (C) 2012-13, The VLFeat Team
> All rights reserved.

### ConGD Baseline
Distributed under the Apache License V2.0, please check `LICENSE` for further information.