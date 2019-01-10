function d = distanceI(i1,i2,mapSize)
%% An index form of distance

[y1,x1] = ind2sub(mapSize,i1);
[y2,x2] = ind2sub(mapSize,i2);
d = distance(x1,y1,x2,y2);

end