#!/bin/bash

### Shell script to install Galaxy in e.g. Ubuntu Linux. Tested on Biolinux (Ubuntu 12.04 LTS)
### Run as root.

# Define a directory for Galaxy's shared data, e.g. for analyses.
# If DATA_DIR variable has not been edited, the script will prompt the user
# to prepare the data directory and edit this file.
DATA_DIR=""
if [ -z "$DATA_DIR" ]; then
    echo "You must define a directory that Galaxy will use for variable \$DATA_DIR"
    echo "Please decide on a directory where users should find shared data, e.g. for analyses."
    echo "Please edit this file and run again."
    exit
else
	if [ ! -d "$DATA_DIR" -o ! -w "$DATA_DIR" ]; then
    	echo "You need to specify a directory for which this user has permission to write."
    	exit
    fi
fi

# Stop running the galaxy server
service galaxy stop 

# Download Galaxy using Mercurial (hg)
cd /etc
apt-get -y install mercurial
hg clone https://bitbucket.org/galaxy/galaxy-dist/

# Put the old aside, and in with the new!
mv galaxy-server galaxy-server_old
mv galaxy-dist galaxy-server

# Create new config file based on the sample .ini-file, and replace defaults
# with our preferred entries.
cd galaxy-server
cp universe_wsgi.ini.sample universe_wsgi.ini
sed '1,/# Use a threadpool/ s/#host = 127.0.0.1/host = 0.0.0.0/' universe_wsgi.ini > universe_wsgi.ini.tmp && mv -f universe_wsgi.ini.tmp universe_wsgi.ini &&\
sed 's/#library_import_dir = None/library_import_dir = $DATA_DIR/' universe_wsgi.ini > universe_wsgi.ini.tmp && mv -f universe_wsgi.ini.tmp universe_wsgi.ini &&\
sed 's/#allow_library_path_paste = False/allow_library_path_paste = True/' universe_wsgi.ini > universe_wsgi.ini.tmp && mv -f universe_wsgi.ini.tmp universe_wsgi.ini

# Create a Galaxy system user
# useradd -r -s /bin/false galaxy
useradd -s /bin/bash galaxy

# Change ownership of galaxy-server/ to galaxy user
cd /etc
chown -R galaxy:galaxy galaxy-server

# Edit galaxy user's crontab to run Galaxy at startup.
su galaxy
cd ~
crontab -l > crontab_file.tmp
echo "@reboot sh /etc/galaxy-server/run.sh" >> crontab_file.tmp
crontab crontab_file.tmp
rm crontab_file
exit

echo "Setup is complete! Please reboot your computer so Galaxy can start."

exit 0
