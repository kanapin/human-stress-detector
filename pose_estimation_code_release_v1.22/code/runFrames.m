function [] = runFrames(pathToFrameData, fghigh_params, parse_params_Buffy3and4andPascal, pm2segms_params)

fileID = fopen(pathToFrameData, 'r');
from = fscanf(fileID, 'from=%d ', 1);
to = fscanf(fileID, 'to=%d\n', 1);

for f = from:to-1
    my_bb = fscanf(fileID, '[%d %d %d %d]\n', 4);
    [T sticks_imgcoor] = PoseEstimStillImage(pwd, 'example_data/images/frames', '%06d.png', f, 'full', my_bb, fghigh_params, parse_params_Buffy3and4andPascal, [], pm2segms_params, true);
end

end