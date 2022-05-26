function outImg = yuv2rgb(img)
%UNTITLED2 Summary of this function goes here
%   
% Detailed explanation goes here
    img = im2double(img);
    mat = [1 0 1.13983; 1 -0.39465 -0.5806; 1 2.03211 0];
        

    for i = 1:size(img,1)
        for j = 1:size(img,2)
            aux = reshape(img(i,j,:),[3,1]);
            outImg(i,j,:) = mat * aux;

        end
    end

end