#bash script that serves as a wrapper for using monkeyContactUpdater inside a cron job
#cd /home/tucker/Desktop/GIT/DVMaxChecker/
cd /home/joseph/Desktop/GIT/DVMaxChecker/
echo "tried running monkey contact updater on:">>monkeyContactUpdaterLog.txt
echo $(date)>>monkeyContactUpdaterLog.txt
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
matlab -nosplash -nodesktop -r "cd('/home/joseph/Desktop/GIT/DVMaxChecker');monkeyContactUpdater;quit"