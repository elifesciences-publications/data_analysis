function [f allsizescenters shuffledskew] = MASSplacefieldnumDIRECTIONAL(clusters,posstructure, dim)

      %set(0,'DefaultFigureVisible', 'off');

%determine how many spikes & pos files

allsizes = [];
allcenterXmean = [];
allcenterYmean = [];
allcenterXmax = [];
allcenterYmax = [];
allskew = [];
alldir = [];
alldirskew = [];
clustspikenames = (fieldnames(clusters));
spikenum = length(clustspikenames);
allavpfrate = [];
allmaxpfrate = [];
shuffledskew = NaN(500, 500);
totsnum = 0;
FRAI = [];

posnames = (fieldnames(posstructure));
posnum = length(posnames);
pnames = {};
for s = 1:posnum
  if contains(posnames(s), 'position')==1
    pnames(end+1) = (posnames(s));
  end
end

%output = {'cluster name'; 'cluster size'; 'direction'; 'num of fields'; 'field size in cm'; 'centermax'; 'centermean'; 'skewness'};
output = {'cluster name'; 'cluster size'; 'direction'; '1=to, 2=away'; 'field size in cm'; 'centermax X'; 'centermax Y'; 'skewness'; 'dir skewness'; 'av field rate'; 'max field rate'};

for zzzz = 1:length(pnames)
  currentname = char(pnames(zzzz));
  posData = posstructure.(currentname);
  posData = fixpos(posData);
  % get date of spike
  date = strsplit(currentname,'date_'); %splitting at year rat12_2018_08_20_time
  date = char(date(1,2));
  date = strsplit(date,'_position'); %rat12_2018_08_20
  date = char(date(1,1));

  cnames = {};

  cstart = 0;
  cend = 100000000;

  currentclusts = struct;
  for c = 1:(spikenum)
    name = char(clustspikenames(c));
    date;
    if contains(name, date)==1 & cstart==0
      [currentclusts(:).(name)] = deal(clusters.(name));
    end
  end

  currentclustname = (fieldnames(currentclusts));
  currentnumclust = length(currentclustname);


  if currentnumclust>0

  velthreshold = 12;
  vel = velocity(posData);
  vel(1,:) = smoothdata(vel(1,:), 'gaussian', 30); %originally had this at 30, trying with 15 now
  fastvel = find(vel(1,:) > velthreshold);
  totaltime = length(fastvel)./30;
  posDataFast = posData(fastvel, :);
  xvalsFast = posDataFast(:,2);
  yvalsFast = posDataFast(:,3);

  psize = 3.5 * dim;
  xvals = posDataFast(:,2);
  yvals = posDataFast(:,3);
  xmin = min(posDataFast(:,2));
  ymin = min(posDataFast(:,3));
  xmax = max(posDataFast(:,2));
  ymax = max(posDataFast(:,3));
  xbins = ceil((xmax)/psize); %number of x
  ybins = ceil((ymax)/psize); %number of y
  xinc = (0:xbins)*psize; %makes a vectors of all the x values at each increment
  yinc = (0:ybins)*psize; %makes a vector of all the y values at each increment

  %occupancy
  occ = zeros(xbins, ybins);
  testing = 0;
  for x = (1:xbins)
    for y = (1:ybins)
      if x<xbins & y<ybins
      occx = find(xvalsFast>=xinc(x) & xvalsFast<xinc(x+1));
      occy = find(yvalsFast>=yinc(y) & yvalsFast<yinc(y+1));
      elseif x==xbins & y<ybins
      occx = find(xvalsFast>=xinc(x));
      occy = find(yvalsFast>=yinc(y) & yvalsFast<yinc(y+1));
      elseif x<xbins & y==ybins
      occx = find(xvalsFast>=xinc(x) & xvalsFast<xinc(x+1));
      occy = find(yvalsFast>=yinc(y));
      elseif x==xbins & y==ybins
      occx = find(xvalsFast>=xinc(x));
      occy = find(yvalsFast>=yinc(y));
      end

      if length(intersect(occx, occy)) == 0
      occ(x,y) = NaN;
      else
      occ(x,y) = length(intersect(occx, occy));
      end
  end
  end

numocc = occ(~isnan(occ));
occtotal = sum(((numocc)), 'all');
occprobs = occ./(occtotal);

%Sum of (occprobs * mean firing rate per bin / meanrate) * log2 (mean firing rate per bin / meanrate)

%spike rates

