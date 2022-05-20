%###names of input and output folders###
%input folder in the format:
%Dataset |-> NCSU-CUB_Foram_Images_G-bulloides
%        |->   .
%        |->   .
%        |->   .
%        |-> NCSU-CUB_Foram_Images_Others

clear

path = {'G_Bulloides','G_Ruber','G_Sacculifer','N_Dutertrei','N_Incompta','N_Pachyderma','Others'};
%path = {'G_Bulloides'};
outF = 'yuvIMG';

%create output folder
mkdir(outF);
%start of main loop, goes through all folders of the dataset

parfor K = 1 : length(path)

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
        yuv = zeros(imgR,imgC,3);
        %this loop goes through 16 images at a time and stores the value of
        %each pixel in a 3D matrix

        for J = [1,10,11,12,13,14,15,16]
            
            img = im2double(imsharpen(readimage(imB,I)));
            %imshow(img);
            yuv(:,:,1) = yuv(:,:,1) + img;
            yuv(:,:,2) = yuv(:,:,2) + img.^2;
            I = I + 1;
        end

        for J = [2,3,4,5,6,7,8,9]
            img = im2double(imsharpen(readimage(imB,I)));
            %imshow(img);
            yuv(:,:,1) = yuv(:,:,1) + img;
            yuv(:,:,3) = yuv(:,:,3) + img.^2;
            I = I + 1;
        end

        
        yuv(:,:,1) = (yuv(:,:,1)/12);
        yuv(:,:,2) = rescale(sqrt(yuv(:,:,2)),-0.4, 0.2);
        yuv(:,:,3) = rescale(sqrt(yuv(:,:,3)),-0.2, 0.4);
        

        %this loop processes 10th, 50th and 90th percentile of each group
        %of 16 pixel gathered in the previous step
        

        
        imgO = yuv2rgb(yuv);
        imgO = imreducehaze(imgO);
        %imgO = decorrstretch(imgO); %?? migliora oppure no?
        imgO = imsharpen(imgO);
        imgO = localcontrast(uint8(imgO*255));
       
        
        %every matrix obtained this way is used as a channel in the RGB image
        %and is than saved in the new folder
        
        %montage({imgO,imgO(:,:,1),imgO(:,:,2),imgO(:,:,3)});pause(0.5);
        nome = strcat(outF,'/',path{K},'/',char(imB.Labels(I-1)),'.png');
        imwrite(imgO,nome);
        %imshow(imgO); pause(1);


%         for J = [16 7 6 5 4 3 2 1 15 14 13 12 11 10 9 8]
%             img = ((readimage(imB,I-J)));
%             montage({imgO,img,imgO(:,:,1),imgO(:,:,2),imgO(:,:,3)})
%         end
%         pause(2);
        %montage({imgO,img,imgO(:,:,1),imgO(:,:,2),imgO(:,:,3)});pause(1);

        %disp(imB.Files(I-16));
    end
end