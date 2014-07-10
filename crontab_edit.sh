#!/bin/bash

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