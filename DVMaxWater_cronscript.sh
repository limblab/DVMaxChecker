#bash script that serves as a wrapper for using DVMaxWaterChecker inside a cron job
#cd /home/tucker/Desktop/GIT/DVMaxChecker/
cd /home/joseph/Desktop/GIT/DVMaxChecker/
echo "tried running water checker on:">>waterCheckerLog.txt
echo $(date)>>waterCheckerLog.txt
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
matlab -nosplash -nodesktop -r "cd('/home/joseph/Desktop/GIT/DVMaxChecker');DVMaxWaterChecker;quit"