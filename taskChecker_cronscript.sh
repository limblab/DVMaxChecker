#bash script that serves as a wrapper for using TaskChecker inside a cron job
#cd /home/tucker/Desktop/GIT/DVMaxChecker/
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
matlab -nosplash -nodesktop -r "cd('/home/tucker/Desktop/GIT/DVMaxChecker');taskChecker;quit"