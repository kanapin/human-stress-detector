cmake_minimum_required(VERSION 2.8)
project( bodydetector )
find_package( OpenCV REQUIRED )
include_directories( ${OpenCV_INCLUDE_DIRS} )
add_executable( bodydetector bodydetector.cpp )
target_link_libraries( bodydetector ${OpenCV_LIBS} )

