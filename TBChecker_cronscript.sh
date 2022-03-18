#bash script that serves as a wrapper for using DTBChecker inside a cron job
#cd /home/tucker/Desktop/GIT/DVMaxChecker/

cd C:/Users/jts3256.GOB/Desktop/GIT/DVMaxChecker
echo "tried running task checker on:">>TBCheckerLog.txt
echo $(date)>>TBCheckerLog.txt
matlab -nosplash -nodesktop -r "cd('C:/Users/jts3256.GOB/Desktop/GIT/DVMaxChecker');TBChecker;quit"

