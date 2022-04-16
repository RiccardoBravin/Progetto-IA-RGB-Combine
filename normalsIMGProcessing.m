%###names of input and output folders###
%input folder in the format:
%Dataset |-> NCSU-CUB_Foram_Images_G-bulloides
%        |->   .
%        |->   .
%        |->   .
%        |-> NCSU-CUB_Foram_Images_Others    

clear

path = {'G. Bulloides','G. Ruber','G. Sacculifer','N. Dutertrei','N. Incompta','N. Pachyderma','Others'};
outF = 'normIMG';

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
        px = zeros(imgR,imgC,1);
        %this loop goes through 16 images at a time and stores the value of
        %each pixel in a 3D matrix 
        
        for J = 1 : 16
            img = double(readimage(imB,I));
            
            px = img;
            I = I + 1;
        end
        
        [X,Y] = meshgrid(1:imgC,1:imgR);
       

        [nx,ny,nz] = surfnorm(X,Y,px);
        b = reshape([nx ny nz], size(nx,1), size(nx,2),3);
        b = ((b+1)./2).*255;
        %imshow(uint8(b));
        
        %every matrix obtained this way is used as a channel in the RGB image
        %and is than saved in the new folder
        imgO = uint8(b);
        nome = strcat(outF,'/',path{K},'/',char(imB.Labels(I-1)),'.png');
        imwrite(imgO,nome);
        
        montage({imgO,readimage(imB,I-1)})

        pause(2);
        %montage({img90,img50,img10,imgO})

    end
end    