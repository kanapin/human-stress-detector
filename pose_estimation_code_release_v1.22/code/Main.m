function [ output_args ] = Main(  )
    pathToVideo = '/Users/nurlan/Dropbox/path-detector-media/working_set/nairobi_128_132.avi';
    outputVideoPath = '/Users/nurlan/Dropbox/path-detector-media/processed/nairobi_128_132.avi';
    pathToOutputCSV = '/Users/nurlan/Dropbox/path-detector-media/important_data/nairobi_128_132.csv';
    %pathToVideo = '/home/nurlan/Dropbox/dataset/3_sec.avi';
    %outputVideoPath = '/home/nurlan/Dropbox/dataset/3_all_proc.avi';

    videoReader = VideoReader(pathToVideo);
    %mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),'colormap',[]);
    numberOfFrames = videoReader.NumberOfFrames;

    peopleDetector = vision.PeopleDetector();

    addpath(genpath(pwd()));
    load('env.mat');

    writerObj = VideoWriter(outputVideoPath);
    writerObj.FrameRate = 10;
    open(writerObj);

    csvFile = fopen(pathToOutputCSV, 'wt');
    formatString = repmat('%f,', 1, 4);
    formatString = [formatString(1:end-1), '\n'];

    detector = vision.ForegroundDetector(...
       'NumTrainingFrames', 5, ...
       'InitialVariance', 30*30);
   
    yellow = uint8([255 255 0]);
    blob = vision.BlobAnalysis(...
       'CentroidOutputPort', false, 'AreaOutputPort', false, ...
       'BoundingBoxOutputPort', true, ...
       'MinimumBlobAreaSource', 'Property', 'MinimumBlobArea', 75);
    shapeInserter = vision.ShapeInserter('BorderColor','White');
    
    for k = 1 : numberOfFrames
        frame = read(videoReader, k);
        fgMask = step(detector, frame);
        fgMask8 = uint8(fgMask) * 255;
        
        
        bbox_blob = step(blob, fgMask);
        display(bbox_blob);
        fgMask8 = step(shapeInserter, fgMask8, bbox_blob);
        imshow(fgMask8);
        w = waitforbuttonpress;
        [bboxes,scores] = step(peopleDetector, frame);
        
        processedFrame = false;
        %frame = insertObjectAnnotation(frame,'rectangle',bboxes,scores);
        %imshow(frame);
        
        if numel(bboxes) > 0 %&& k < 3%mod(k,1000) == 1
            display(k);
            x = bboxes(1);
            y = bboxes(2);
            w = bboxes(3);
            h = bboxes(4);
            x = x + int32(w*0.25);
            w = int32(w*0.50);
            y = y + int32(h*0.1);
            h = int32(h*0.3);
            bboxes = double([x y w h]);
            W = waitforbuttonpress;
            display(bboxes);
            imwrite(frame, sprintf([pwd '/example_data/images/%02d.png'], k)); 
            pause(1);
            [T sticks_imgcoor] = PoseEstimStillImage(pwd, 'example_data/images', '%02d.png', k, 'full', bboxes', fghigh_params, parse_params_Buffy3and4andPascal, [], pm2segms_params, true);
            for i1 = 1 : 10
                fprintf(csvFile, formatString, sticks_imgcoor(:, i1));
            end
            processedFrame = imread(sprintf([pwd '/segms_full/%02d.png'], k));
            delete(sprintf([pwd '/example_data/images/%02d.png'], k));
            delete(sprintf([pwd '/poses_full/%02d.png'], k));
            delete(sprintf([pwd '/segms_full/%02d.png'], k));
            delete(sprintf([pwd '/fghigh_full/%02d.png'], k));
            %frame = insertObjectAnnotation(frame,'rectangle',bboxes,scores);
        end
        if ~islogical(processedFrame)
            imshow(processedFrame);
            writeVideo(writerObj, processedFrame);
        else
            imshow(frame);
            writeVideo(writerObj, frame);
        end


        %w = waitforbuttonpress;
    end
    %release(videoReader);
    fclose(csvFile);
    close(writerObj);
    output_args = 0;
end

