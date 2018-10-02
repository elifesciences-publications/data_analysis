function thingy = firingPerVel(time, accelORvel, firingdata, t)
% Takes pos data, timestamps, cluster data, and window size (in seconds)
% outputs average firing rate per velocity/acc
% ASSIGN VELOCITY BEFORE THIS FUNCTION

if size(time, 2) < size(time, 1)
	time = time';
end

if size(accelORvel, 2) < size(accelORvel, 1)
	accelORvel = accelORvel';
end

if size(accelORvel, 2) > size(firingdata, 1)
	firingdata = firingdata';
end

assvel = accelORvel;
%assvel = (assignvel(time,accelORvel));
time = time(1:length(assvel));
assvel = assvel(1,:);



start = min(time);
ending = max(time);

r = mua_rate(firingdata,start,ending,t);
%info = thetaPowerVsTime(lfpdata,time,L,L);
rate = r(2,:); % number of spikes per time bin
size(rate);
fastest = max(rate);
m = length(rate);


avg_accel = zeros(m,1);
for i = 1:m
    avg_accel(i) = mean(assvel((time > start+t*(i-1)) & (time < start+t*i))); % finds average vel within times
end

maxacc = max(avg_accel);

%vbin = [0; 5; 10; 15; 20; 25];
%vbin = [0; 8; 16; 24; 32; 40];
%vbin = [0; 5; 10; 15; 20; 25; 30; 35; 40; 45];
%vbin = [0; 10; 20; 30; 40; 50];
%vbin = [0; 5; 12; 25; 40; 55];
vbin = [0; 10; 20; 30; 40];


average = [];
deviation = zeros(fastest+1,1);
threshold = .01 * length(rate);


i = 1;
while i <= length(vbin)
		 if i==1
			 		subset = rate(avg_accel >= vbin(i) & avg_accel<vbin(i+1));
		 elseif i==length(vbin) %if you wanna go to infinity

						 subset = rate(avg_accel > vbin(i));
		 elseif i<length(vbin) & i>1
     			subset = rate(avg_accel > vbin(i) & avg_accel<vbin(i+1));

		end

     if length(subset) < threshold
			 	average(i) = NaN;
        average(i) = length(firingdata)./(length(time)./(2000*t)); %sub in average rate
     else
        average(i) = mean(subset);
     end
		 i = i+1;
end



thingy = [average];