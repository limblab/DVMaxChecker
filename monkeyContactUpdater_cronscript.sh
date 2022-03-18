#bash script that serves as a wrapper for using monkeyContactUpdater inside a cron job
#cd /home/tucker/Desktop/GIT/DVMaxChecker/

cd C:/Users/jts3256.GOB/Desktop/GIT/DVMaxChecker
echo "tried running task checker on:">>monkeyContactUpdaterLog.txt
echo $(date)>>monkeyContactUpdaterLog.txt
matlab -nosplash -nodesktop -r "cd('C:/Users/jts3256.GOB/Desktop/GIT/DVMaxChecker');monkeyContactUpdater;quit"
