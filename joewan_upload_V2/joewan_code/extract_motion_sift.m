
function extract_motion_sift(directory,save_dir,segment_inf,feature_type)

block_size = 32;
cell_num = 2;
oribin_num = 8;

len = length(segment_inf);
for i=1:len
    segment_inf1 = segment_inf{i};
    gesture_num = size(segment_inf1,1);
    dir_M = sprintf('%s\\M_%d.avi',directory,i);
    dir_K = sprintf('%s\\K_%d.avi',directory,i);
    if gesture_num==1
        feature_name = sprintf('%s\\K_%d.csv',save_dir,i);
        file_exist = exist(feature_name,'file');
        if ~file_exist
            if strcmp(feature_type,'3D MoSIFT')
                command_K =['3DMoSIFT.exe ' dir_M ' ' dir_K ' "' feature_name '" 0'];
            elseif strcmp(feature_type,'3D EMoSIFT')
                command_K =['3DEMoSIFT.exe ' dir_M ' ' dir_K ' "' feature_name '" 0'];
            elseif  strcmp(feature_type,'3D SMoSIFT')
                command_K =['3DSMoSIFT.exe ' dir_M ' ' dir_K ' "' feature_name '" 3 4 0 0 1 1 0 0 0 0 0 0'];
            elseif strcmp(feature_type,'MFSK')
                command_K =['MFSK\MFSK.exe ' dir_M ' ' dir_K ' "' feature_name '" ' num2str(cell_num) ' ' num2str(block_size)...
                     ' ' num2str(oribin_num) ' ' num2str(oribin_num) ' ' num2str(oribin_num)];
            else
            end
            system(command_K);
        end
    else
        movie_M = read_movie(dir_M);
        movie_K =read_movie(dir_K);
        for j=1:gesture_num
            feature_name = sprintf('%s\\K_%d_%d.csv',save_dir,i,j);
            file_exist = exist(feature_name,'file');
            if ~file_exist
                beg1 = segment_inf1(j,1);
                end1 = segment_inf1(j,2);
                sub_movie_M =movie_M(beg1:end1);
                sub_movie_K =movie_K(beg1:end1);
                sub_movie_M_name = 'tmp_M.avi';
                sub_movie_K_name = 'tmp_K.avi';
                save_submovie(sub_movie_M,sub_movie_M_name);
                save_submovie(sub_movie_K,sub_movie_K_name);
                if strcmp(feature_type,'3D MoSIFT')
                    command_K =['3DMoSIFT.exe ' sub_movie_M_name ' ' sub_movie_K_name ' "' feature_name '" 0'];
                elseif strcmp(feature_type,'3D EMoSIFT')
                    command_K =['3DEMoSIFT.exe ' sub_movie_M_name ' ' sub_movie_K_name ' "' feature_name '" 0'];
                elseif strcmp(feature_type,'3D SMoSIFT')
                    command_K =['3DSMoSIFT.exe ' sub_movie_M_name ' ' sub_movie_K_name ' "' feature_name '" 3 4 0 0 1 1 0 0 0 0 0 0'];
                elseif strcmp(feature_type,'MFSK')
                    command_K =['MFSK\MFSK.exe ' sub_movie_M_name ' ' sub_movie_K_name ' "' feature_name '" ' num2str(cell_num) ' ' num2str(block_size)...
                     ' ' num2str(oribin_num) ' ' num2str(oribin_num) ' ' num2str(oribin_num)];
                else
                end    
                system(command_K);
                delete('tmp_K.avi','tmp_M.avi');
            end
        end
    end
end

function save_submovie(sub_movie,tmp_name)
writerObj = VideoWriter(tmp_name,'Uncompressed AVI');
writerObj.FrameRate = 10;
open(writerObj);
for k = 1:length(sub_movie) 
   frame = sub_movie(k).cdata;
   writeVideo(writerObj,frame);
end
close(writerObj);