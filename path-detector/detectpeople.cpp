#include <iostream>
#include <queue>
#include <cstring>
#include <opencv2/opencv.hpp>
 
using namespace std;
using namespace cv;

// Let's try to look at 5 (pastFrames) frames before
const int pastFrames = 5;

class DetectedPerson
{
public:
    static int lastID;
    Rect box;
    int id;
    Scalar color;
    DetectedPerson() {}
    DetectedPerson(Rect &box) {
        this->box = box;
        id = ++lastID;
        color = cv::Scalar( (rand() & 0xff), (rand() & 0xff), (rand() & 0xff));
    }
};

int DetectedPerson::lastID = 0;

//std::list< vector<DetectedPerson> > lastFrames;

vector<DetectedPerson> previous;
list< pair<Point, cv::Scalar> > drawn;

 
int main (int argc, const char * argv[])
{
    if (argc != 4) {
        cout << "Usage: detectpeople <fileName> <from frame> <to frame>\n" ;
        exit(0);
    }
    string fileName = string(argv[1]);
    int from, to;
    from = atoi(argv[2]);
    to = atoi(argv[3]);

    VideoCapture cap(fileName);
    cap.set(CV_CAP_PROP_FRAME_WIDTH, 640);
    cap.set(CV_CAP_PROP_FRAME_HEIGHT, 360);    
    if (!cap.isOpened())
        return -1;

    
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

    namedWindow("video capture", CV_WINDOW_AUTOSIZE);
    
    for (int f = 0 ;  ; f ++)
    {
        cap >> img;
        if (!img.data)
            continue;

        if (f < from)
            continue;
        else if (f > to )
            break;
        //cout << "there\n";
        if ( (f & 0xf) == 0xf)
            cout << "Processing frame " << f << endl;
 
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
        vector<DetectedPerson> newList;

        for (i=0; i<found_filtered.size(); i++)
        {
    	    Rect r = found_filtered[i];
            r.x += cvRound(r.width*0.1);
    	    r.width = cvRound(r.width*0.8);
    	    r.y += cvRound(r.height*0.06);
    	    r.height = cvRound(r.height*0.9);

            
            Point center = r.tl();
            center.x += r.width / 2;
            center.y += r.height / 2;

            DetectedPerson *closest = 0;
            int distToClosest = 1 << 30; // Infinity

            cout << "center = " << center << endl;

            
            for (size_t k = 0 ; k < previous.size(); k ++) {
                DetectedPerson &person = previous[k];
                Point otherCenter = person.box.tl();
                otherCenter.x += person.box.width / 2;
                otherCenter.y += person.box.height / 2;
                int dist2 = (center.x - otherCenter.x)*(center.x - otherCenter.x) + 
                    (center.y - otherCenter.y)*(center.y - otherCenter.y);

                Rect &box = person.box;
                if ( box.x - box.width/2 <= center.x && center.x <= box.x + 3*box.width/2 && 
                    box.y - box.height/2 <= center.y && center.y <= box.y + 3*box.height/2 &&
                    distToClosest > dist2) 
                {
                    closest = &person;
                    distToClosest = dist2;
                }
                
            }
            if (closest == 0) 
            {
                closest = new DetectedPerson(r);
            }
            newList.push_back(*closest);
            drawn.push_back(make_pair(center, closest->color));
            if (drawn.size() > 50)
                drawn.pop_front();
        

    	    rectangle(img, r.tl(), r.br(), closest->color, 2);
        }
        for (list< pair<Point, cv::Scalar > >::iterator it = drawn.begin() ; 
            it != drawn.end(); it ++) 
        {
            circle(img, it->first, 2, it->second, 1, 8, 0);
        }
        previous = newList;
        writer << img;
        imshow("video capture", img);
        if (waitKey(20) >= 0)
            break;
        
        /*cout << "Press enter\n";
        char read = 0;
        cin >> read;
        */
    }
    cap.release();
    return 0;
}