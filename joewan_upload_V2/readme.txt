--------------- CHALEARN Gesture Challenge 2   ---------------------
code version: v2.0
date: september 2012
modified data: Sep, 2013;
modified data: Sep, 2015

You can use this software for academical research. 
Before you use this code, you should download and install the next matlab toolbox.
1)spams-matlab
This toolbox can be downloaded: http://spams-devel.gforge.inria.fr/
2£© vlfeat matlab toolbox 
This toolbox can be downloaded: http://www.vlfeat.org/

Please see the main.m if you want to run this code.

If you use this software, you should cite the next three papers:

=========================================================================================================
Jun Wan, Qiuqi Ruan, Shuang Deng and Wei Li, "One-shot learning gesture recognition from rgb-d data 
using bag of features", journal of machine learning research, Vol 14, pp. 2549-2582, 2013

This paper introduces the 3D EMoSIFT features and also use SOMP to replace VQ for coding descriptors. 
=========================================================================================================
Jun Wan, Qiuqi Ruan and Shuang Deng, "3D SMoSIFT: 3D Sparse Motion Scale Invariant Feature Transform 
for Activity Recognition from RGB-D Videos", Journal of Electronic Imaging, 23(2), 023017, 2014. 

This paper introduces the 3D SMoSIFT features. The significant merit is that this new feature is almost 
real-time. And 3D SMoSIFT can get higher performance than 3D MoSIFT and 3D EMoSIFT features.
=========================================================================================================

Jun Wan, Guogong Guo, Stan Z. Li, "Explore Efficient Local Features form RGB-D Data for One-shot Learning 
Gesture Recognition", under review (submitted to IEEE TPAMI, round 2), 2015

In this paper, Mixed features around sparse keypoints (MFSK) is proposed. The MFSK feaute consist of some
popular feature descriptors, such as 3D SMoSIFT, HOG, HOF, MBH. The MFSK feature can outperform all the 
published approaches on the challenging data of CGD, such as translated, scaled and occludeed subsets.
==========================================================================================================

This software is written by Jun Wan; If you have any question, please contact me:
Jun Wan (personal page: http://joewan.weebly.com (under construction))
email: joewan10@gmail.com
