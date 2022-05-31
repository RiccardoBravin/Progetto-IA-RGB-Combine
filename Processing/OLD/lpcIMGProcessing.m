%###names of input and output folders###
%input folder in the format:
%Dataset |-> NCSU-CUB_Foram_Images_G-bulloides
%        |->   .
%        |->   .
%        |->   .
%        |-> NCSU-CUB_Foram_Images_Others    
clear;
path = {'G_Sacculifer','N_Dutertrei','N_Incompta','N_Pachyderma','Others'};
outF = 'ipcIMG';

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
        
        for J = randperm(16)
            img = (readimage(imB,I));

            %imshow(img);
            px(:,:,J) = img;
            I = I + 1;
        end
        px = decorrstretch(px);
        imshow(px(:,:,1:3));
        imgO=zeros([size(px,1),size(px,2),3]);

        %this loop processes 10th, 50th and 90th percentile of each group
        %of 16 pixel gathered in the previous step
        for R = 1 : imgR
            for C = 1 : imgC
                pix = px(R,C,:);
                pix = reshape(pix,[16,1])';
                %pix = reshape(pix,16);
                x = lpc(pix,3);

                imgO(R,C,:) = (x(2:end));
            end
        end
        
        %since we still have greyscale images we need to use uint8 format
        %for pixels values

        imgO = rescale(imgO);
        imgO = imreducehaze(imgO);
        montage({imgO(:,:,1),imgO(:,:,2),imgO(:,:,3),imgO})
        
        
        %every matrix obtained this way is used as a channel in the RGB image
        %and is than saved in the new folder
        nome = strcat(outF,'/',path{K},'/',char(imB.Labels(I-1)),'.png');
        imwrite(imgO,nome);
    end
end    