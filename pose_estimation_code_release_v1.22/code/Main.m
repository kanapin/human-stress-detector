function [ output_args ] = Main( videoFileName )

% Permissions & paths
addpath(genpath(pwd()));
load('env.mat');
pause on;

% Some constants
%pathToMediaFolder = '/Users/nurlan/Dropbox/path-detector-media/'; % OS X
pathToMediaFolder = '/home/nurlan/Dropbox/path-detector-media/'; % Linux


% Setting paths to the input, output video and output csv file.
fullPath = [pathToMediaFolder 'working_set/' videoFileName];
outputVideoPath = [pathToMediaFolder 'processed/' videoFileName];
pathToOutputCSV = [pathToMediaFolder 'important_data/' videoFileName '.csv'];

% Creating video reader
videoReader = VideoReader(fullPath);
numberOfFrames = videoReader.NumberOfFrames;
height = videoReader.Height
width = videoReader.Width

% Creating video writer
writerObj = VideoWriter(outputVideoPath);
writerObj.FrameRate = 10;
open(writerObj);

% Creating CSV file
csvFile = fopen(pathToOutputCSV, 'wt');
formatString = repmat('%f,', 1, 4);
formatString = [formatString(1:end-1), '\n'];

% Vision tools
peopleDetector = vision.PeopleDetector();

foregroundDetector = vision.ForegroundDetector(...
    'NumTrainingFrames', 3, ...
    'InitialVariance', 30*30);

blob = vision.BlobAnalysis(...
    'CentroidOutputPort', false, 'AreaOutputPort', false, ...
    'BoundingBoxOutputPort', true, ...
    'MinimumBlobAreaSource', 'Property', 'MinimumBlobArea', 50);
se = strel('square', 6); % for dilating
shapeInserter = vision.ShapeInserter('BorderColor','White');
debug = false;
debugLevel2 = false;

for k = 1 : numberOfFrames
    % Pre
    writtenCSVData = false;
    
    % Read the next frame
    frame = read(videoReader, k);
    imshow(frame);
    if debug
        w = waitforbuttonpress;
    end
    
    
    % Foreground detection
    fgMask = step(foregroundDetector, frame);
    fgMask = imdilate(fgMask, se);
    
    fgMask8 = uint8(fgMask) * 255;
    bbox_blob = step(blob, fgMask);
    display(bbox_blob);
    %fgMask8 = step(shapeInserter, fgMask8, bbox_blob);
    imshow(fgMask8);
    if debug
        w = waitforbuttonpress;
    end
    
    [rows, ~] = size(bbox_blob);
    if (rows > 0)
        % Choosing the one rectangle, covering all blobs
        x1 = 10000; y1 = 10000; y2 = 0; x2 = 0;
        for i = 1:rows
            rect = bbox_blob(i, :);
            x1 = min(rect(1), x1);
            y1 = min(rect(2), y1);
            x2 = max(rect(1) + rect(3), x2);
            y2 = max(rect(2) + rect(4), y2);
        end
        x1 = max(1, x1 - width/4);
        y1 = max(1, y1 - height/4);
        x2 = min(x2 + width/4, width);
        y2 = min(y2 + height/4, height);
        roi = [x1 y1 x2 y2];
        display(roi);
        if debug
            w = waitforbuttonpress;
        end
        
        % People detection
        roiImage = frame(y1:y2, x1:x2);
        imshow(roiImage);
        if debug
            w = waitforbuttonpress;
        end
        
        [peopleBoxes, scores] = step(peopleDetector, roiImage);
        display(peopleBoxes);
        [num, ~] = size(peopleBoxes)
        if debugLevel2
            w = waitforbuttonpress;
        end
        for i = 1 : num
            display(peopleBoxes(i, :));
            peopleBoxes(i, :) = peopleBoxes(i, :) + double([x1 y1 0 0]);
        end
        display(peopleBoxes);
        out = insertObjectAnnotation(frame,'rectangle', peopleBoxes ,scores);
        imshow(out);
        
        if debugLevel2
            w = waitforbuttonpress;
        end
        
        
        processedFrame = false;
        
        [instances, ~] = size(peopleBoxes);
        %if numel(peopleBoxes) > 0 %&& k < 3%mod(k,1000) == 1
        if instances == 1 
            display(k);
            x = peopleBoxes(1);
            y = peopleBoxes(2);
            w = peopleBoxes(3);
            h = peopleBoxes(4);
            x = x + int32(w*0.27); % .27
            w = int32(w*0.45);     % .45
            y = y + int32(h*0.10); % .10
            h = int32(h*0.23);     % .23
            peopleBoxes = double([x y w h]);
            out = insertObjectAnnotation(frame,'rectangle', peopleBoxes, scores);
            display(peopleBoxes);
            imshow(out);
            if debugLevel2
                W = waitforbuttonpress;
            end
            
            
            imwrite(frame, sprintf([pwd '/example_data/images/%02d.png'], k));
            mode = 'full';
            pause(1);
            [T sticks_imgcoor] = PoseEstimStillImage(pwd, 'example_data/images', ...
                '%02d.png', k, mode, peopleBoxes', fghigh_params, ...
                parse_params_Buffy3and4andPascal, [], pm2segms_params, true);
            [numberOfSticks, ~] = size(sticks_imgcoor);
            for i1 = 1 : numberOfSticks
                fprintf(csvFile, formatString, sticks_imgcoor(:, i1));
            end
            writtenCSVData = true;
            
            processedFrame = imread(sprintf([pwd '/segms_' mode '/%02d.png'], k));
            delete(sprintf([pwd '/example_data/images/%02d.png'], k));
            delete(sprintf([pwd '/poses_' mode '/%02d.png'], k));
            delete(sprintf([pwd '/segms_' mode '/%02d.png'], k));
            delete(sprintf([pwd '/fghigh_' mode '/%02d.png'], k));
            %frame = insertObjectAnnotation(frame,'rectangle',bboxes,scores);
        
        end
    
        if ~islogical(processedFrame)
            imshow(processedFrame);
            writeVideo(writerObj, processedFrame);
            pause(3);
        else
            imshow(frame);
            writeVideo(writerObj, frame);
        end
           
    end % numel(bbox_blob) > 1
    if ~writtenCSVData
        for i1 = 1 : 10
            fprintf(csvFile, formatString, [-1.0, -1.0, -1.0, -1.0]);
        end
    end
    %w = waitforbuttonpress;
end
%release(videoReader);
fclose(csvFile);
close(writerObj);
output_args = 0;
end

