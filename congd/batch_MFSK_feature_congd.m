function batch_MFSK_feature_congd()
MFSK_bin_path = './MFSK';  % path to MFSK program
list_file_path = 'con_list/valid.txt';  % list of videos shipped alone with the database
src_dir = '/data3/gesture/ConGD_files/ConGD/valid';  % where stored the videos
dst_dir = '/data2/szhou/gesture/baseline/MFSK_features_CON/valid'; % where you want the generated features to be stored

[name_list] = textread(list_file_path, '%s %*[^\n]');

parfor i = 1:length(name_list)
    save_path = [dst_dir '/' name_list{i} '.mfsk'];
    mkdir_if_not_exist(fileparts(save_path));
    RGB_name = [name_list{i} '.M.avi'];
    D_name = [name_list{i} '.K.avi'];
    command = strjoin({MFSK_bin_path, [src_dir '/' RGB_name], ...
        [src_dir '/' D_name], save_path});
    [status, output] = system(command);
    if status ~= 0
        disp(output)
    end
    fprintf('%d/%d: %s\n', i, length(name_list), save_path)
end
end

function mkdir_if_not_exist(dirpath)
    if dirpath(end) ~= '/', dirpath = [dirpath '/']; end
    if (exist(dirpath, 'dir') == 0), mkdir(dirpath); end
end
