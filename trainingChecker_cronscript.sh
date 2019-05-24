#bash script that serves as a wrapper for using trainingChecker inside a cron job
#cd /home/tucker/Desktop/GIT/DVMaxChecker/
cd /home/joseph/Desktop/GIT/DVMaxChecker/
echo "tried running training checker on:">>trainingCheckerLog.txt
echo $(date)>>trainingCheckerLog.txt
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
matlab -nosplash -nodesktop -r "cd('/home/joseph/Desktop/GIT/DVMaxChecker');trainingChecker;quit"