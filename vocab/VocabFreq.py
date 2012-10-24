import csv, glob, shutil

# parse dictionary, store keys
file_dic = open(glob.glob('*.txt')[0])
dic = []
for line in file_dic:
    dic.append(line.lower().strip())

# read KF notes
file_csv = open(glob.glob('*.csv')[0], "r")
csv.field_size_limit(10000000)
reader_csv = csv.reader(file_csv, dialect = 'excel')
file_dic.close()

# Containers for storing values
global_word_count = {} # {word:frequency}
author_to_words = {} # {author:{word:frequency}}
all_authors = []
all_ids = []
all_ids_to_freq = {}

print "Welcome to FreqCounter"
while 1:
    id_column_in = raw_input("Enter column number of note ids: ")
    author_column_in = raw_input("Enter column number of author names: ")
    text_column_in = raw_input("Enter column number of note text: ")
    try:
        id_column_in = int(id_column_in) - 1
        author_column_in = int(author_column_in) - 1
        text_column_in = int(text_column_in) - 1
        break
    except:
        print "Invalid input, try again!"
        continue


# Compare each row to key in dictionary dic
i = 1
for row in reader_csv:
    if i == 1:
        i = 0
        continue
    '''
    note_id = row[0].lower().strip() 
    author_name = row[1].lower().strip()
    text_column = row[2].lower().strip()   
    '''
    note_id = row[id_column_in].lower().strip() 
    author_name = row[author_column_in].lower().strip()
    text_column = row[text_column_in].lower().strip()   
    
    if author_name not in all_authors:
        all_authors.append(author_name)
        
    all_ids.append(note_id)
    all_ids_to_freq[note_id] = 0
    
    # Count words globally
    # Count words per author
    for word in dic:                
        if word in text_column:
            # Count words per author
            count = text_column.count(word)
            
            all_ids_to_freq[note_id] += count
            
            # Count words globally for the whole document
            if word not in global_word_count:
                global_word_count[word] = count
            else:
                global_word_count[word] += count            
            
            if author_name not in author_to_words:
                author_to_words[author_name] = {}
                author_to_words[author_name][word] = count
            elif author_name in author_to_words and word in author_to_words[author_name]: #author_name in author_to_words
                author_to_words[author_name][word] += count
            elif author_name in author_to_words and word not in author_to_words[author_name]: 
                author_to_words[author_name][word] = count
        # NOTE: WILL BE DELETED
        else: #elif word not in text_row
            # Count words per author
            count = 0
            # Add new words
            if author_name not in author_to_words:
                author_to_words[author_name] = {}
                author_to_words[author_name][word] = count  
            # Add new words
            elif author_name in author_to_words and word not in author_to_words[author_name]: 
                author_to_words[author_name][word] = count
file_csv.close()

# Output collected frequencies to .csv files
# Authors frequencies
shutil.copyfile(glob.glob('*.csv')[0], 'student_output.csv')
write_students_to = open('student_output.csv', 'w')
writer_students_csv = csv.writer(write_students_to, dialect = 'excel')

for author in all_authors:
    for word in dic:
        writer_students_csv.writerow([author, word, author_to_words[author][word]])
# Close .csv
write_students_to.close()

# IDs frequencues
shutil.copyfile(glob.glob('*.csv')[0], 'IDs_output.csv')
write_ids_to = open('IDs_output.csv', 'w')
writer_ids_csv = csv.writer(write_ids_to, dialect = 'excel')

for ids in all_ids:
    writer_ids_csv.writerow([ids, all_ids_to_freq[ids]])
# Close .csv
write_ids_to.close()


# Global words frequencies
shutil.copyfile(glob.glob('*.csv')[0], 'global_output.csv')
write_to = open('global_output.csv', 'w')
writer_csv = csv.writer(write_to, dialect = 'excel')

for key in dic:
    if key in global_word_count:
        get_value = global_word_count[key]        
        writer_csv.writerow([key, get_value])    
    else:        
        writer_csv.writerow([key, 0])
# Close .csv
write_to.close()