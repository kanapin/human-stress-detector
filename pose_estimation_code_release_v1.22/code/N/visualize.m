%pathToVideo = '/home/nurlan/Dropbox/path-detector-media/working_set/nairobi_86_90.avi';
pathToVideo = '/home/nurlan/Dropbox/path-detector-media/working_set/nairobi_128_132.avi';
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
    s = size(bbox);
    r = s(1);
    x = 0;
    y = 0;
    x1 = 1000;
    y1 = 1000;
    for i = 1 : r
        
    end
    W = waitforbuttonpress;
    out    = step(shapeInserter, frame, bbox);
    imshow(out);
end