import tools


def joint(list_f, p_result_f, out_f):
    with open(list_f) as f:
        list = f.readlines()
    with open(p_result_f) as f:
        result = f.readlines()
    p_table = {}
    if len(list) != len(result):
        print "WRONG!"
        return -1
    for i in range(len(list)):
        line = list[i][:-1]
        file_name = '/'.join(line.split('/')[-3:-1])
        segs = line.split('/')[-1].split('.')[0]
        s, e = segs.split('-')
        label = result[i][:-1]
        s, e, label = int(s), int(e), int(label)
        print file_name, s, e, label
        if not p_table.has_key(file_name):
            p_table[file_name] = []
        p_table[file_name].append(((s, e), label))
    tools.formatted_write(p_table, out_f)


joint('/data2/szhou/gesture/baseline/congd/con_list/valid_split.list',
      '/data2/szhou/gesture/baseline/congd/svm/valid.prediction',
      '/data2/szhou/gesture/baseline/congd/svm/valid_prediction.txt')