for c = 1:(currentnumclust)

    name = char(currentclustname(c))
    clust = currentclusts.(name);
    clustsize = length(clust);
    [clustmin indexmin] = min(abs(posData(1,1)-clust));
    [clustmax indexmax] = min(abs(posData(end,1)-clust));
    clust = clust(indexmin:indexmax);


    assvel = assignvelOLD(clust, vel);
    fastspikeindex = find(assvel > velthreshold);
    %meanrate = length(fastspikeindex)./(totaltime); %WANT ONLY AT HIGH VEL



    %finding directionality per spike
    dirinfo = direction(clust(fastspikeindex), posData); %outputs [timevector; xposvector; yposvector; fxvector; fyvector];
    size(dirinfo);
    %if left forced or right choice is negative in y direction, toward reward
    %if right forced or left choice is positive in y direction, toward reward
    %if middle is positive in x direction, toward reward
    %if middle is negative in x direction, away from reward
            %   1   2   3   4   5
    xlimmin = [300 300  750 780 430];
    xlimmax = [505 505  950 950 870];
    ylimmin = [370 000  380 000 300];
    ylimmax = [700 370  700 380 440];
    %position 1: left forced
    %position 2: right forced
    %position 3: left choice arm
    %position 4: right choice arm
    %position 5: middle stem

      toreward = [];
      awayreward = [];
      for k=1:length(xlimmin)

        inX = find(dirinfo(2,:) > xlimmin(k) & dirinfo(2,:) <=xlimmax(k)); %check to make sure correct indexing
        inY = find(dirinfo(3,:) > ylimmin(k) & dirinfo(3,:) <=ylimmax(k));
        inboth = intersect(inX, inY);
        if (k == 1 | k== 4) %if left forced or right choice is negative in y direction, toward reward
          yneg = find(dirinfo(5,:)<0);
          ypos = find(dirinfo(5,:)>0);
          toreward = [toreward, intersect(inboth, yneg)]; %indices of to
          awayreward = [awayreward, intersect(inboth, ypos)];

        elseif (k == 2 | k== 3) %if right forced or left choice is positive in y direction, toward reward
          yneg = find(dirinfo(5,:)<0);
          ypos = find(dirinfo(5,:)>0);
          awayreward = [awayreward, intersect(inboth, yneg)]; %indices of to
          toreward = [toreward, intersect(inboth, ypos)];
        elseif (k == 5) %if middle is positive in x direction, toward reward
          xneg = find(dirinfo(4,:)<0);
          xpos = find(dirinfo(4,:)>0);
          toreward = [toreward, intersect(inboth, xpos)]; %indices of to
          awayreward = [awayreward, intersect(inboth, xneg)];
        end
      end

      testing = intersect(toreward, awayreward);
      dirinfo(:, testing)';
      torewardspikes = dirinfo(1,toreward);
      size(torewardspikes);
      awayrewardspikes = dirinfo(1,awayreward);
      size(awayrewardspikes);


      %%%%%%%%%%%%

    %NOW DO CHARTS AND EVERYTHING FOR BOTH
    %spiking normalization chart
  for zdir=1:2;
      if zdir ==1;
        spikestochart = torewardspikes;
        dir = 'to';
        currentdir = 1;
      else
        spikestochart = awayrewardspikes;
        dir = 'away';
        currentdir = 2;
      end


    spikestochart = cutclosest(posDataFast(1,1), posDataFast(end,1), spikestochart, spikestochart);
    if length(spikestochart)<2
      continue
    end


    [chart spikegraph timegraph] = normalizePosData(spikestochart, posDataFast, dim);

    chart = chartinterp(chart);
    spikegraph = chartinterp(spikegraph);
    timegraph = chartinterp(timegraph);


    %smoothing spiking normalization

    chart = ndnanfilter(chart, 'gausswin', [10/dim, 10/dim], 2, {}, {'symmetric'}, 1);
    spikegraph = ndnanfilter(spikegraph, 'gausswin', [10/dim, 10/dim], 2, {}, {'symmetric'}, 1);
    timegraph = ndnanfilter(timegraph, 'gausswin', [10/dim, 10/dim], 2, {}, {'symmetric'}, 1);

    chartlin = sort(chart(:));
    chartlin = chartlin(~isnan(chartlin));
    chartnozero = mean(chartlin(find(chartlin>0)));
    chartlinstd = std(chartlin);
    chartlinmedian = median(chartlin);
    chartlinmean = mean(chartlin);



    %divided into 5cm by 5cm bins
    %place fields are 5 or more adjacent picels with a firing rate >3xmean unit rate
    %finds mean rate


    meanrate = nanmean(chart(:));
    maxrate = max(chart(:));
    chart(isnan(chart)) = 0;
    spikegraph(isnan(spikegraph)) = 0;
    timegraph(isnan(timegraph)) = 0;



    %finds maxes
    actualmax = imregionalmax(chart); %maxes are where there is a 1 on this chart
    [I,J] = find(actualmax==1);
    linearmax = sub2ind(size(actualmax), I, J); %linear indices

    %finds areas where firing > 3x mean. those are marked with a 1 on the chart
      [I,J] = find(chart>=chartlinmean+(1*(chartlinstd)));

    %[I,J] = find(chart>=3*meanrate);


    chartmax = zeros(size(chart));


    for p=1:length(I)
      chartmax(I(p),J(p)) = 1;
    end

    CC = bwconncomp(chartmax,4); %finds pixels connected by sides
    numfields = 0;
    fieldsize = [];
    centermax = [];
    centermean =[];


    for z=1:length(CC.PixelIdxList)


      [Yindex, Xindex] = ind2sub(size(chartmax),cell2mat(CC.PixelIdxList(z)));
      YM = length(unique(Yindex));
      XM = length(unique(Xindex));

        [centerY, centerX] = ind2sub(size(chartmax),cell2mat(CC.PixelIdxList(z)));
        yvals_real = ybins-centerY;
        yvals_real = (ymax)./ybins * yvals_real;
        xvals_real = (xmax)./xbins * centerX;

        %corner points so can find distance around the bend
        C1 = [417, 365];
        C2 = [854, 380];
        dis = 100;
        for x=1:length(yvals_real);
          disnew1 = pdist([C1; xvals_real(x), yvals_real(x)]);
          disnew2 = pdist([C2; xvals_real(x), yvals_real(x)]);
          disnew = min(disnew1, disnew2);
          if disnew<dis
            dis = disnew;
          end
        end
        if dis*dim/3.5<5
          wantedY = find(yvals_real>345 | yvals_real<388); %these are in the arms
          wantedX = find(yvals_real<=345 | yvals_real>=388); %this is center. finding with Y but these are the X values
          YM = length(unique(yvals_real(wantedY)));
          XM = length(unique(xvals_real(wantedX)));
          fsize = YM+XM;
        else
          fsize = max([YM; XM]);
        end

        fsize = fsize*dim;


        curr = (chart(Yindex, Xindex));
        currspikegraph = (spikegraph(Yindex, Xindex));
        currtimegraph= (timegraph(Yindex, Xindex));



      if fsize>=15 & max(curr(:))>=chartlinmean+(2*(chartlinstd))
        fieldsize(end+1) = fsize;
        %find all instances where animal goes through place field

        %finds indices of place fields
        [centerY, centerX] = ind2sub(size(chartmax),cell2mat(CC.PixelIdxList(z)));
        %converts indices to actual values
        realX = (xmax)./xbins .* centerX;
        realY = (ymax)./ybins .* centerY;

        currentrates = chart(centerY, centerX);
        %currspikegraph2 = spikegraph(centerY, centerX);
        %currtimegraph2= timegraph(centerY, centerX);

        avpfrate = nanmean(currentrates(:));
        maxpfrate = max(currentrates(:));





        numfields = numfields+1;
        [centerY, centerX] = ind2sub(size(chartmax),cell2mat(CC.PixelIdxList(z)));

        xbins = ceil((xmax)/psize);
        ybins = ceil((ymax)/psize);


        newchart = zeros(size(chart));
        newchart(centerY, centerX) = chart(centerY, centerX);
        M = max(newchart, [], 'all');
        [centerYmax, centerXmax] = find(newchart==M);
        centerYmax = ybins-centerYmax; %here?
        newchart(find(newchart==0))=NaN;

        newspikegraph  = zeros(size(chart));
        newtimegraph  = zeros(size(chart));
        newspikegraph(centerY, centerX) = spikegraph(centerY, centerX);
        newtimegraph(centerY, centerX) = timegraph(centerY, centerX);
        newspikegraph(find(newspikegraph==0))=NaN;
        newtimegraph(find(newtimegraph==0))=NaN;






        centerXmean = nanmean(centerX);
        centerYmean = nanmean(centerY);
        centerYmean = ybins-centerYmean;
        centerXmean = (xmax)./xbins * centerXmean;
        centerYmean = (ymax)./ybins * centerYmean;


        %The skewness was defined, in dimensionless units, as the ratio of the third
        %moment of the place field firing rate distribution divided by the cube of the
        %standard deviation (Spiegel 1994).

        %5 used to be 440 820 340 420
        xlimmin = [300 300  750 780 ];
        xlimmax = [505 505  950 950 ];
        ylimmin = [370 000  380 000 ];
        ylimmax = [700 370  700 380 ];


        for k=1:length(xlimmin)
          if centerYmean<380 & centerYmean>340 & size(newchart,2)>size(newchart,1)%center area so place field could go horizontally or vertically
                k=5;
                flattened = nanmean(newchart,1);
                flattenednewspikegraph = nanmean(newspikegraph,1);
                flattenednewtimegraph = nanmean(newtimegraph,1);
                newflattened = flattened;

            else
                inX = find(centerXmean > xlimmin(k) & centerXmean <=xlimmax(k)); %check to make sure correct indexing
                inY = find(centerYmean > ylimmin(k) & centerYmean <=ylimmax(k));
                inboth = intersect(inX, inY);
                if length(inboth)>0
                  flattened = nanmean(newchart,2)'; %need this directional
                  flattenednewspikegraph = nanmean(newspikegraph,2)';
                  flattenednewtimegraph = nanmean(newtimegraph,2)';
                  %need to flip right forced and left choice
                  if (k == 1 | k== 4)
                    newflattened = flattened;
                  elseif (k == 2 | k== 3)
                    newflattened = flip(flattened);
                    flattenednewspikegraph = flip(flattenednewspikegraph);
                    flattenednewtimegraph = flip(flattenednewtimegraph);
                  end


              end
          end
        end



        flatstart = (find(newflattened>0));

        newflattened = newflattened(flatstart(1):end);
        flattenednewspikegraph = flattenednewspikegraph(flatstart(1):end);
        flattenednewtimegraph = flattenednewtimegraph(flatstart(1):end);


        F1 = 0;
        F2 = 0;
        F1t = 0;
        F2t = 0;
        for ts=1:length(flattenednewspikegraph)
          if F1<=(nansum(flattenednewspikegraph)./2) & isnan(flattenednewspikegraph(ts))==0
            F1 = F1+flattenednewspikegraph(ts);
            F1t = F1t+flattenednewtimegraph(ts);
        elseif F1>=(nansum(flattenednewspikegraph)./2) & isnan(flattenednewspikegraph(ts))==0
            F2 = F2+flattenednewspikegraph(ts);
            F2t = F2t+flattenednewtimegraph(ts);
          end
        end




        FRAItemp = ((F1/F1t)-(F2/F2t)) ./ ((F1/F1t)+(F2/F2t));


        %SHUFFLE
        %SHUFFLE
        totsnum = totsnum+1;
        %for sss=1:500 %SHUFFLE
        %  newflattened = newflattened(~isnan(newflattened)); %SHUFFLE
        %  newflattened = newflattened(randperm(length(newflattened))); %SHUFFLE






        counter = 0;
        flatmean = 0;
        countersum = 0;


        for kk = 1:length(newflattened)
          if newflattened(kk)>0
          flatmean = flatmean+(kk*newflattened(kk));
          counter = counter+1;
          countersum = countersum+newflattened(kk);
          end
        end
        flatmean = flatmean./countersum;


        flatmom = 0;
        temp = [];
        for kk = 1:length(newflattened)
          if newflattened(kk)>0
            kk-flatmean;
            temp(end+1)= ((kk-flatmean)^3)*newflattened(kk);
          flatmom = flatmom+((kk-flatmean)^3)*newflattened(kk);
          end
        end



        flatstd = 0;
        for kk = 1:length(newflattened)
          if newflattened(kk)>0
          flatstd = flatstd+((kk-flatmean)^2)*newflattened(kk);
        end
        end

        flatstd = sqrt(flatstd);


        if length(newflattened(~isnan(newflattened)))>2
          skewness = flatmom./(flatstd^3);
        else
          skewness = NaN;
        end


