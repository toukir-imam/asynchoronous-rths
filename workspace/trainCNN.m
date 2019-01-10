function [net, info, trainI, validationI] = trainCNN(data,numEpochs,batchSize,cardIndex,displayFig)
%% Train AlexNet to predict the optimal move
% Vadim Bulitko
% Sep 23, 2016


%% Control Parameters
opts.learningRate = 0.0001;
opts.batchSize = batchSize;
opts.numEpochs = numEpochs;
opts.expDir = 'deepLearning/_optimalMove/_cnn/';
opts.gpus = [cardIndex]; %#ok<NBRAK>


%% Set up
run('matconvnet-1.0-beta20/matlab/vl_setupnn.m');

%% Load the initial network
netFile = 'deepLearning/_optimalMove/_cnn/imagenet-caffe-alex.mat';
net = load(netFile);
% be robust to different save methods
if (isfield(net, 'net'))
    net = net.net;
end
%targetHeight = net.meta.normalization.imageSize(1);
%targetWidth = net.meta.normalization.imageSize(2);
%assert(targetHeight == data.imageHeight);
%assert(targetWidth == data.imageWidth);
%fprintf('\nLoaded %s network\n\n',netFile);

% Split the data into training (75%) and validation (25%) subsets
rng('shuffle');
numData = length(data.class);
numTraining = floor(0.75*numData);
rp = randperm(numData);
opts.train = rp(1:numTraining);
opts.val = rp(numTraining+1:end);
trainI = opts.train;
validationI = opts.val;

opts.errorFunction = 'multiclass';

% fprintf('\t%s spectrograms randomly split into %s training + %s validation\n',...
%     hrNumber(numData),hrNumber(numTraining),hrNumber(numData-numTraining));

%% Modify loaded net to fit our task
net = init_net(net,data.numClasses);

%% Train
batchFn = @getBatch;
[net, info] = cnn_train(net, data, batchFn, ...
    'expDir', opts.expDir, ...
    'learningRate', opts.learningRate, ...
    'batchSize', opts.batchSize, ...
    'numEpochs', opts.numEpochs, ...
    'gpus', opts.gpus, ...
    'train', opts.train, ...
    'val', opts.val, ...
    'errorFunction', opts.errorFunction, ...
    'plotStatistics', displayFig, ...
    'printOut', false, ...
    'saveNet', false, ...
    'continue', false ...
    );

%% Finalize the trained net by removing loss layer and putting in a softmax prob layer
net = finalize_net(net);

%close(fig);

end

function [net] = finalize_net(net)
%% Prepare the network for forward runs

% Remove the softmax loss layer
net.layers = net.layers(1:end-1);

% Put in a soft max instead
net.layers{end+1} = struct( ...
    'type', 'softmax', ...
    'name', 'prob' ...
    );

end

% function [images, labels] = getBatch(data, batch)
% %% getBatch function used by cnn_train
% 
% images = data.input(:,:,:,batch);
% labels = data.class(batch);
% 
% end

function [images, labels] = getBatch(data, batch)
%% getBatch function used by cnn_train
% data is problemDB.data
% batch is the set of indexes

targetHeight = 227;
targetWidth = 227;

labels = data.class(batch);
images = zeros(targetHeight,targetWidth,3,numel(batch),'single');
for i = 1:numel(batch)
    images(:,:,:,i) = imresize2(data.input(:,:,:,batch(i)),[targetHeight,targetWidth]);
end

end


function [net] = init_net(net,numClasses)
%% Modify CNN
%  adjust the last two layers

net = vl_simplenn_tidy(net);

% Remove the last two layers
net.layers = net.layers(1:end-2);

% Put in a fully connected layer
net.layers{end+1} = struct( ...
    'type', 'conv', ...
    'weights', {{0.05*randn(1,1,4096,numClasses, 'single'), zeros(numClasses,1,'single')}}, ...
    'stride', [1 1], ...
    'pad', [0 0 0 0], ...
    'name', 'fc8' ...
    );

% Put in a softmax loss layer
net.layers{end+1} = struct( ...
    'type', 'softmaxloss', ...
    'name', 'softmaxloss' ...
    );
end
