#bash script that serves as a wrapper for using TaskChecker inside a cron job
cd /home/joseph/Desktop/GIT/DVMaxChecker/
echo "tried running monkey status checker on:">>monkeyStatusLog.txt
echo $(date)>>monkeyStatusLog.txt
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
matlab -nosplash -nodesktop -r "cd('/home/joseph/Desktop/GIT/DVMaxChecker');MonkeyStatusChecker;quit"