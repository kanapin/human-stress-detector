#include <iostream>
#include <cstring>
#include <cstdio>
#include <fstream>
#include <opencv2/opencv.hpp>
 
using namespace std;
using namespace cv;


const int MAX_DEQUE_SIZE = 3;


string createOutputFilename(const string& s) {
    size_t dotIndex = s.find('.');
    if (dotIndex < s.length()) {
        string res = "converted_" + s.substr(0, dotIndex) + ".mkv";
        return res;
    } else {
        cerr << "Unknown extension for " << s << endl;
        exit(0);
    }
}


char buff[81];



int main (int argc, const char * argv[])
{
    if (argc < 8) {
        cout << "Usage: detectpeople <fileName> <secondFrom> <secondTo> <rx> <ry> <rwidth> <rheight>\n" ;
        exit(0);
    }
    string fileName = string(argv[1]);
    double secondFrom, secondTo;
    sscanf(argv[2], "%lf", &secondFrom);
    sscanf(argv[3], "%lf", &secondTo);
    Rect window;
    sscanf(argv[4], "%d", &window.x);
    sscanf(argv[5], "%d", &window.y);
    sscanf(argv[6], "%d", &window.width);
    sscanf(argv[7], "%d", &window.height);

    cout << "Save frames to png?\n";
    string answer;
    cin >> answer;
    bool saveFrames = false;

    if (answer == "Yes" || answer == "YES" || answer == "yes")
        saveFrames = true;


    VideoCapture cap(fileName);
    //cap.set(CV_CAP_PROP_FRAME_WIDTH, 480);
    //cap.set(CV_CAP_PROP_FRAME_HEIGHT, 360);    
    if (!cap.isOpened())
        return -1;

    int frameFrom = (int)(secondFrom * cap.get(CV_CAP_PROP_FPS));
    int frameTo = (int)(secondTo * cap.get(CV_CAP_PROP_FPS));

    cout << "Cutting from frames " << frameFrom << " to " << frameTo << endl;

    

    

    //int frameCnt = cap.get(CV_CAP_PROP_FRAME_COUNT);
    //cout << "frame count = " + frameCnt << endl;


    
    Size S = Size((int) cap.get(CV_CAP_PROP_FRAME_WIDTH),    // Acquire input size
                  (int) cap.get(CV_CAP_PROP_FRAME_HEIGHT));

    cout << "Size " << S << endl;

    VideoWriter writer;
    string outputFileName = createOutputFilename(fileName);
    cout << "Saving to " << outputFileName << endl;

    writer.open(outputFileName, CV_FOURCC('P','I','M','1'), cap.get(CV_CAP_PROP_FPS), S, true);

    if (!cap.isOpened())
    {
        cout  << "Could not open the output video for write: " << fileName << endl;
        return -1;
    }

 
    Mat full_img, img;
    HOGDescriptor hog;
    hog.setSVMDetector(HOGDescriptor::getDefaultPeopleDetector());
 
    namedWindow("video capture", CV_WINDOW_AUTOSIZE);

    fstream rectangleDataFile;
    rectangleDataFile.open("rectangleData.txt", fstream::out);

    rectangleDataFile << "from=" << frameFrom << " to=" << frameTo << '\n';

    for (int f = 0 ;  ; f ++)
    {
        cap >> full_img;
        if (!full_img.data) {
            cerr << "Frame " << f << " is skipped" << endl;
            break;
        }

        if (f < frameFrom)
            continue;
        else if (f >= frameTo )
            break;
        
        img = Mat(full_img, window);
        

        vector<Rect> found, found_filtered;
        hog.detectMultiScale(img, found, 0, Size(8,8), Size(32,32), 1.05, 2);
 
        size_t i, j;
        for (i=0; i<found.size(); i++)
        {
            Rect r = found[i];
            for (j=0; j<found.size(); j++)
                if (j!=i && (r & found[j])==r)
                    break;
            if (j==found.size())
                found_filtered.push_back(r);
        }
        vector<Rect> currentFrameRectangles;

        //rectangleDataFile << "frame: " << f << '\n';
        Rect largest(0, 0, 0, 0);
        for (i=0; i<found_filtered.size(); i++)
        {
    	    Rect r = found_filtered[i];
            r.x += cvRound(r.width*0.15);
    	    r.width = cvRound(r.width*0.65);
    	    r.y += cvRound(r.height*0.1);
    	    r.height = cvRound(r.height*0.3);
    	    if (largest.width * largest.height < r.width * r.height)
                largest = r;
            

        }
        largest.x += window.x;
        largest.y += window.y;
        rectangleDataFile << '[' << largest.x  << ' ' << largest.y  << ' ' << 
            largest.width << ' ' << largest.height << "]\n";

        if (saveFrames) {
            sprintf(buff, "frames/%06d.png", f);
            imwrite(buff, full_img);
        }
        
        rectangle(full_img, largest.tl(), largest.br(), cv::Scalar(0,255,0), 2);

        writer << full_img;
        
        imshow("video capture", full_img);
        if (waitKey(20) >= 0)
            break;
            
    }
    cap.release();
    rectangleDataFile.close();
    return 0;
}