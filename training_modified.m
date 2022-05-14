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

        for j = [1,10,11,12,13,14,15,16,2,3,4,5,6,7,8,9]
            
            data_I(:,:,j,n) = imresize(readimage(imB,i),img_sz);
            
            i = i + 1;
        end
        
        data_L(n) = K;
        n = n+1;

    end
end
%}
load("Dataset_I.mat", "data_I")
load("Dataset_L.mat", "data_L")

[trainInd,testInd] = dividerand(size(data_L,2),0.83,0.17,0);

numClasses = max(data_L); %number of classes in the training set

train_I = data_I(:,:,:,trainInd);
train_L = categorical(data_L(trainInd));

test_I = data_I(:,:,:,testInd);
test_L = categorical(data_L(testInd));



%###########tuning rete############

net = alexnet;  %load AlexNet

miniBatchSize = 30;
learningRate = 1e-4;
metodoOptim='sgdm';
options = trainingOptions(metodoOptim,...
    'MiniBatchSize',miniBatchSize,...
    'MaxEpochs',30,...
    'InitialLearnRate',learningRate,...
    'ExecutionEnvironment','gpu',...
    'Verbose',false,...
    'Plots','training-progress');



layersTransfer = net.Layers(2:end-3);
layers = [
        imageInputLayer([227 227 16],"Name","imageinput")
        convolution2dLayer([5 5],3,"Name","conv","Padding","same")
        reluLayer("Name","relu")
        crossChannelNormalizationLayer(5,"Name","crossnorm")
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