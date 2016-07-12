function create_hist(center_mat, list, out_file_name )
load(center_mat)
[video_names, labels] = textread(list, '%s %s');
label = '0';
code_size = 5000;
cell_num = 2;
oribin_num = 8;
out_fid = fopen(out_file_name, 'wt');
for i=1:length(video_names)
    feat_path = video_names{i};
    label = labels{i};
    [~, ~, tmp_desc]=readmosift_hoghofmbh(feat_path, oribin_num, cell_num);
    hist = calhist_from_centers(tmp_desc, center, code_size);
    fprintf(out_fid, '%s', label);
    for j=1:length(hist)
        feat = hist(1,j);
        fprintf(out_fid, ' %d:%g', j, feat);
    end
    fprintf(out_fid, '\n');
    disp(sprintf('%d/%d: %s', i, length(video_names), feat_path));
end
fclose(out_fid);

function hist = kmeans2d_hist(cluster_number,idx)
hist = zeros(1,cluster_number);
for i=1:length(idx)
    hist(idx(i)) = hist(idx(i)) +1;
end
hist = hist/norm(hist,2);

function hist = calhist_from_centers(descr, center,codebook_size)
distance = eucliddist(descr,center);
[c idx] = min(distance,[],2);
hist = kmeans2d_hist(codebook_size,idx);