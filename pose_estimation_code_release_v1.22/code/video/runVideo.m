pathToVideo = '/home/nurlan/Dropbox/dataset/3_sec.avi';
outputPath = '/home/nurlan/Dropbox/dataset/3_sec_proc.avi';
videoReader = VideoReader(pathToVideo);
%mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),'colormap',[]);
numberOfFrames = videoReader.NumberOfFrames;

peopleDetector = vision.PeopleDetector;


writerObj = VideoWriter(outputPath);
writerObj.FrameRate = 10;
open(writerObj);


for k = 1 : numberOfFrames
    frame = read(videoReader, k);
    [bboxes,scores] = step(peopleDetector, frame);
    processedFrame = false;
    if numel(bboxes) > 0 && mod(k,5) == 1
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
        imwrite(frame, sprintf('/home/nurlan/Developer/human-stress-detector/pose_estimation_code_release_v1.22/example_data/images/%02d.png', k)); 
        pause(1);
        [T sticks_imgcoor] = PoseEstimStillImage(pwd, 'images', '%02d.png', k, 'full', bboxes', fghigh_params, parse_params_Buffy3and4andPascal, [], pm2segms_params, true);
        processedFrame = imread(sprintf('/home/nurlan/Developer/human-stress-detector/pose_estimation_code_release_v1.22/example_data/segms_full/%02d.png', k));
        frame = insertObjectAnnotation(frame,'rectangle',bboxes,scores);
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
close(writerObj);