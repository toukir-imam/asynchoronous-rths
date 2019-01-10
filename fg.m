function r = fg(a,b)
% fg (floating point greater)
% returns true if a > b robustly

epsilon = 0.0001;

r = (a > (b + epsilon));
end
