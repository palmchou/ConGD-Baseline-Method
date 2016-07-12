function [frame_number pos descr]=readmosift(mosiftname,type)
% [frame_number pos,dscr]=readmosift(stipfname)
%frame_number: 
% pos: 
% 3dmosift: x y z scale orientation vx vy vz
% mosift:  x y frame number scale vx vy  
% descr: descriptor 
if strcmp(type,'3D MoSIFT') || strcmp(type,'3D EMoSIFT') || strcmp(type,'3D SMoSIFT')
    l=readlines(mosiftname);
    n = length(l);
    pos=zeros(n,8);
    frame_number=zeros(n,1);
    descr=zeros(n,768);
    
    count=0;
    for i=1:n 
        v=transpose(sscanf(l{i},'%f'));
        if length(v)==777
            count = count+1;
            frame_number(count) = single(v(1));
            pos(count,:) = v(2:9);
            descr(count,:) = v(10:end);
        end
    end
    frame_number = frame_number(1:count);
    pos = pos(1:count,:);
    descr = descr(1:count,:);
elseif strcmp(type,'MoSIFT')
    l=readlines(mosiftname);
    n = length(l);
    pos=zeros(n,5);
    frame_number=zeros(n,1);
    descr=zeros(n,256);
    
    count=0;
    for i=1:n 
        v=transpose(sscanf(l{i},'%f'));
        if length(v)==262
            count = count+1;
            frame_number(count) = single(v(3));
            tmp = [v(1:2) v(4:6)];
            pos(count,:) = tmp;
            descr(count,:) = v(7:end);
        end
    end
    frame_number = frame_number(1:count);
    pos = pos(1:count,:);
    descr = descr(1:count,:);
else
end

