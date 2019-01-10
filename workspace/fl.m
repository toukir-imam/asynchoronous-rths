function r = fl(a,b)
% fl (floating point less)
% returns true if a < b robustly

epsilon = 0.0001;

r = (a < (b - epsilon));
end