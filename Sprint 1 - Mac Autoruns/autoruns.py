#!/usr/bin/python

import os, hashlib, plistlib, re

SYSTEM_LAUNCHAGENTS='/Library/LaunchAgents'
SYSTEM_LAUNCHDAEMONS='/Library/LaunchDaemons'
USERS=os.listdir('/Users')
AUTORUNTYPES = ["System LaunchAgent", "User LaunchAgent", "System LaunchDaemon",\
     "User LaunchDaemon", "Cron job"]
global AUTORUNENTRIES
AUTORUNENTRIES = []

"""
Define a class which applies to each autorun entry
  name: the filename associated with the autorun
  filepath: the program executed by the entry
  autoruntype: what type of entry this is (see AUTORUNTYPES)
  md5: the MD5 hash of the filepath
  sha1: the SHA1 of the filepath
  sha256: the SHA1 of the filepath
"""
class AutorunEntry():
    def __init__(self, name, filepath, autoruntype, md5, sha1, sha256):
        self.name = name
        self.filepath = filepath
        self.autoruntype = autoruntype
        self.md5 = md5
        self.sha1 = sha1
        self.sha256 = sha256
    def __str__(self):
        return "{0}: {1}, {2}, {3}".format(self.name, self.autoruntype, self.filepath, self.sha256)

"""
Retrieve the Program or ProgramArguments key of a plist
"""
def get_plist_program(plistfile):
    try:
        with open(plistfile, 'rb') as f:
            plist = plistlib.load(f)
    except PermissionError:
        return "- Permission error opening file."
    try:
        program = plist['Program']
        return program
    except:
        try:
            program = plist['ProgramArguments']
            return program
        except:
            return "- No program listed."
        return "- No program listed."

"""
Instantiate an AutorunEntry object and add it to the global list of objects
"""
def process_launchentry(filename, program, launchtype):
    if program[0] == "-":
        fullpath = "-"
        sha256 = "-"
    else:
        if type(program) == list:
            fullpath = program[0]
        else:
            fullpath = program
        with open(fullpath, 'rb') as f:
            data = f.read()
            md5 = hashlib.md5(data).hexdigest()
            sha1 = hashlib.sha1(data).hexdigest()
            sha256 = hashlib.sha256(data).hexdigest()
    entry = AutorunEntry(filename, program, launchtype, md5, sha1, sha256)
    return entry

"""
Enumerate Launch Agents from SYSTEM_LAUNCHAGENTS directory as well
as each user's ~/Library
"""
def enumerate_launchagents():
    launchagents = []
    for root,dirs,files in os.walk(SYSTEM_LAUNCHAGENTS):
        for f in files:
            fullpath = os.path.join(root,f)
            program = get_plist_program(fullpath)
            entry = process_launchentry(f, program, "System LaunchAgent")
            AUTORUNENTRIES.append(entry)
    for user in USERS:
        user_dir = os.path.join('/Users', user)
        user_launchagents_dir = os.path.join(user_dir, '/Library/LaunchAgents')
        for root,dirs,files in os.walk(user_launchagents_dir):
            for f in files:
                fullpath = os.path.join(user_launchagents_dir,f)
                program = get_plist_program(fullpath)
                entry = process_launchentry(f, program, "User LaunchAgent")
                AUTORUNENTRIES.append(entry)

"""
Enumerate Launch Daemons from SYSTEM_LAUNCHDAEMONS directory as well
as each user's ~/Library
"""
def enumerate_launchdaemons():
    launchdaemons = []
    for root,dirs,files in os.walk(SYSTEM_LAUNCHDAEMONS):
        for f in files:
            fullpath = os.path.join(root,f)
            program = get_plist_program(fullpath)
            entry = process_launchentry(f, program, "System LaunchDaemon")
            AUTORUNENTRIES.append(entry)
    for user in USERS:
        user_dir = os.path.join('/Users', user)
        user_launchdaemons_dir = os.path.join(user_dir, '/Library/LaunchDaemons')
        for root,dirs,files in os.walk(user_launchdaemons_dir):
            for f in files:
                fullpath = os.path.join(user_launchdaemons_dir,f)
                program = get_plist_program(fullpath)
                entry = process_launchentry(f, program, "User LaunchDaemon")
                AUTORUNENTRIES.append(entry)

"""
Enumerate each user's cron entries.
at jobs are stored at this location as well. Any at jobs present will may result in undefined behavior.
"""
def enumerate_crons():
    try:
        crondir = '/var/at/tabs'
        crons = os.listdir(crondir)
        for e in crons:
            fullpath = os.path.join(crondir, e)
            with open(fullpath,'r') as f:
                lines = f.readlines()
                for line in lines:
                    line = line.strip()
                    if re.search(r'^#', line) is None:
                        name = e
                        program = line
                        entry = AutorunEntry(name, program, "Cron job", "-", "-", "-")
                        AUTORUNENTRIES.append(entry)
    except PermissionError:
        print("[-] Failed to open cron entries. Try again with sudo.")

"""
Format output similar to autorunsc
"""
def print_results():
    for autoruntype in AUTORUNTYPES:
        print("{0} Entries:".format(autoruntype))
        for entry in AUTORUNENTRIES:
            if entry.autoruntype == autoruntype:
                print("\t{0}:\t{1}".format(entry.name, entry.filepath))
                print("\t\tMD5:\t{0}".format(entry.md5))
                print("\t\tSHA1:\t{0}".format(entry.sha1))
                print("\t\tSHA256:\t{0}".format(entry.sha256))

if __name__ == '__main__':
    enumerate_launchagents()
    enumerate_launchdaemons()
    enumerate_crons()
    print_results()