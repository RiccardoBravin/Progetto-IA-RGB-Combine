clear

augNum = 4;
groupingBy = 1;
pw = 2;

path = {'G_Bulloides','G_Ruber','G_Sacculifer','N_Dutertrei','N_Incompta','N_Pachyderma','Others'};
outF = strcat('GroupBy', string(groupingBy), '_x', string(augNum));
outFPP = strcat(outF, "PostProcessed", '_x', string(augNum));

mkdir(outF);
mkdir(outFPP);

parfor K = 1 : length(path)

    imB = imageDatastore(strcat('Dataset/',path{K}), ...
        'IncludeSubfolders', true, ...
        'LabelSource','foldernames');

    mkdir(outF,path{K});
    mkdir(outFPP,path{K});

    I = 1;
    while I < length(imB.Labels)

        [imgR, imgC] = size(readimage(imB,I));
        px = zeros(imgR,imgC,16);

        O = [1 10 11 12 13 14 15 16 2 3 4 5 6 7 8 9];
        O = mod(O + randi(15),16) + 1;

        for J = 1 : 16
            img = readimage(imB,I);
            px(:,:,O(J)) = img;
            I = I + 1;
        end
        
        for NO = 1 : augNum
            RGB = zeros(imgR,imgC,3);
    
            d = 1;
            while d <= 16
                for chan = 1:3
                    for i = 1:groupingBy
                        if(d <= 16)
                            RGB(:,:,chan) = RGB(:,:,chan) + px(:,:,d).^pw;
                            d = d + 1;
                        end
                    end
                end
            end
    
    
            RGB = uint8(rescale(RGB, 0, 255));
            
    
            RGB2 = RGB;
            RGB2 = imlocalbrighten(RGB2, 0.5, 'AlphaBlend',true);
            RGB2 = imreducehaze(RGB2,0.9,'method','approxdcp');
            
            
            nome = strcat(outF,'/',path{K},'/',char(imB.Labels(I-1)),'_', string(NO), '.png');
            imwrite(RGB,nome);
    
            nome = strcat(outFPP,'/',path{K},'/',char(imB.Labels(I-1)),'_', string(NO),'.png');
            imwrite(RGB2,nome);
    %         montage({RGB,RGB(:,:,1),RGB(:,:,2),RGB(:,:,3)}); pause(1);
    %         montage({RGB2,RGB2(:,:,1),RGB2(:,:,2),RGB2(:,:,3)}); pause(1);
            px = circshift(px, randi(15), 3);
        end


    end
end