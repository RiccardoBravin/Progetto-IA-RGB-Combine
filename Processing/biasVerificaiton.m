clear
clc

path = GetSubDirs('Dataset');
outF = strcat('Bias');

mkdir(outF);

for C = 1 : length(path)
    patterns  = GetSubDirs(strcat('Dataset/', string(path{C})));
    mkdir(outF, path{C});

    for P = 1 : length(patterns)
        pics = dir(strcat('Dataset\', string(path{C}),'\', string(patterns{P}), '\*.png'));
        origin = strcat('Dataset\', string(path{C}),'\', string(patterns{P}), '\', string(pics(1).name));
        dest = strcat(outF, '\', string(path{C}));
        copyfile(origin, dest)
        movefile(strcat(dest, '\', string(pics(1).name)), strcat(dest, '\', string(P), '.png'));
    end
end

function [subDirsNames] = GetSubDirs(parentDir)
    % Get a list of all files and folders in this folder.
    files = dir(parentDir);
    % Get a logical vector that tells which is a directory.
    dirFlags = [files.isdir];
    % Extract only those that are directories.
    subDirs = files(dirFlags);
    subDirsNames = cell(1, numel(subDirs) - 2);
    for i=3:numel(subDirs)
        subDirsNames{i-2} = subDirs(i).name;
    end
end