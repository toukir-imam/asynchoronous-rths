function networkAccuracy = evalNetworkAccuracy(net,data,validationI,gpuIndex)
%% Evaluate the prediction accuracy of the network on the validation part of the data
% Vadim Bulitko
% Sep 23, 2016

%% Switch to the right card
gpuDevice(gpuIndex);

%% See if we are given validation indecies
if (nargin < 3)
    % no, use the whole set
    validationI = 1:length(data.class);
end

%% Prepare the network for its forward run
net = vl_simplenn_tidy(net) ;
net = vl_simplenn_move(net, 'gpu');
targetHeight = net.meta.normalization.imageSize(1);
targetWidth = net.meta.normalization.imageSize(2);

%% Run through all validation data on the GPU
correct = 0;
for i = validationI
    % Get the validation image
    im = gpuArray(data.input(:,:,:,i));
    im = imresize2(im,[targetHeight,targetWidth]);

    % Run the network
    res = vl_simplenn(net, im, [], [], 'Mode', 'test');
    scores = squeeze(gather(res(end).x));
    [~, predictedClass] = max(scores);
    
    % Check the answer
    if (predictedClass == data.class(i))
        correct = correct + 1;
    end
end

% Compute the accuracy
networkAccuracy = correct / length(validationI);

end
