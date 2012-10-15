import csv, glob, shutil

# Parse dictionary, store keys
file_dic = open(glob.glob('*.txt')[0])
dic = []
for line in file_dic:
    new=line.lower().strip()
    dic.append(new)

# Initialize csv reader
file_csv = open(glob.glob('*.csv')[0], "r")
csv.field_size_limit(10000000)
reader_csv = csv.reader(file_csv, dialect = 'excel')
word_count = {}

# Compare each row to key in dictionary dic
for row in reader_csv:
    
    for i in dic: 
        new_row=row[2].lower().strip()
        
        if i in new_row:
            count = new_row.count(i)
            
            if i not in word_count:
                word_count[i] = count
            else:
                word_count[i] = word_count[i] + count
# Close stream                
file_dic.close()
file_csv.close()


# Copy original file
shutil.copyfile(glob.glob('*.csv')[0], 'output.csv')
# Overwrite copied file
write_to = open('output.csv', 'w')
# Initialize csv writer
writer_csv = csv.writer(write_to, dialect = 'excel')

# Write to overwritten file
for key in dic:

    if key in word_count:
        get_value = word_count[key]        
        writer_csv.writerow([key, get_value])
    
    else:        
        writer_csv.writerow([key, 0])
# Close stream      
write_to.close()

