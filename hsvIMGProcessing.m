%###names of input and output folders###
%input folder in the format:
%Dataset |-> NCSU-CUB_Foram_Images_G-bulloides
%        |->   .
%        |->   .
%        |->   .
%        |-> NCSU-CUB_Foram_Images_Others

clear

path = {'G. Bulloides','G. Ruber','G. Sacculifer','N. Dutertrei','N. Incompta','N. Pachyderma','Others'};
outF = 'hsvIMG';

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
        hsv = zeros(imgR,imgC,3,16);
        %this loop goes through 16 images at a time and stores the value of
        %each pixel in a 3D matrix

        for J = 1 : 16
            img = im2double((readimage(imB,I)));
            hsv(:,:,:,J) = (cat(3,zeros(imgR,imgC),ones(imgR,imgC),img));
            hsv(:,:,1,J) = hsv(:,:,1,J) + (16/255*(J-1));
            I = I + 1;
        end


        imgO = zeros(imgR,imgC,3);

        %this loop processes 10th, 50th and 90th percentile of each group
        %of 16 pixel gathered in the previous step
        for J = 1 : 16
            imgO = imgO + hsv2rgb(hsv(:,:,:,J));
        end
            
        imgO = imgO./16;
        %imgO = imadjust(imgO,stretchlim(imgO),[]);
        imgO = imsharpen(imgO);

        %every matrix obtained this way is used as a channel in the RGB image
        %and is than saved in the new folder
        
        nome = strcat(outF,'/',path{K},'/',char(imB.Labels(I-1)),'.png');
        imwrite(imgO,nome);
        imshow(imgO);

        
%         for J = 1 : 16
%             img = ((readimage(imB,I-J)));
%             montage({imgO,img})
%         end
        %pause(2);

    end
end