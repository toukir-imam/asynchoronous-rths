function r = fe(a,b)
% fe (floating point equal)
% returns true if abs(a-b) < epsilon

epsilon = 0.0001;

r = (abs(a-b) < epsilon);
end
