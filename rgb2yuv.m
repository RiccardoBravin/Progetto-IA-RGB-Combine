function outImg = rgb2yuv(img)
%UNTITLED2 Summary of this function goes here
%   
% Detailed explanation goes here
    img = im2double(img);
    mat = [0.299 0.587 0.114; -0.14713 -0.28886 0.436; 0.615 -0.51499 -0.10001];
        

    for i = 1:size(img,1)
        for j = 1:size(img,2)
            aux = reshape(img(i,j,:),[3,1]);
            outImg(i,j,:) = mat * aux;

        end
    end

end