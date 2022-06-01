clear all
warning off


%% Data gathering

%path in cui è contenuto il dataset
pathP = 'Processing/hsvIMG';%here you have to save the 3-channels images, not the original images

%dimensione dell'immagine 
im_sz=[227 227];

%ImageDatastore delle immagini del dataset
imP = imageDatastore(pathP, ...
                     'IncludeSubfolders', true, ...
                     'LabelSource','foldername');

%Numero di classi nel dataset
numClasses = numel(categories(imP.Labels));
%Creazione dell'augmented imageDatstore per il resize delle immagini
imP = augmentedImageDatastore(im_sz,imP);

%Lettura di immagini e labels dal dataset
all_imgs = readall(imP);
%suddivisione dei dati letti in label numeriche e immagini
all_lbls = categorical(grp2idx(table2array(all_imgs(:,2))));
all_imgs = table2array(all_imgs(:,1));

%suddivisione in folder 
k_fold = cvpartition(all_lbls, 'kfold',4);

%% Tuning network
%import della rete preallenata
net = alexnet;

%definizione delle opzioni di allenamento
metodoOptim='adam';
learningRate = 4e-5;
batch_size = 30;
options = trainingOptions(metodoOptim,...
    'MiniBatchSize',batch_size,...
    'MaxEpochs',10,...
    'InitialLearnRate',learningRate,...
    'ExecutionEnvironment','gpu',...
    'Verbose',false,...
    'Plots','training-progress');

%modificazione della rete per accomodare il numero di classi richiesto in
%output
layersTransfer = net.Layers(1:end-3);
layers = [
        layersTransfer
        fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
        softmaxLayer
        classificationLayer];

%% k-fold training

%cicla per ogni fold
for i = 1:4
    
    %maschere per il training e test set
    train_mask = training(k_fold, i);
    test_mask = test(k_fold,i);
    
    %Selezione del fold di immagini per test e train
    I_train = all_imgs(train_mask);
    I_test = all_imgs(test_mask);
    
    %Conversione delle immagini in tensori 4D
    I_train = cat(4,I_train{:});
    I_test = cat(4,I_test{:});
    
    %Slezione del fold di labels corrispondenti alle immagini
    L_train = all_lbls(train_mask);
    L_test = all_lbls(test_mask);

    %Allenamento del network
    netTransfer = trainNetwork(I_train,L_train,layers,options);
    
    %Test di accuracy
    [YPred,scores] = classify(netTransfer,I_test);
    
    %struttura per salvare risultati
    results{i,1} = mean(YPred == L_test)
    results{i,2} = scores;
    results{i,3} = test_mask;
    
end

%Salvataggio dei risultati
save(strcat(extractAfter(pathP,'/'),"_results.mat"),"results");