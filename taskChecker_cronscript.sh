#bash script that serves as a wrapper for using TaskChecker inside a cron job
cd C:/Users/jts3256.GOB/Desktop/GIT/DVMaxChecker
echo "tried running task checker on:">>taskCheckerLog.txt
echo $(date)>>taskCheckerLog.txt
matlab -nosplash -nodesktop -r "cd('C:/Users/jts3256.GOB/Desktop/GIT/DVMaxChecker');taskChecker;quit"