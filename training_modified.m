clear all
warning off


%###########network and data initialization###############

img_sz=[227 227];

%{
path = {'G_Bulloides','G_Ruber','G_Sacculifer','N_Dutertrei','N_Incompta','N_Pachyderma','Others'};

n = 1;
for K = 1 : length(path)

    %create datastore of the selected folder
    imB = imageDatastore(strcat('Dataset/',path{K}), ...
        'IncludeSubfolders', true, ...
        'LabelSource','foldernames');

    i = 1;
    
    while i < length(imB.Labels)

        [imgR, imgC] = size(readimage(imB,i));
        imgO = zeros(imgR,imgC,16);
        %this loop goes through 16 images at a time and stores the value of
        %each pixel in a 3D matrix
        
        auxI = readimage(imB,i);
        BW = imbinarize(auxI,0.2);
        BW = bwareaopen(BW,8000); 
        BW = imdilate(BW, strel('disk', 30));
        props = regionprops(BW, 'BoundingBox');
        bounds = props.BoundingBox;
%         bounds(1) = bounds(1)-20;
%         bounds(2) = bounds(2)-50;
%         bounds(3) = bounds(3)+50;
%         bounds(4) = bounds(4)+50;

        %imshow(BW); pause(1)


        for j = [1,10,11,12,13,14,15,16,2,3,4,5,6,7,8,9]
            
            
            auxI = imcrop(readimage(imB,i), bounds);
            
            %imshow(auxI)
                
            data_I(:,:,j,n) = imresize(auxI,img_sz);
            
            i = i + 1;
        end
        
        data_L(n) = K;
        n = n+1;

    end
end
%}
load("Dataset.mat", "DATA");

[trainInd,testInd] = dividerand(size(DATA{1},4),0.83,0.17,0);

numClasses = max(DATA{2}); %number of classes in the training set

train_I = DATA{1}(:,:,:,trainInd);
train_L = categorical(DATA{2}(trainInd));

test_I = DATA{1}(:,:,:,testInd);
test_L = categorical(DATA{2}(testInd));



%###########tuning rete############

net = alexnet;  %load AlexNet

miniBatchSize = 30;
learningRate = 2e-4;
metodoOptim='sgdm';
options = trainingOptions(metodoOptim,...
    'MiniBatchSize',miniBatchSize,...
    'MaxEpochs',30,...
    'InitialLearnRate',learningRate,...
    'ExecutionEnvironment','gpu',...
    'Verbose',false,...
    'Plots','training-progress', ...
    'Shuffle','every-epoch',...
    'ValidationData',{test_I,test_L},...
    'OutputNetwork', 'best-validation-loss'...
    );


layersTransfer = net.Layers(2:end-3);

for i = 1:size(layersTransfer,1)
    try
    layersTransfer(i).WeightLearnRateFactor = 1;
    catch
    end
end

layers = [
        imageInputLayer([227 227 16],"Name","imageinput")
        convolution2dLayer([1 1],8,"Name","inconv","Padding","same")
        convolution2dLayer([7 7],3,"Name","inconv","Padding","same")
        layersTransfer
        fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
        softmaxLayer
        classificationLayer
];



%############training############

netTransfer = trainNetwork(train_I, train_L, layers,options);

%############test#############

[YPred,scores] = classify(netTransfer,test_I);

%############data############
accuracy = sum(YPred' == test_L)/size(test_L,2);
disp(accuracy)
confusionchart(test_L,YPred)


%% Visualize convolution

img = train_I(:,:,:,1);
weights = netTransfer.Layers(2,1).Weights;
O(:,:,1) = (convn(img, weights(:,:,:,1),'valid'));
O(:,:,2) = (convn(img, weights(:,:,:,2),'valid'));
O(:,:,3) = (convn(img, weights(:,:,:,3),'valid'));
O = normalize(O);
%imagesc(O);
montage({O(:,:,1),O(:,:,2),O(:,:,3),O})