%%%%%%%%%%%%%%%%
%%here to find directional skewness, positive means skewed in the direction of travel
      if currentdir == 1
        dirskewness = skewness;
        FRAI(end+1) = FRAItemp;
      elseif currentdir ==2
        dirskewness = skewness.*-1;
        FRAI(end+1) = FRAItemp.*-1;
      end
%  if maxrate >= .5 %SHUFFLE
%    shuffledskew(sss, totsnum) = dirskewness; %SHUFFLE
%  end %shuffle
%    end %%SHUFFLE


        centerXmax = (xmax)./xbins * centerXmax;
        centerYmax = (ymax)./ybins * centerYmax;
        centermax(end+1:end+2) = [centerXmax(1), centerYmax(1)];

        centerXmean = nanmean(centerX);
        centerYmean = nanmean(centerY);
        centerYmean = ybins-centerYmean;
        centerXmean = (xmax)./xbins * centerXmean;
        centerYmean = (ymax)./ybins * centerYmean;
        centermean(end+1:end+2) = [centerXmean, centerYmean];


        if maxrate >= .5 %& centerYmean < 580 & centerYmean > 190
        allsizes(end+1) = fieldsize(end);
        allcenterXmean(end+1) = centerXmean;
        allcenterYmean(end+1) = centerYmean;
        allcenterXmax(end+1) = centerXmax(1);
        allcenterYmax(end+1) = centerYmax(1);
        allskew(end+1) = skewness;
        alldir(end+1) = currentdir;
        alldirskew(end+1) = dirskewness;
        allavpfrate(end+1) = avpfrate;
        allmaxpfrate(end+1) = maxpfrate;
      else
          numfields = NaN;
          fieldsize = NaN;
          allsizes(end+1) = NaN;
          allcenterXmean(end+1) = NaN;
          allcenterYmean(end+1) = NaN;
          allcenterXmax(end+1) = NaN;
          allcenterYmax(end+1) = NaN;
          allskew(end+1) = NaN;
          alldir(end+1) = currentdir;
          alldirskew(end+1) = NaN;
          allavpfrate(end+1) = NaN;
          allmaxpfrate(end+1) = NaN;
        end

        newdata = {name; clustsize; dir; alldir(end); allsizes(end); allcenterXmax(end); allcenterYmax(end); allskew(end); alldirskew(end); avpfrate(end); maxpfrate(end)};
        output = horzcat(output, newdata);
      end



    end

    %maximum firing rate >= .5hz

    %newdata = {name; clustsize; dir; numfields; fieldsize; centermean; centermax; skewness};
    %output = horzcat(output, newdata);
  end

