function [frame_number, pos, descr]=readmosift_hoghofmbh(featurename,oribin_num,cell_num)
% [frame_number pos,dscr]=readmosift(stipfname)
%frame_number: 
% pos: 
% 3dmosift: x y z scale orientation vx vy vz
% mosift:  x y frame number scale vx vy  
% descr: descriptor 



l=readlines(featurename);
n = length(l);
pos=zeros(n,2);
frame_number=zeros(n,1);
desc_num = cell_num*cell_num*oribin_num*8+768;
descr=zeros(n,desc_num);

tmp = desc_num+3;

count=0;
for i=1:n 
    v=transpose(sscanf(l{i},'%f'));
    if length(v)==tmp
        count = count+1;
        frame_number(count) = single(v(1));
        pos(count,:) = v(2:3);
        descr(count,:) = v(4:end);
    end
end
frame_number = frame_number(1:count);
pos = pos(1:count,:);
descr = descr(1:count,:);

[row, col]=find((descr<0)|(descr>255));
if ~isempty(row) 
    row = unique(row);
    descr(row,:)=[];
    pos(row,:)=[];
    frame_number(row,:)=[];
end

% descr = descr(:,1:768);%3D SMoSIFT 
% descr = descr(:,769:896);%HOGHOF
% descr = descr(:,897:end);%MBH
% descr = descr(:,1:end);% MFSK




