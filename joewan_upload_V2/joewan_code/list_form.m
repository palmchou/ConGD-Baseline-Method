function list_form()
clear;clc;close all;

m=6194;n=2;
data=cell(m,n);
fid=fopen('isolate_test_did.txt','r');
for i=1:m
    for j=1:n
        data{i,j}=fscanf(fid,'%s',[1,1]);
    end
end
fclose (fid);
str=cell(m,1);
for i=1:m
    str{i}=data{i,1};
end
files = [];
for i=1:249
    disp(int2str(i))
    n = 0;
    list = [];
    for j = 1: length(str)
        train_num = str2double(str{j,1});
        if i == train_num
            list{1,n+1} = data{j,2};
            n = n + 1;
        end       
    end
%     list_form{i,1} = list;
    files{i,1} = i;
    files{i,2} = n;
    files{i,3} = list;
end
save ('test_list_form_did.mat', 'files');
