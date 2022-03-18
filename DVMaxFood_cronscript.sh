#bash script that serves as a wrapper for using DVMaxFoodChecker inside a cron job
cd C:/Users/jts3256.GOB/Desktop/GIT/DVMaxChecker
echo "tried running task checker on:">>foodCheckerLog.txt
echo $(date)>>foodCheckerLog.txt
matlab -nosplash -nodesktop -r "cd('C:/Users/jts3256.GOB/Desktop/GIT/DVMaxChecker');DVMaxFoodChecker;quit"