function [ output_args ] = Main( pathToVideo, outputVideoPath, pathToOutputCSV )
    %pathToVideo = '/home/nurlan/Dropbox/dataset/3_sec.avi';
    %outputVideoPath = '/home/nurlan/Dropbox/dataset/3_all_proc.avi';

    videoReader = VideoReader(pathToVideo);
    %mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),'colormap',[]);
    numberOfFrames = videoReader.NumberOfFrames;

    peopleDetector = vision.PeopleDetector('UprightPeople_96x48');

    addpath(genpath(pwd()));
    load('env.mat');

    writerObj = VideoWriter(outputVideoPath);
    writerObj.FrameRate = 10;
    open(writerObj);

    csvFile = fopen(pathToOutputCSV, 'wt');
    formatString = repmat('%f,', 1, 4);
    formatString = [formatString(1:end-1), '\n'];

    for k = 1 : numberOfFrames
        frame = read(videoReader, k);
        [bboxes,scores] = step(peopleDetector, frame);
        processedFrame = false;
        frame = insertObjectAnnotation(frame,'rectangle',bboxes,scores);
        imshow(frame);
        W = waitforbuttonpress;
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

