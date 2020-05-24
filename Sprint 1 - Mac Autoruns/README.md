# Mac Autoruns
This script performs some of the same functions as the Sys Internals tool autoruns. It enumerates a subset of the persistence locations identified by SentinelOne.

# Requirements
* Python3

# Usage
The script takes no arguments.
```
sudo python3 autoruns.py
```
`sudo` is required to enumerate cron entries and system level plist files. The script can be run with normal user privileges, but the data returned will be incomplete.

## Information
The script will enumerate the programs called by Launch Agents/Daemons and hash those programs. For cron jobs, each cron entry will be returned, but no hashing will occur.

# Resources
[Autoruns](https://docs.microsoft.com/en-us/sysinternals/downloads/autoruns)
[How Malware Persists on MacOS](https://www.sentinelone.com/blog/how-malware-persists-on-macos/)