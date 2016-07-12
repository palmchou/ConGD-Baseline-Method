import numpy as np
with open('con_list/train.txt') as src:
    src_list = src.readlines()
output = open('con_list/single_label_train.list', 'w')

single_label_list = {}
for line in src_list:
    if len(line.split()) == 2:
        path, seg_label = line.split()
        label = seg_label.split(':')[1]
        if label not in single_label_list:
            single_label_list[label] = []
        single_label_list[label].append(path)

for label in single_label_list:
    n = len(single_label_list[label])
    rand_idx = np.random.permutation(range(n)).tolist()[:10]
    map(output.write, [single_label_list[label][idx]+'\n' for idx in rand_idx])


