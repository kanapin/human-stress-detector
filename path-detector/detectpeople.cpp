#include <iostream>
#include <opencv2/opencv.hpp>
 
using namespace std;
using namespace cv;
 
int main (int argc, const char * argv[])
{
    if (argc < 2) {
        cout << "Usage: detectpeople <fileName>\n" ;
        exit(0);
    }
    string fileName = string(argv[1]);

    VideoCapture cap(fileName);
    cap.set(CV_CAP_PROP_FRAME_WIDTH, 480);
    cap.set(CV_CAP_PROP_FRAME_HEIGHT, 360);    
    if (!cap.isOpened())
        return -1;

    

    //int frameCnt = cap.get(CV_CAP_PROP_FRAME_COUNT);
    //cout << "frame count = " + frameCnt << endl;


    
    Size S = Size((int) cap.get(CV_CAP_PROP_FRAME_WIDTH),    // Acquire input size
                  (int) cap.get(CV_CAP_PROP_FRAME_HEIGHT));
    VideoWriter writer;
    writer.open("_" + fileName + ".mkv", CV_FOURCC('P','I','M','1'), cap.get(CV_CAP_PROP_FPS), S, true);

    if (!cap.isOpened())
    {
        cout  << "Could not open the output video for write: " << fileName << endl;
        return -1;
    }

 
    Mat img;
    HOGDescriptor hog;
    hog.setSVMDetector(HOGDescriptor::getDefaultPeopleDetector());
 
    //namedWindow("video capture", CV_WINDOW_AUTOSIZE);
    cout << "here\n";
    for (int f = 0 ;  ; f ++)
    {
        cap >> img;
        if (!img.data)
            continue;

        if (f < 75 * 30)
            continue;
        else if (f > (75 + 10) * 30 )
            break;
        //cout << "there\n";
        
 
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
        for (i=0; i<found_filtered.size(); i++)
        {
    	    Rect r = found_filtered[i];
            r.x += cvRound(r.width*0.1);
    	    r.width = cvRound(r.width*0.8);
    	    r.y += cvRound(r.height*0.06);
    	    r.height = cvRound(r.height*0.9);
    	    rectangle(img, r.tl(), r.br(), cv::Scalar(0,255,0), 2);
        }
        writer << img;
        /*imshow("video capture", img);
        if (waitKey(20) >= 0)
            break;
            */
    }
    cap.release();
    return 0;
}