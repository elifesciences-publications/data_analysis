function f = POSdecodetrigger(triggertimeONLY, pos, clusters, dim, tdecode, windowsz)
%decodes position around trigger times


timeshift = windowsz;

triggertime = triggertimeONLY;
if size(triggertime,1)<size(triggertime,2)
  triggertime = triggertime';
end



tdecodesec = tdecode;
tdecode = tdecode*2000;

  temp = ceil(timeshift/tdecodesec);
  triggertime = triggertime;
  SWRstart = triggertime-(tdecodesec*temp);
  SWRend = triggertime+(tdecodesec*temp);


posData = pos;
%timevector = time;

t = tdecode;
t = 2000*t;
tm = 1;

%find number of clusters
clustname = (fieldnames(clusters));
numclust = length(clustname);

%BIN
psize = 3.5 * dim;

xvals = posData(:,2);
yvals = posData(:,3);
xmin = min(posData(:,2));
ymin = min(posData(:,3));
xmax = max(posData(:,2));
ymax = max(posData(:,3));
xbins = ceil((xmax-xmin)/psize); %number of x
ybins = ceil((ymax-ymin)/psize); %number of y


xinc = xmin +(0:xbins)*psize; %makes a vectors of all the x values at each increment
yinc = ymin +(0:ybins)*psize; %makes a vector of all the y values at each increment


% for each cluster,find the firing rate at esch velocity range
fxmatrix = firingPerPos(pos, clusters, dim, tdecodesec);
%outputs a structure of rates

maxprob = [];
spikenum = 1;
times = [];
percents = [];
numcel = [];
maxx = [];
maxy = [];
same = 0;

n =0;
nivector = zeros((numclust),1);
r =1;
while r <= (length(triggertime))
  maxy = [];
  maxx = [];
  percents = [];
   %find spikes in each cluster for time
   tm = SWRstart(r);
   for count = 1:(windowsz*2)./tdecodesec
      %find spikes in each cluster for time
      for c=1:numclust   %permute through cluster
        name = char(clustname(c));
        nivector(c) = length(find(clusters.(name)>=tm & clusters.(name)<tm+tdecodesec));
      end

         %for the cluster, permute through the different conditions
       endprob = zeros(xbins, ybins);
           for x = (1:xbins) %WANT TO PERMUTE THROUGH EACH SQUARE OF SPACE SKIPPING NON OCCUPIED SQUARES. SO EACH BIN SHOULD HAVE TWO COORDINATES
             for y = (1:ybins)
             productme =0;
             expme = 0;
             c = 1;

             if x<xbins & y<ybins
               occx = find(xvals>=xinc(x) & xvals<xinc(x+1));
               occy = find(yvals>=yinc(y) & yvals<yinc(y+1));
             elseif x==xbins & y<ybins
               occx = find(xvals>=xinc(x));
               occy = find(yvals>=yinc(y) & yvals<yinc(y+1));
             elseif x<xbins & y==ybins
               occx = find(xvals>=xinc(x) & xvals<xinc(x+1));
               occy = find(yvals>=yinc(y));
             elseif x==xbins & y==ybins
               occx = find(xvals>=xinc(x));
               occy = find(yvals>=yinc(y));
             end

             if length(occx) == 0  & length(occy)==0 %means never went there, dont consider
               endprob(x,y) = NaN;
               break
             end
             for c=1:numclust  %permute through cluster
                 ni = nivector(c);
                 name = char(clustname(c));
                 fx = fxmatrix.(name);
                 fx = (fx(x, y));

                 if fx ~= 0
                   productme = productme + (ni)*log(fx);  %IN
                 else
                   fx = .00000000000000000000001;
                   fprintf('zero thing isnt working')
                   productme = productme + (ni)*log(fx);
                 end

                 expme = (expme) + (fx);
                  % goes to next cell, same location

             end
             numcel(end+1) = (ni);
             % now have all cells at that location
             tmm = tdecodesec;
           endprob(x, y) = (productme) + (-tmm.*expme); %IN
           end
           end

           [maxvalx, maxvaly] = find(endprob == max(endprob(:)));

           mp = max(endprob(:))-12;

         endprob = exp(endprob-mp);


            %finds indices
           conv = 1./sum(endprob(~isnan(endprob)), 'all');
           endprob = endprob.*conv; %matrix of percents
           %percents = vertcat(percents, endprob);

           percents(end+1) = max(endprob(:)); %finds confidence
           if length(maxvalx) > 1 %if probs are the sample, randomly pick one and print warning
               same = same+1;
               maxvalx = datasample(maxvalx, 1);
               maxvaly = datasample(maxvaly, 1);

           end

               if length(maxvalx)<1 | length(maxvaly) <1
                 maxx(end+1) = NaN;
                 maxy(end+1) = NaN;
                 perents(end)
               else
                 maxx(end+1) = (xinc(maxvalx)); %translates to x and y coordinates
                 maxy(end+1) = (yinc(maxvaly));
               end




         tm = tm+tdecodesec;

   end

SIZETEST = size(maxx);
SIZETEST = size(maxy);

if r == 1
  allSWRx = [maxx];
  allSWRy = [maxy];
  allpercents = [percents];
else
  allSWRx = [allSWRx; maxx];
  allSWRy = [allSWRy; maxy];

  allpercents = [allpercents; percents];
end

size(allSWRx);
size(allSWRy);


r = r+1

end

%warning('your probabilities were the same')
%same = same
allSWRx = allSWRx+psize/2;
allSWRy = allSWRy+psize/2;



f.x = allSWRx;
f.y = allSWRy;
f.percents = allpercents;
