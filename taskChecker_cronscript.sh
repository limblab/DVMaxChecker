#bash script that serves as a wrapper for using TaskChecker inside a cron job
cd /home/joseph/Desktop/GIT/DVMaxChecker/
echo "tried running task checker on:">>taskCheckerLog.txt
echo $(date)>>taskCheckerLog.txt
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
matlab -nosplash -nodesktop -r "cd('/home/joseph/Desktop/GIT/DVMaxChecker');taskChecker;quit"