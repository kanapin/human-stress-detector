#include <iostream>
#include <cstring>
#include <cstdio>
#include <fstream>
#include <opencv2/opencv.hpp>
 
using namespace std;
using namespace cv;


char buff[81];



int main (int argc, const char * argv[])
{
    if (argc < 8) {
        cout << "Usage: make_video <folder> <from> <to> <width> <height> <fps> <outputFileName>\n" ;
        exit(0);
    }
    string folderName = string(argv[1]);
    int from, to, width, height, fps;

    sscanf(argv[2], "%d", &from);
    sscanf(argv[3], "%d", &to);
    sscanf(argv[4], "%d", &width);
    sscanf(argv[5], "%d", &height);
    sscanf(argv[6], "%d", &fps);

    
    Size S = Size(width, height);

    cout << "Size " << S << endl;

    VideoWriter writer;
    string outputFileName(argv[7]);
    cout << "Saving to " << outputFileName << endl;
    // TODO: fix FPS val
    writer.open(outputFileName, CV_FOURCC('P','I','M','1'), 24, S, true);
 
    Mat full_img, *prev = NULL;
    for (int f = from ; f < to ; f++)
    {
        sprintf(buff, "%s/%06d.png", folderName.c_str(), f);
        full_img = imread(buff);
        writer << full_img;
        cout << "here\n";
        
            
    }
    
    return 0;
}