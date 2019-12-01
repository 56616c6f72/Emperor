__author__ = "AugustTom"
__version__ = "1.0"

import os
import sys


class Inode:
    def __init__(self):
        self.inode = ""
        self.type = ""
        self.mode = ""
        self.flags = ""
        self.generation = ""
        self.version = ""
        self.group = ""
        self.fileSize = ""
        self.fileACL = ""
        self.directoryACL = ""
        self.links = ""
        self.blockcount = ""
        self.fragment = ""
        self.address = ""
        self.number = ""
        self.size = ""
        self.ctime = ""
        self.atime = ""
        self.mtime = ""
        self.crtime = ""
        self.dtime = ""
        self.extraFields = ""
        self.extents = ""

    def put_the_values_down(self):
        return self.inode + "," + self.type + "," + self.mode + "," + self.flags + "," \
               + self.generation + "," + self.version + "," + self.user + "," + self.group + "," + \
               self.fileSize + "," + self.fileACL + "," + self.directoryACL + "," + \
               self.links + "," + self.blockcount + "," + self.fragment + "," + \
               self.address + "," + self.number + "," + self.size + "," + self.ctime + "," + \
               self.atime + "," + self.mtime + "," + self.crtime + "," + self.dtime + "," + self.extraFields + "," + self.extents + "\n"

    @staticmethod
    def reformat_date(date):

        date = date.split()

        if len(date) > 5:
            date.pop(0)
            date.pop(0)
            date.pop(0)
            return ' '.join([str(elem) for elem in date])
        else:
            return "error"


list_of_key_words = {"Inode:", "Type:", "Mode:", "Flags:", "Generation:", "Version:", "User:", "Group:",
                     "Size:", "File", "Directory", "Links:", "Blockcount:", "Fragment:",
                     "Address:", "Number:", "ctime:", "atime:", "mtime:", "crtime:","dtime:", "Size", "EXTENTS"}


def welcome_message():
    print('''
    (o_
    //\ 
    V_/_

    Pingu here...''')


def read_the_input_file():

    if len(sys.argv) > 1:
        file_location = sys.argv[1]
    else:
        print("No input directory was provided. \nLooking for the default file name 'full_inode_extract_output.txt'")
        file_location = "full_inode_extract_output.txt"
    
    if not os.path.exists(file_location):
        print("Ups... File not found")
        exit(1)
        
    with open(file_location) as input_file:
        print("File found - " + file_location)
        return input_file.read().replace('\n', ' ')


def open_the_output_file(output_dir):
    output = open(output_dir, "w+")
    output.write("Inode,Type,Mode,Flags,Generation,Version,User,Group,File Size,File ACL,"
                 "Directory ACL,Links,Blockcount,Fragment,"
                 "Address,Number,Fragment Size,ctime,atime,mtime,crtime,dtime,Size of extra inode fields,EXTENTS\n")
    return output


def write_to_file(text, output_file):
    new_inode = Inode()
    words = text.split()
    i = 0
    length  = len (words)
    while i < len(words):
        j = i + 1
        word = words[i]

        if word == "Inode:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.inode = val
        elif word == "Type:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.type = val
        elif word == "Mode:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.mode = val
        elif word == "Flags:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.flags = val
        elif word == "Generation:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.generation = val
        elif word == "Version:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.version = val
        elif word == "User:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.user = val
        elif word == "Group:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.group = val
        elif word == "Size:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.fileSize = val
        elif word == "File":
            val = ""
            j += 1
            while words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.fileACL = val
        elif word == "Directory":
            val = ""
            j = j + 1
            words[j] = words[j]
            while words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.directoryACL = val
        elif word == "Links:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.links = val
        elif word == "Blockcount:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.blockcount = val
        elif word == "Fragment:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.blockcount = val
        elif word == "Address:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.address = val
        elif word == "Number:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.number = val
        elif word == "Size:" and new_inode.size != "":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.size = val
        elif word == "ctime:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j] + " "
                j += 1
            new_inode.ctime = new_inode.reformat_date(val)
        elif word == "atime:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j] + " "
                j += 1
            new_inode.atime = new_inode.reformat_date(val)
        elif word == "mtime:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j] + " "
                j += 1
            new_inode.mtime = new_inode.reformat_date(val)
        elif word == "crtime:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j] + " "
                j += 1
            new_inode.crtime = new_inode.reformat_date(val)
        elif word == "dtime:":
            val = ""
            while words[j] not in list_of_key_words:
                val += words[j] + " "
                j += 1
            new_inode.dtime = new_inode.reformat_date(val)
        elif word == "Size" and new_inode.size != "" and new_inode.fileSize != "":
            val = ""
            j += 4
            while words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.extraFields = val
        elif word == "EXTENTS:":
            val = ""
            if (j < len(words) - 1) and words[j] not in list_of_key_words:
                val += words[j]
                j += 1
            new_inode.extents = val
            output_file.write(new_inode.put_the_values_down())

        i = j
    output_file.close()


# the Main

welcome_message()
try:
    final_dir = "pingu_debugfs_timeline.csv"
    write_to_file(read_the_input_file(), open_the_output_file(final_dir))
    print("All done. ^_^")

except Exception:
    print("Something went wrong :'( ")
    exit(1)