end
end

end

f = output';

%if you want seperate choice points
xlimmin = [300 300 320 320 320 450 750 780 828 780 780];
xlimmax = [505 450 450 505 505 850 950 950 950 950 950];
ylimmin = [545 422 320 170 000 300 575 420 339 182 000];
ylimmax = [700 545 422 320 170 440 700 575 420 339 182];
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

%1 = 1, 2 and 4,5 grouped as forced arms
%2 = 3 is forced point
%3 = 6 is middle stem
%4 = 7,8 and 10,11 grouped as choice arms
%5 = 9 is free choice point
posQuadmax = zeros(length(allcenterXmax), 1);
for k=1:length(xlimmin)
  inX = find(allcenterXmax > xlimmin(k) & allcenterXmax <=xlimmax(k));
  inY = find(allcenterYmax > ylimmin(k) & allcenterYmax <=ylimmax(k));
  inboth = intersect(inX, inY);
  if (k == 2 | k== 4)        %|k== 1 | k== 5 %& vel(inboth(z))>threshold
    posQuadmax(inboth) = 1;
  elseif k == 3                                 %& vel(inboth(z))>threshold
    posQuadmax(inboth) = 2;
  elseif (k== 1 | k== 5)
    posQuadmax(inboth) = 0;
  elseif k == 6                        %& vel(inboth(z))>threshold
    posQuadmax(inboth) = 3;
  elseif (k == 8 | k== 10 )                %| k== 7 | k== 11          %& vel(inboth(z))>threshold
    posQuadmax(inboth) = 5;
  elseif (k== 7 | k== 11)
    posQuadmax(inboth) = 6;
  elseif k == 9                                    %& vel(inboth(z))>threshold
    posQuadmax(inboth) = 4;
  else
    posQuadmax(inboth) = NaN;
  end
end

want = ~isnan(shuffledskew(1,:));
shuffledskew = shuffledskew(:,want);

size(allmaxpfrate)
size(posQuadmax)
allsizescenters = [alldir; allsizes; allcenterXmax; allcenterYmax; allskew; alldirskew; allavpfrate; allmaxpfrate; posQuadmax'; FRAI]';
