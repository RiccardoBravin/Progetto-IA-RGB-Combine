%###names of input and output folders###
%input folder in the format:
%Dataset |-> NCSU-CUB_Foram_Images_G-bulloides
%        |->   .
%        |->   .
%        |->   .
%        |-> NCSU-CUB_Foram_Images_Others    

clear

path = {'G. Bulloides','G. Ruber','G. Sacculifer','N. Dutertrei','N. Incompta','N. Pachyderma','Others'};
outF = 'percentileIMG';

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
        ft = zeros(imgR,imgC,16);
        %this loop goes through 16 images at a time and stores the value of
        %each pixel in a 3D matrix 
        
        for J = 1 : 16
            img = readimage(imB,I);
            ft(:,:,J) = (img);
            mont{J} = rescale(log1p(ft(:,:,J)));
            
            I = I + 1;
        end
        montage(mont1)
        pause(1);
        montage(mont2)
        pause(1);

        img90 = zeros(imgR,imgC);
        img50 = zeros(imgR,imgC);
        img10 = zeros(imgR,imgC);
        
        %this loop processes 10th, 50th and 90th percentile of each group
        %of 16 pixel gathered in the previous step
        for R = 1 : imgR
            for C = 1 : imgC
                pix = ft(R,C,:);
                sort(pix); %prctile() is too slow, the nearest rank method gives us much better performance
                img90(R,C) = pix(15);
                img50(R,C) = pix(8);
                img10(R,C) = pix(2);
            end
        end


        %since we still have greyscale images we need to use uint8 format
        %for pixels values
        img90 = uint8(ifft2(img90));
        img50 = uint8(ifft2(img50));
        img10 = uint8(ifft2(img10));
        
        %every matrix obtained this way is used as a channel in the RGB image
        %and is than saved in the new folder
        imgO = cat(3,img10,img50,img90);
        nome = strcat(outF,'/',path{K},'/',char(imB.Labels(I-1)),'.png');
        imwrite(imgO,nome);

        
        %montage({img90,img50,img10,imgO})

    end
end    