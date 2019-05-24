#bash script that serves as a wrapper for using DVMax_checker inside a cron job
#cd /home/tucker/Desktop/GIT/DVMaxChecker/
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
matlab -nosplash -nodesktop -r "cd('/home/joseph/Desktop/GIT/DVMaxChecker');DVMax_checker;quit"

