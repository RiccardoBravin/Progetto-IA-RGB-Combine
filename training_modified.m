clear all
warning off


%###########network and data initialization###############
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
im_sz=[227 227];
numClasses = max(DATA{2}); %number of classes in the training set

[trainInd,testInd] = dividerand(size(DATA{1},4),0.83,0.17,0);

all_lbls = categorical(DATA{2});
all_imgs = DATA{1};
k_fold = cvpartition(all_lbls, 'kfold',4);

%% Tuning network

net = alexnet;  %load AlexNet

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


layersTransfer = net.Layers(2:end-3);

% for i = 1:size(layersTransfer,1)
%     try
%     layersTransfer(i).WeightLearnRateFactor = .1;
%     catch
%     end
% end

layers = [
        imageInputLayer([227 227 16],"Name","imageinput")
        convolution2dLayer([7 7],3,"Name","inconv1","Padding","same")
        layersTransfer
        fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
        softmaxLayer
        classificationLayer
];



%% k-fold training

for i = 1:4
    
    %get the fold training and test selection masks
    train_mask = training(k_fold, i);
    test_mask = test(k_fold,i);
    
    %select fold of images
    I_train = all_imgs(:,:,:,train_mask);
    I_test = all_imgs(:,:,:,test_mask);
    
    %select relative labels
    L_train = all_lbls(train_mask);
    L_test = all_lbls(test_mask);

    %train network
    netTransfer = trainNetwork(I_train,L_train,layers,options);
    
    %test accuracy
    [YPred,scores] = classify(netTransfer,I_test);
    
    results{i,1} = mean(YPred == L_test');
    results{i,2} = scores;
    results{i,3} = test_mask;
    disp(results);
    
end

save(strcat("conv","_results.mat"),"results");


% %% Visualize convolution
% 
% img = train_I(:,:,:,1);
% O = activations(netTransfer,img,'inconv2');
% O = rescale(O);
% %imagesc(O);
% montage({O(:,:,1),O(:,:,2),O(:,:,3),O})
