clear

%Cartelle da cui leggere le diverse classi
path = {'G_Bulloides','G_Ruber','G_Sacculifer','N_Dutertrei','N_Incompta','N_Pachyderma','Others'};
%Creazione della cartella di output
outF = 'hsvIMG';
outFPP= 'hsvPPIMG';
mkdir(outF);
mkdir(outFPP);

%ciclo parallelizzato su ogni cartella di "path"
parfor K = 1 : length(path)

    %Creazione dell'imageDatastore per la data cartella di path
    imB = imageDatastore(strcat('Dataset/',path{K}), ...
        'IncludeSubfolders', true, ...
        'LabelSource','foldernames');
    %Genera una cartella nella path specificata con lo stesso nome di quella di input
    mkdir(outF,path{K});
    mkdir(outFPP,path{K});

    %Per ogni immagine nella cartella 
    I = 1;
    while I < length(imB.Labels)
        
        %Lettura della dimensione della immagine
        [imgR, imgC] = size(readimage(imB,I));
        %inizializzazione delle matrici a zero
        hsv = zeros(imgR,imgC,3);
        imgO = zeros(imgR,imgC,3);

        %Dichiarazione dell'ordine randomizzato di lettura delle immagini
        %per la rimozione del bias di inizio
        Ind = [1 10 11 12 13 14 15 16 2 3 4 5 6 7 8 9];
        Ind = mod(Ind + randi(15),16) + 1;
        
        for J = Ind
            %lettura dell'immagine corrente
            img = im2double(readimage(imB,I));
            
            %generazione dell'immagine in hsv
            hsv(:,:,1) = (16/255*(J-1)); %hue calcolata in funzione della numerazione dell'immagine
            hsv(:,:,2) = ones(imgR,imgC);   %saturation posta ad 1
            hsv(:,:,3) = img;               %value
            
            %somma del quadrato dell'immagine
            imgO = imgO + hsv2rgb(hsv).^2; 
            I = I + 1;
        end
        
        %Riscala tra 0 e 1 per avere il full range di colori
        imgO = rescale(imgO);
        nome = strcat(outF,'/',path{K},'/',char(imB.Labels(I-1)),'.png');
        imwrite(imgO,nome);
        

        %Post processing per aumentare la luminosità e accentuare i colori
        imgO = imlocalbrighten(imgO,0.2);
        imgO = imreducehaze(imgO,.5);
        
        %salvataggio dell'immagine ottenuta nella nuova path 
        nome = strcat(outFPP,'/',path{K},'/',char(imB.Labels(I-1)),'.png');
        imwrite(imgO,nome);


    end
end