clear
reshsv = load("hsv2IMG_results.mat").results;
respca = load("PCAIMG_results.mat").results;


pathP = 'Processing/hsv2IMG';%here you have to save the 3-channels images, not the original images

imP = imageDatastore(pathP, ...
                     'IncludeSubfolders', true, ...
                     'LabelSource','foldername');

all_lbls = categorical(grp2idx((imP.Labels)));

clearvars imP

FOLD = 4;

ind = find(reshsv{FOLD,3} .* respca{FOLD,3});
lbls = all_lbls(ind);


one = find(reshsv{FOLD,3});
two = find(respca{FOLD,3});

j = 1;
for i = 1:size(one,1)
    
    if one(i) == ind(j)
        indhsv(j,:) = i;
        j = j+1;
    end
    if(j > size(ind,1))
            break
    end
end

j = 1;
for i = 1:size(two,1)
    if two(i) == ind(j)
        indpca(j,:) = i;
        j = j+1;
    end
    if(j > size(ind,1))
            break
    end
end

[v1,v2] = max(reshsv{FOLD,2}(indhsv,:) + respca{FOLD,2}(indpca,:),[],2);


accuracy = mean(lbls == categorical(v2))




