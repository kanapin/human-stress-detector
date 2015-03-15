#include <iostream>
#include <cstring>
#include <cstdio>
#include <fstream>
#include <opencv2/opencv.hpp>
 
using namespace std;
using namespace cv;



int main (int argc, const char * argv[])
{
    if (argc < 2) {
        cout << "Usage: cvt <inputFileName> [OutputFileName] [from sec] [to sec] [fps]\n";
        exit(0);
    }
    string inputFileName = string(argv[1]);
    string outputFileName = inputFileName + ".avi";
    int fps = 30;
    if (argc >= 3) {
        outputFileName = string(argv[2]);
    }
    int from = 0, to = 1 << 30;
    double f1, f2;
    if (argc >= 5) {
        sscanf(argv[3], "%lf", &f1);
        sscanf(argv[4], "%lf", &f2);
    }
    if (argc >= 6) 
	sscanf(argv[5], "%d", &fps);
    from = (int)(f1 * fps);
    to = (int)(f2 * fps);
    cout << "FPS = " << fps << endl;

    VideoCapture cap(inputFileName);
    cap.set(CV_CAP_PROP_FRAME_WIDTH, 640);
    cap.set(CV_CAP_PROP_FRAME_HEIGHT, 360);    


    Size S = Size((int) cap.get(CV_CAP_PROP_FRAME_WIDTH),    // Acquire input size
                  (int) cap.get(CV_CAP_PROP_FRAME_HEIGHT));

    S = Size(640, 360);

    cout << "Size " << S << endl;

    VideoWriter writer;
    
    

    //writer.open(outputFileName, CV_FOURCC('P','I','M','1'), cap.get(CV_CAP_PROP_FPS), S, true);
    writer.open(outputFileName, CV_FOURCC('M','J','P','G'), fps, S, true);
    if (!writer.isOpened())
    {
        cout  << "Could not open the output video for write: " << outputFileName << endl;
        return -1;
    }
    cout << "Saving to " << outputFileName << endl;

    if (!cap.isOpened())
    {
        cout  << "Could not open the output video for write: " << inputFileName << endl;
        return -1;
    }

    Mat img;
    //namedWindow( "Display window", WINDOW_AUTOSIZE );// Create a window for display.
    
    
    for (int f = 0 ;  ; f ++)
    {
        
        cap >> img;
        if (f < from) {
            continue;
        }
        else if (f >= to) {
            break;
        }
        if (!img.data) {
            cerr << "Frame " << f << " is skipped" << endl;
            break;
        }
        //cout << img.cols << ' ' << img.rows << endl;
        //imshow( "Display window", img ); 
        resize(img, img, Size(640, 360), 0, 0, INTER_CUBIC);
        writer << img;
        //waitKey(0);
            
    }
    cap.release();
    
    return 0;
}
