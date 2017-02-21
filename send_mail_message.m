function send_mail_message(id,subject,message,attachment)
%% SEND_MAIL_MESSAGE send email to gmail once calculation is done
% Example
% send_mail_message('its.neeraj','Simulation finished','This is the message area','results.doc')
 
% Pradyumna
% June 2008

%Tucker Tomlinson
%Oct 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Your gmail ID and password 
%(from which email ID you would like to send the mail)
m = 'MillerLabWarnings@northwestern.edu'; 

%get credentials from file:
credentialFile='/home/tucker/authorizationCredentials/MillerLabWarnings.txt';
fid=fopen(credentialFile);

for i=1:2
    tmp=fgetl(fid);
    if strfind(tmp,'password')
        p=tmp(strfind(tmp,':')+1:end);
    elseif strfind(tmp,'user name')
        u=tmp(strfind(tmp,':')+1:end);
    else
        error('sendMailMessage:badAuthfile','could not read credentials from file. file must have two lines one leading with "password:", and the other leading with "user name:"')
    end
end        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 1
    message = subject;
    subject = '';
elseif nargin == 2
    message = '';
    attachment = '';
elseif nargin == 3
    attachment = '';
end

% Send Mail ID
emailto = id;
% emailto = strcat(id,'@gmail.com');
%% Set up NU SMTP service.
% Then this code will set up the preferences properly:
setpref('Internet','E_mail',m);
setpref('Internet','SMTP_Server','smtp.northwestern.edu');
setpref('Internet','SMTP_Username',u);
setpref('Internet','SMTP_Password',p);

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','587');

%% Send the email

if isempty(attachment)
    sendmail(emailto,subject,message)
else
    sendmail(emailto,subject,message,attachment)
end

end
