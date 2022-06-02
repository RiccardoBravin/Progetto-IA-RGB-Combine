clear

%scelta del numero di immagini da raggruppare
groupingBy = 3;
%potenza a cui elevare per la somma di immagini
pw = 2;

%Cartelle da cui leggere le diverse classi
path = {'G_Bulloides','G_Ruber','G_Sacculifer','N_Dutertrei','N_Incompta','N_Pachyderma','Others'};

%scelta e generazione delle due cartelle in cui salvare le immagini con e
%senza post processing
outF = strcat('GroupBy', string(groupingBy));
outFPP = strcat(outF, "PP");
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
        px = zeros(imgR,imgC,16);
        RGB = zeros(imgR,imgC,3);

        %Dichiarazione dell'ordine randomizzato di lettura delle immagini
        %per la rimozione del bias di inizio
        Ind = [1 10 11 12 13 14 15 16 2 3 4 5 6 7 8 9];
        Ind = mod(Ind + randi(15),16) + 1;
        
        %Lettura delle immagini e salvataggio nella struttura px
        for J = Ind
            px(:,:,J) = readimage(imB,I);
            I = I + 1;
        end

        %Finchè non ho sommato tutte e 16 le immagini
        d = 1;
        while d <= 16
            %Per ogni canale dell'immagine finale
            for chan = 1:3
                %sommo al canale dell'immagine finale "groupingBy" immagini
                for i = 1:groupingBy
                    %se non ho già visitato tutte le immagini
                    if(d <= 16)
                        %sommo all'immagine finale l'immagine corrente
                        %elevata a pw
                        RGB(:,:,chan) = RGB(:,:,chan) + px(:,:,d).^pw;
                        d = d + 1;
                    end
                end
            end
        end

        %riscalo l'immagine nell'intervallo [0,1]
        RGB = rescale(RGB);

        %Post processing per aumentare la luminosità e accentuare i colori
        RGB2 = imlocalbrighten(RGB, 0.2, 'AlphaBlend',true);
        RGB2 = imreducehaze(RGB2,0.3,'method','approxdcp');

        %salvataggio dell'immagine senza post processing nella nuova path 
        nome = strcat(outF,'/',path{K},'/',char(imB.Labels(I-1)),'.png');
        imwrite(RGB,nome);
        %salvataggio dell'immagine con post processing nella nuova path 
        nome = strcat(outFPP,'/',path{K},'/',char(imB.Labels(I-1)),'.png');
        imwrite(RGB2,nome);

    end
end