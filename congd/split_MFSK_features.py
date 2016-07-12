import copy
import os
import shutil


def check_create_par_dir(file_path):
    dir_ = os.path.dirname(file_path)
    if not os.path.exists(dir_):
        os.makedirs(dir_)


def split_feat(feats, seg_points, save_path):
    feats_copy = copy.copy(feats)
    check_create_par_dir(save_path)
    out_f = open(save_path, 'w')
    for line in feats_copy:
        frame = int(line.split(' ', 1)[0])
        s_min, s_max = seg_points[0], seg_points[1]
        if s_min <= frame <= s_max:
            out_f.write(line)
            feats.remove(line)
        elif frame > s_max:
            break
    out_f.close()


def split(MFSK_src_dir, split_dir, input_list_file, output_list_file):
    with open(input_list_file) as input:
        input_list = input.readlines()
    output = open(output_list_file, 'w')
    for i, line in enumerate(input_list):
        video_name, segments_info = line.split(' ', 1)
        print 'Splitting', video_name, '%d/%d' % (i, len(input_list))
        segments = segments_info.split()
        features_file = os.path.join(MFSK_src_dir, video_name+'.mfsk')
        with open(features_file) as f_file:
            feats = f_file.readlines()
        if len(segments) == 1:
            seg = segments[0]
            points, label = seg.split(':')
            s, e = points.split(',')
            save_path = os.path.join(split_dir, video_name, '%s-%s.mfsk' % (s, e))
            check_create_par_dir(save_path)
            shutil.copy(features_file, save_path)
            output.write('%s %s\n' % (save_path, label))
        else:
            for seg in segments:
                points, label = seg.split(':')
                s, e = points.split(',')
                save_path = os.path.join(split_dir, video_name, '%s-%s.mfsk' % (s, e))
                split_feat(feats, (int(s), int(e)), save_path)
                output.write('%s %s\n' % (save_path, label))

if __name__ == '__main__':
    split(MFSK_src_dir='/data2/szhou/gesture/baseline/MFSK_features_CON/train',
          split_dir='/data2/szhou/gesture/baseline/MFSK_features_CON_splited/train',
          input_list_file='con_list/train.txt',
          output_list_file='con_list/train_split.list')
    split(MFSK_src_dir='/data2/szhou/gesture/baseline/MFSK_features_CON/valid',
          split_dir='/data2/szhou/gesture/baseline/MFSK_features_CON_splited/valid',
          input_list_file='con_list/valid_segmented.txt',
          output_list_file='con_list/valid_split.list')
