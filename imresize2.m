function img_out = imresize2(img_in,outputSize)
%% An alternative to imresize
% Adapted from https://www.mathworks.com/matlabcentral/fileexchange/30787-image-resize
% Author: DGM https://www.mathworks.com/matlabcentral/profile/authors/6733114-dgm

%% Check if we have the real imresize
if (exist('imresize','builtin'))  
    img_out = imresize(img_in,outputSize);
    return
end

%% Preliminaries
inputSize = size(img_in);
numChannels = size(img_in,3);

scale = outputSize ./ inputSize(1:2);
yscale = scale(1);
xscale = scale(2);

yy = linspace(1,inputSize(1),ceil(inputSize(1)*yscale));
xx = linspace(1,inputSize(2),ceil(inputSize(2)*xscale));

%% Resize
if (isa(img_in,'gpuArray'))
    img_out = zeros([ceil(inputSize(1:2).*[yscale xscale]) numChannels],'single','gpuArray');
else
    img_out = zeros([ceil(inputSize(1:2).*[yscale xscale]) numChannels],'single');
end

for channel = 1:numChannels
    img_out(:,:,channel) = interp2(img_in(:,:,channel),xx',yy,'linear');
end

%% Check the output size
% If the image size is wrong (due to scale factor rounding) then try again
if (size(img_out,1) ~= outputSize(1) || size(img_out,2) ~= outputSize(2))
    img_out = imresize2(img_out,outputSize);
    % If the second try didn't work, give up
    assert(size(img_out,1) == outputSize(1) && size(img_out,2) == outputSize(2));
end

end
