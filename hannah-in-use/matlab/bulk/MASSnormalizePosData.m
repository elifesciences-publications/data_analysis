function f = MASSnormalizePosData(spikestructure, posstructure, dim)

%This function bins event data based on a user input bin size and
%normalizes based on total time spent in bin
%color maps with range based on highest and lowest three percent of firing
%Args:
%   eventData: A timeseries of cell firings (e.g. the output of abovetheta)
%   posData: The matrix of overall position data with columns [time,x,y]
%   dim: Bin size in cm (only square bins are supported)

spikename = (fieldnames(spikestructure));
spikenum = length(spikename);



set(0,'DefaultFigureVisible', 'off');

xcoord = [];
ycoord = [];
for k = 1:spikenum
    name = char(spikename(k))
    % get date of spike
    date = strsplit(name,'cluster_'); %splitting at year
    date = char(date(1,2));
    date = strsplit(date,'_maze_cl');
    date = char(date(1,1));
    date = strsplit(date,'_box_cl');
    date = char(date(1,1));
    date = strsplit(date,'_rotation_cl');
    date = char(date(1,1));
    date = strsplit(date,'_cl');
    date = char(date(1,1));
    date = strcat(date, '!');
    date = regexp(date,'_1!|_2!|_3!|_4!|_5!|_6!|_7!|_8!|_9!|_10!|_11!|_12!|_13!|_14!|_15!|_16!|_17!|_18!|_19!|_20!|_21!|_22!|_23!|_24!|_25!|_26!|_27!|_28!|_29!|_30!|_31!|_32!','split');
    %date = strsplit(date,'_1!'|'_2!'|'_3!','_4!','_5!','_6!','_7!','_8!','_9!','_10!','_11!','_12!','_13!','_14!','_15!','_16!','_17!','_18!','_19!','_20!','_21!','_22!','_23!','_24!', '_25!', '_26!', '_27!', '_28!', '_29!', '_30!', '_31!', '_32!')
    date = char(date(1,1));
    %date = regexp(date,'(?=[maze])_1_|_2_|_3_|_4_|_5_|_6_|_7_|_8_|_9_|_10_|_11_|_12_|_13_|_14_|_15_|_16_|_17_|_18_|_19_|_20_|_21_|_22_|_23_|_24_|_25_|_26_|_27_|_28_|_29_|_30_|_31_|_32_','split');
    %date = char(date(1,1));
    % formats date to be same as in position structure: date_2015_08_01_acc
    accformateddate = strcat(date, '_acc');
    accformateddate = strcat('date_', accformateddate);
    % formats date to be same as in time structure: date_2015_08_01_time
    timeformateddate = strcat(date, '_time');
    timeformateddate = strcat('date_', timeformateddate);
    % formats date to be same as in time structure: date_2015_08_01_position
    posformateddate = strcat(date, '_position');
    posformateddate = strcat('date_', posformateddate);

    chart = normalizePosData(spikestructure.(name), posstructure.(posformateddate), dim);

    sigma = 1; % set sigma to the value you need
    sz = 2*ceil(2.6 * sigma) + 1; % See note below
    mask = fspecial('gauss', sz, sigma);
    chart = nanconv(chart, mask, 'same');
    [maxValue, linearIndexesOfMaxes] = max(chart(:));

    [colsOfMaxes rowsOfMaxes] = find(chart == maxValue);
    if length(rowsOfMaxes) >1
      v = randi(length(rowsOfMaxes));
      rowsOfMaxes = rowsOfMaxes(v);
      colsOfMaxes = colsOfMaxes(v);
    end


    psize = 3.5 * dim;
    xmax = max(posstructure.(posformateddate)(:,2));
    xbins = ceil(xmax/psize);
    xstep = xmax/xbins;
    xcoord(end+1) = rowsOfMaxes * xstep;

    ymax = max(posstructure.(posformateddate)(:,3));
    ybins = ceil(ymax/psize);
    ystep = ymax/ybins;
    ycoord(end+1) = colsOfMaxes * ystep;



    %newName = strrep(spikename,'_',' ');
    %title(['spike is ' newName ])
end

xlimmin = [000 000 000 000 000 450 750 780 828 780 780];
xlimmax = [505 450 450 505 505 850 1500 1500 1500 1500 1500];
ylimmin = [545 422 320 170 000 300 575 420 339 182 000];
ylimmax = [1500 545 422 320 170 440 1500 575 420 339 182];
%position 1: end of left forced
%position 2: left forced
%position 3: forced choice point
%position 4: right forced
%position 5: end of right forced
%position 6: middle stem
%position 7: end of left choice
%position 8 left choice arm
%position 9: free choice point
%position 10: right choice arm
%position 11: end of right choice arm

posQuad = zeros(length(xcoord), 3);
posQuad(:,2) = xcoord;
posQuad(:,3) = ycoord;

for k=1:length(xlimmin)
  inX = find(xcoord > xlimmin(k) & xcoord <=xlimmax(k));
  inY = find(ycoord > ylimmin(k) & ycoord <=ylimmax(k));
  inboth = intersect(inX, inY);

  if (k == 2 | k== 4 | k == 1 | k==5)         %forced arm
    posQuad(inboth, 1) = 1;
  elseif k == 3                               %forced  point
    posQuad(inboth, 1) = 2;
  elseif k == 6                        %middle
    posQuad(inboth, 1) = 3;
  elseif (k == 8 | k== 10 | k==7 | k==11)                          % choice arm
    posQuad(inboth, 1) = 4;
  elseif k == 9                                    % choicepoint
    posQuad(inboth) = 5;
  end
end

f = posQuad;
