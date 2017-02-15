% Read in serial data
%   Eric Koch, 1/14/17
clc, clear all, close all

% Find active port with serial data
instrInfo = instrhwinfo('serial');
num_ports = numel(instrInfo.AvailableSerialPorts);
if num_ports==0
    error('NO ACTIVE SERIAL PORTS FOUND. CHECK TO ENSURE SERIAL DEVICE IS CONNECTED')
elseif num_ports>0
    ii = 1;
    while ii < num_ports+1
        tmpport = instrInfo.SerialPorts{ii};
        tmpser = serial(tmpport);
        fopen(tmpser);
        pause(2);
        if tmpser.BytesAvailable > 0
            Port = instrInfo.SerialPorts{ii};
            ii = num_ports + 1;
        end
        ii = ii + 1;
        fclose(tmpser);
        delete(tmpser)
        clear tmpser tmpport      
    end
    clear num_ports ii
end

% Port = instrInfo.SerialPorts{1};
% newobj = instrfindall

% create serial object on available port
s1 = serial(Port); % Must change port to correct one for situation
BR = get(s1,'BaudRate');
set(s1,'BaudRate',BR);
set(s1,'Timeout',10);

% open connection to serial port object
fopen(s1);

% configure recording
% s1.RecordDetail = 'verbose';

% generate file name
dt = datestr(now,'dd_mmm_yy');
file = strcat('testdata_',dt,'.txt');
% file = 'myrecord.txt';

% create new file with index number instead of overwriting if file exists
if exist(file)>0
    ind = 1;
    file = strcat('testdata_',dt,'_',num2str(ind),'.txt');
    while exist(file)>0
        ind = ind+1;
        file = strcat('testdata_',dt,'_',num2str(ind),'.txt');
    end
end

fid = fopen(file,'w+');
fprintf(fid,'Test Data\n');
fprintf(fid,strcat(datestr(now),'\n'));
fclose(fid);
fid = fopen(file,'a+');
% s1.RecordMode = 'index';
% s1.RecordName = file;

% Begin recording data from serial port object to file
% record(s1,'on')
ii = 1;
pause(5);
while s1.BytesAvailable > 0 && ii<10
    read = fread(s1)';
    read1 = char(read)
%     read = num2str(read);
%     out(ii,:) = read;
    fprintf(fid,read1);
    ii = ii+1;
    pause(0.5);
end

% record(s1,'off')
% s1.RecordName

% get rid of serial object when done
fclose(fid);
fclose(s1);
delete(s1)
clear s1
