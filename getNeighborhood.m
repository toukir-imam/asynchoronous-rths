function neighborhood = getNeighborhood(map,i,r)
%% Gets a neighborhood of radius r centered in position i from the map
% Vadim Bulitko
% May 15, 2016

% Initialize
neighborhood = true(2*r+1,2*r+1);

% Compute coordinate ranges
[y,x] = ind2sub(size(map),i);

xMin = max(1,x-r);
xMax = min(size(map,2),x+r);
yMin = max(1,y-r);
yMax = min(size(map,1),y+r);

% Map range
xRange = xMin:xMax;
yRange = yMin:yMax;

% Neighborhood range
xRangeN = (xRange-x)+r+1;
yRangeN = (yRange-y)+r+1;

% Copy
neighborhood(yRangeN,xRangeN) = map(yRange,xRange);

end
