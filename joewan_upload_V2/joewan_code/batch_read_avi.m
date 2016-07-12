function [train_data test_data]= batch_read_avi(directory,type,vocabulary_size,test_number)
if nargin<=3
    test_number=0;
end
if (strcmp(type,'M'))||strcmp(type,'K')
    train_data = cell(vocabulary_size,1);
    test_data = cell(test_number,1);   
else
    train_data.M = cell(vocabulary_size,1);
    train_data.K = cell(vocabulary_size,1);
    test_data.M = cell(test_number,1);
    test_data.K = cell(test_number,1);
end

data_num = vocabulary_size + test_number;
for i=1:data_num
    if strcmp(type,'M')
        dir_M = sprintf('%s\\M_%d.avi',directory, i);
        movie_M =read_movie(dir_M);
    elseif strcmp(type,'K')
        dir_K = sprintf('%s\\K_%d.avi',directory, i);
        movie_K =read_movie(dir_K);
    else
        dir_M = sprintf('%s\\M_%d.avi',directory, i);
        dir_K = sprintf('%s\\K_%d.avi',directory, i);
        movie_M =read_movie(dir_M);
        movie_K =read_movie(dir_K);
    end
    if i<=vocabulary_size
        if strcmp(type,'M')
            train_data{i} = movie_M;
        elseif strcmp(type,'K')
            train_data{i} = movie_K;
        else
            train_data.M{i} = movie_M;
            train_data.K{i} = movie_K;
        end
        
    else
        if strcmp(type,'M')
            test_data{i-vocabulary_size} = movie_M;
        elseif strcmp(type,'K')
            test_data{i-vocabulary_size} = movie_K;
        else
            test_data.M{i-vocabulary_size} = movie_M;
            test_data.K{i-vocabulary_size} = movie_K;
        end 
    end
end
if data_num == vocabulary_size
    test_data =[];
end
