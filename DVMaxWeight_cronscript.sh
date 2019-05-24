#bash script that serves as a wrapper for using DVMaxWeightChecker inside a cron job
#cd /home/tucker/Desktop/GIT/DVMaxChecker/
cd /home/joseph/Desktop/GIT/DVMaxChecker/
echo "tried running Weight checker on:">>weightCheckerLog.txt
echo $(date)>>weightCheckerLog.txt
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
matlab -nosplash -nodesktop -r "cd('/home/joseph/Desktop/GIT/DVMaxChecker');DVMaxWeightChecker;quit"