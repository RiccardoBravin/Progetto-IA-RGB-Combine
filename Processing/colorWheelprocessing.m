%###names of input and output folders###
%input folder in the format:
%Dataset |-> NCSU-CUB_Foram_Images_G-bulloides
%        |->   .
%        |->   .
%        |->   .
%        |-> NCSU-CUB_Foram_Images_Others    
clear 
clc

path = {'G_Bulloides','G_Ruber','G_Sacculifer','N_Dutertrei','N_Incompta','N_Pachyderma','Others'};
outF = 'rgbrgb';

pw = 2;
%create output folder
mkdir(outF);
%start of main loop, goes through all folders of the dataset 

for K = 1 : length(path)

    %create datastore of the selected folder
    imB = imageDatastore(strcat('Dataset/',path{K}), ...
                         'IncludeSubfolders', true, ...
                         'LabelSource','foldernames');
    
    %create new folder in the selected output folde that has the same name of the input folder                  
    mkdir(outF,path{K}); 
    
    %go through each image in the dataStore
    I = 1;
    while I < length(imB.Labels)                

        [imgR, imgC] = size(readimage(imB,I));
        px = zeros(imgR,imgC,16);
        %this loop goes through 16 images at a time and stores the value of
        %each pixel in a 3D matrix 
        for J = 1 : 16
            img = readimage(imB,I);
            px(:,:,J) = img;
            
            I = I + 1;
        end

        RGB = zeros(imgR,imgC,3);
        
        for ch = 1:3
            d = ch;
            while(d <= 16)
                RGB(:,:,ch) = RGB(:,:,ch) + (px(:,:,d)).^pw;
                    
                d = d + 3;
            end
        end
        
        %since we still have greyscale images we need to use uint8 format
        %for pixels values

        RGB = uint8(rescale(RGB(:,:,:).^(1/pw), 0, 255));
        
        nome = strcat(outF,'/',path{K},'/',char(imB.Labels(I-1)),'.png');
        imwrite(RGB,nome);

        montage({RGB, RGB(:,:,1), RGB(:,:,2), RGB(:,:,3)})
        
%         for i = 1:16
%             montage({uint8(px(:,:,i)),RGB} );
%             pause(0.5/16);
%         end

    end

end    