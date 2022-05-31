%###names of input and output folders###
%input folder in the format:
%Dataset |-> NCSU-CUB_Foram_Images_G-bulloides
%        |->   .
%        |->   .
%        |->   .
%        |-> NCSU-CUB_Foram_Images_Others

clear

path = {'G_Bulloides','G_Ruber','G_Sacculifer','N_Dutertrei','N_Incompta','N_Pachyderma','Others'};
outF = 'hsv3IMG';

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
        hsv = zeros(imgR,imgC,3);
        imgO = zeros(imgR,imgC,3);

        %this loop goes through 16 images at a time and stores the value of
        %each pixel in a 3D matrix

        O = [1 10 11 12 13 14 15 16 2 3 4 5 6 7 8 9];
        O = mod(O + randi(15),16) + 1;
        
        for J = 1:16
            
            img = im2double(readimage(imB,I));
            % imshow(img);pause(0.3);
            
            hsv(:,:,1) = (16/255*(O(J)-1));
            hsv(:,:,2) = ones(imgR,imgC);
            hsv(:,:,3) = img;
            
            
            imgO = imgO + hsv2rgb(hsv).^2;
            I = I + 1;
        end
        
        imgO = rescale(imgO);
        imgO = imlocalbrighten(imgO,0.2);
        %imgO = imadjust(imgO, stretchlim(imgO),[]);
        imgO = imreducehaze(imgO,0.3);
        %imgO = imsharpen(imgO);
        

        %every matrix obtained this way is used as a channel in the RGB image
        %and is than saved in the new folder

        nome = strcat(outF,'/',path{K},'/',char(imB.Labels(I-1)),'.png');
        imwrite(imgO,nome);
        
        
        %imshow(imgO); pause(1);
        %montage({imgO,imgO(:,:,1),imgO(:,:,2),imgO(:,:,3)})
        
%         for i = 1:16
%             montage({tosee(:,:,i), imgO} ); pause(0.1);
%         end
        %disp(imB.Files(I-16));
    end
end