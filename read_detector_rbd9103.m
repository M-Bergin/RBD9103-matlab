%define the serial port
ttyport='/dev/ttyUSB0';

if isempty(varargin)
    %do a read and return counts
    configure=1;
    read=1;
elseif length(varargin)==1
    %we are probably running in complete count mode
    configure=0;
    read=1;
    N_points=varargin{1};
elseif length(varargin)==2
    %We are either configuring or returning the counter to default mode
    for i=1:2:length(varargin)
        switch lower(varargin{i})
            case 'init'
                configure=1;
                read=0;
            otherwise
                warning(['variable ' varargin{i} ' is not defined']);
        end
    end
    sampling_period=varargin{2};
end

%Check if the port exists and is open and open it if necassary

out = instrfind('Port', ttyport);  % Check to see if the serial port is already defined in MATLAB
if (~isempty(out))  % It is get the handle
    for i=1:length(out)
        if (strcmp(get(out(i), 'Status'),'open'))  % Is it open?
            %yes, then grab the handle
            sph=out(i);
        end
    end
end
if ~exist('sph','var')
    if(configure==0 )
        %error('There is no serial port defined, please init it first')
        disp('The detector isnt initialised, recalling with 15ms sampling interval and 10 points, use read_detector(Init,count_time) to set');
        configure=1;
        sampling_period=15;
        N_points=10;
    end
    sph = serial(ttyport,'BaudRate',57600,'DataBits',8);
    fopen(sph);
end

if configure==1
    %empty the buffer
    flushinput(sph);
    
    %Set the sampling period on the ammeter
    message=['&I',sprintf('%04d',sampling_period)];
    fprintf(sph,message);
    
    %Clear any data filters
    fprintf(sph,'&F000');
    
    %Set device range to 20nA max
    fprintf(sph,'&R2');
    
    %Set device range to autorange
    %fprintf(sph,'&R0')
    
    
end

% Read from the ammeter
if read==1
    
    %empty the buffer
    flushinput(sph);
    
    sph.Timeout=1;
    
    %Initalise Variables
    current=zeros(N_points,1)*NaN;
    received_str{N_points}=[];
    
    %Quickly read in the data
    n=1;
    flushinput(sph);
    while n<N_points+1
        received_str{n}=fscanf(sph);
        if length(received_str{n})==28
            n=n+1;
        else
            
        end
        
    end
    
    
    %Convert the data into currents
    for n=1:N_points
        if length(received_str{n})>12
            if strcmp(received_str{n}(end-3),'m')
                unitd=10^-3;
            elseif strcmp(received_str{n}(end-3),'u')
                unitd=10^-6;
            elseif strcmp(received_str{n}(end-3),'n')
                unitd=10^-9;
            elseif strcmp(received_str{n}(end-3),'p')
                unitd=10^-12;
            else
                unitd=NaN;
            end
            current(n)=abs(str2double(received_str{n}(end-11:end-5))*unitd); %Absolute value taken for if the current is from electrons
        end
    end
    
    %Return the current as counts
    counts=nanmean(current);
    error=nanstd(current)/sum(~isnan(current)); %only if all the points are non NaN
    
end