function predict_label = recognition_knn(train_hist, All_hist,data_num,train_label,video_gestures)
predict_label = cell(data_num,1);
Group = cell2mat(train_label);
distance = 'euclidean' ;k=1;
Class = knnclassify(All_hist, train_hist, Group', k, distance);
count = 1;
for i=1:data_num
    num_gesture=video_gestures(i);
    predict = Class(count:(count+num_gesture-1));
    count = count+num_gesture;
    predict_label{i}  = predict';
end