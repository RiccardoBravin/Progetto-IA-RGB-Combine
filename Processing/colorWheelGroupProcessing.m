clear

groupingBy = 1;
pw = 2;

path = {'G_Bulloides','G_Ruber','G_Sacculifer','N_Dutertrei','N_Incompta','N_Pachyderma','Others'};
outF = strcat('GroupBy', string(groupingBy));
outFPP = strcat(outF, "PostProcessed");

mkdir(outF);
mkdir(outFPP);

for K = 1 : length(path)

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

        RGB = zeros(imgR,imgC,3);

        for d = 1:16
            for ch = 1:3
                for gc = 1:groupingBy
                    disp((ch-1)*groupingBy+gc);
                    if ((ch-1)*groupingBy+gc) <=16
                        RGB(:,:,ch) = RGB(:,:,ch) + px(:,:,(ch-1)*groupingBy+gc).^pw;
                    end
                end
            end
        end
        
        d = 1
        while d <= 16
            for i = 1:groupingBy
                RGB(:,:,1)
            end

        end


        RGB = uint8(rescale(RGB, 0, 255));
        

        RGB2 = RGB;
        RGB2 = imlocalbrighten(RGB2, 0.5, 'AlphaBlend',true);
        RGB2 = imreducehaze(RGB2,0.9,'method','approxdcp');
        
        
%         nome = strcat(outF,'/',path{K},'/',char(imB.Labels(I-1)),'.png');
%         imwrite(RGB,nome);
% 
%         nome = strcat(outFPP,'/',path{K},'/',char(imB.Labels(I-1)),'.png');
%         imwrite(RGB2,nome);

        montage({RGB,RGB(:,:,1),RGB(:,:,2),RGB(:,:,3)}); pause(1);
        montage({RGB2,RGB2(:,:,1),RGB2(:,:,2),RGB2(:,:,3)}); pause(1);


    end
end