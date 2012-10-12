import csv, glob

file_dic = open(glob.glob('*.txt')[0])
dic = []
for line in file_dic:
    new=line.lower().strip()
    dic.append(new)


file_csv = open(glob.glob('*.csv')[0], "r")
csv.field_size_limit(10000000)
reader_csv = csv.reader(file_csv, dialect='excel')
word_count = {}
for row in reader_csv:
    for i in dic:
        new_row=row[2].lower().strip()
        
        if i in new_row:
            count = new_row.count(i)
            if i not in word_count:
                word_count[i] = count
            else:
                word_count[i] = word_count[i]+count
                
file_dic.close()
file_csv.close()


write_to = open(glob.glob('*.csv')[0]+'.txt', 'w')

word_keys = word_count.keys()
word_keys.sort()
for key in word_keys:
    write_to.write(key.rjust(40)+' '+ str(word_count[key])+'\n')
    
write_to.close()

   