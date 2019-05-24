#bash script that serves as a wrapper for using DVMaxFoodChecker inside a cron job
#cd /home/tucker/Desktop/GIT/DVMaxChecker/
cd /home/joseph/Desktop/GIT/DVMaxChecker/
echo "tried running food checker on:">>foodCheckerLog.txt
echo $(date)>>foodCheckerLog.txt
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
matlab -nosplash -nodesktop -r "cd('/home/joseph/Desktop/GIT/DVMaxChecker');DVMaxFoodChecker;quit"