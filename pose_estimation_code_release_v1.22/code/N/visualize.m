%pathToVideo = '/home/nurlan/Dropbox/path-detector-media/working_set/nairobi_86_90.avi';
pathToVideo = '/Users/nurlan/Dropbox/path-detector-media/working_set/nairobi_128_132.avi';
videoReader = VideoReader(pathToVideo);

numberOfFrames = videoReader.NumberOfFrames;

peopleDetector = vision.PeopleDetector('UprightPeople_96x48');
%peopleDetector = vision.PeopleDetector();
detector = vision.ForegroundDetector(...
       'NumTrainingFrames', 5, ...
       'InitialVariance', 30*30);
blob = vision.BlobAnalysis(...
       'CentroidOutputPort', false, 'AreaOutputPort', false, ...
       'BoundingBoxOutputPort', true, ...
       'MinimumBlobAreaSource', 'Property', 'MinimumBlobArea', 250);
shapeInserter = vision.ShapeInserter('BorderColor','White');

for k = 1 : numberOfFrames
    frame = read(videoReader, k);
    %[bboxes,scores] = step(peopleDetector, frame);
    %frame = insertObjectAnnotation(frame,'rectangle',bboxes,scores);
    fgMask = step(detector, frame);
    bbox   = step(blob, fgMask);
    imshow(fgMask);
    s = size(bbox);
    r = s(1);
    x = 1000;
    y = 1000;
    x1 = 0;
    y1 = 0;
    
%     for i = 1 : r
%         display(box);
%         box = bbox(i, :);
%         x = min(box(1), x);
%         y = min(box(2), y);
%         x1 = max(box(1) + box(3), x1);
%         y1 = max(box(2) + box(4), y1);
%     end
    %display([x, y, x1 - x, y1 - y]);
    %true_bbox = [x, y, x1 - x, y1 - y];
    %W = waitforbuttonpress;
    step
    if true_bbox(3) > 0
        out    = step(shapeInserter, frame, true_bbox);
    else
        out = frame;
    end
    
    imshow(out);
end