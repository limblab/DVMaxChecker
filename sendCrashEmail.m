function sendCrashEmail(maintainerEmailAddress,ME,sourceFunction)
    recepients = maintainerEmailAddress;    
    subject = [sourceFunction,' crashed.'];
    message = {ME.identifier;ME.message};
    for i=1:numel(ME.stack)
        message=[message;{ME.stack(i).file;['line: ' num2str(ME.stack(i).line)]}]; 
    end
    send_mail_message(recepients,subject,message)    
end