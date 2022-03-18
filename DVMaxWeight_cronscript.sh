#bash script that serves as a wrapper for using DVMaxWaterChecker inside a cron job
#cd /home/tucker/Desktop/GIT/DVMaxChecker/
#bash script that serves as a wrapper for using TaskChecker inside a cron job
cd C:/Users/jts3256.GOB/Desktop/GIT/DVMaxChecker
echo "tried running task checker on:">>weightCheckerLog.txt
echo $(date)>>weightCheckerLog.txt
matlab -r "cd('C:/Users/jts3256.GOB/Desktop/GIT/DVMaxChecker');DVMaxWeightChecker;quit"