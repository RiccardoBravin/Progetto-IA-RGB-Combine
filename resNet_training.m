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
        

        %imshow(BW); pause(1)


        for j = [1,10,11,12,13,14,15,16,2,3,4,5,6,7,8,9]
            
            %imshow(auxI)
                
            data_I(:,:,j,n) = imresize(auxI,img_sz);
            
            i = i + 1;
        end
        
        data_L(n) = K;
        n = n + 1;

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


miniBatchSize = 30;
learningRate = 1e-5;
metodoOptim='adam';
options = trainingOptions(metodoOptim,...
    'MiniBatchSize',miniBatchSize,...
    'MaxEpochs',30,...
    'InitialLearnRate',learningRate,...
    'ExecutionEnvironment','gpu',...
    'Verbose',false,...
    'Plots','training-progress',...
    'ValidationData',{test_I,test_L},...
    'OutputNetwork', 'best-validation-loss'...
    );



lgraph = layerGraph(resnet18); %Scelta del network da utilizzare
lgraph = removeLayers(lgraph, {'ClassificationLayer_predictions','prob','fc1000','data'});
newLayers = [
    fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',20,'BiasLearnRateFactor', 20)
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classoutput')];
lgraph = addLayers(lgraph,newLayers);
lgraph = connectLayers(lgraph,'pool5','fc');


newLayers = [
    imageInputLayer([227 227 16],"Name","Big2data")
    %convolution2dLayer([3 3],8,"Name","addConv1","Padding","same",'WeightsInitializer','he')
    %batchNormalizationLayer("Name","bn_conv1_2")
    convolution2dLayer([5 5],3,"Name","addConv2","Padding","same",'WeightsInitializer','he')
    reluLayer("Name","conv1_relu_2")
    ];
lgraph = addLayers(lgraph,newLayers);
lgraph = connectLayers(lgraph,'addConv2','conv1');

%############training############

netTransfer = trainNetwork(train_I, train_L, lgraph, options);

%############test#############

[YPred,scores] = classify(netTransfer,test_I);

%############data############
accuracy = sum(YPred' == test_L)/size(test_L,2);
disp(accuracy)
confusionchart(test_L,YPred)


%% Visualize first layer convolution

img = train_I(:,:,:,1);
O = activations(netTransfer,img,'addConv2');
O = rescale(O);
%imagesc(O);
montage({O(:,:,1),O(:,:,2),O(:,:,3),O})
