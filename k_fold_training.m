clear all
warning off


%% Data gathering

pathP = 'Processing/hsv3IMG';%here you have to save the 3-channels images, not the original images
im_sz=[227 227];

imP = imageDatastore(pathP, ...
                     'IncludeSubfolders', true, ...
                     'LabelSource','foldername');

numClasses = numel(categories(imP.Labels)); %number of classes in the training set

imP = augmentedImageDatastore(im_sz,imP);

all_imgs = readall(imP);
all_lbls = categorical(grp2idx(table2array(all_imgs(:,2))));
all_imgs = table2array(all_imgs(:,1));
k_fold = cvpartition(all_lbls, 'kfold',4);



clearvars imP

%% Tuning network

net = alexnet;

metodoOptim='adam';
learningRate = 1e-5;
batch_size = 30;

options = trainingOptions(metodoOptim,...
    'MiniBatchSize',batch_size,...
    'MaxEpochs',20,...
    'InitialLearnRate',learningRate,...
    'ExecutionEnvironment','gpu',...
    'Verbose',false,...
    'Plots','training-progress');


layersTransfer = net.Layers(1:end-3);
layers = [
        layersTransfer
        fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
        softmaxLayer
        classificationLayer];

%% k-fold training

for i = 1:4
    
    %get the fold training and test selection masks
    train_mask = training(k_fold, i);
    test_mask = test(k_fold,i);
    
    %select fold of images
    I_train = all_imgs(train_mask);
    I_test = all_imgs(test_mask);
    
    %convert images to 4d matrix 
    I_train = cat(4,I_train{:});
    I_test = cat(4,I_test{:});
    
    %select relative labels
    L_train = all_lbls(train_mask);
    L_test = all_lbls(test_mask);

    %train network
    netTransfer = trainNetwork(I_train,L_train,layers,options);
    
    %test accuracy
    [YPred,scores] = classify(netTransfer,I_test);
    
    results{i,1} = mean(YPred == L_test)
    results{i,2} = scores;
    results{i,3} = test_mask;
    
end

save(strcat(extractAfter(pathP,'/'),"_results.mat"),"results");