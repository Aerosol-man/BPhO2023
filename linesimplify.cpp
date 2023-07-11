#include "linesimplify.h"

#include <QDebug>

//$ visvalingham-whyatt.m
xt::xarray<double> LineSimplify::vwReduce(xt::xarray<double> points, double epsilon)
{
    /*
    Implementation of the Visvalingham-Whyatt line simplification algorithm
    points - Nx2 array of points
    epsilon - minimum area for each triangle as a percentage of the total area.
              Controls the level of detail produced
    */
    xt::xarray<double> out = points;
    int length = points.shape(0);
    int start = 1;
    auto x = xt::view(out, xt::all(), 0);
    auto y = xt::view(out, xt::all(), 1);
    //Calculate area covered by the curve
    double curveArea = (xt::amax(x)() - xt::amin(x)()) * (xt::amax(y)() - xt::amin(y)());
    double epsArea = curveArea * epsilon;

    while(length > 3)
    {
        //Store the index & area of the point with the lowest efective area
        int minIndex = -1;
        double minArea = INFINITY;

        for (int i = start; i < length - 1; i++)
        {
            //Calulate the area of the triangle
            double area = std::abs(out(i - 1, 1) * (out(i, 0) - out(i + 1, 0))
                                   + out(i, 1) * (out(i + 1, 0) - out(i - 1, 0))
                                   + out(i + 1, 1) * (out(i, 0) - out(i - 1, 0))) * 0.5 ;

            if (area < minArea)
            {
                minIndex = i;
                minArea = area;
            }
            else
            {
                start = i;
            }
        }

        if (minArea < epsArea)
        {
            //exclude the point
//            for (int j = minIndex; j < length - 1; j++)
//            {
//                out(j, 0) = out(j + 1, 0);
//                out(j, 1) = out(j + 1, 1);
//            }
            out = xt::view(out, xt::drop(minIndex), xt::all());
            length -= 1;
        }
        else
        {
            break;
        }
    }

//    xt::xarray<double> temp(std::vector<size_t>({length, 2}));

//    for(int i = 0; i < length; i++)
//    {
//        temp(i, 0) = out(i, 0);
//        temp(i, 1) = out(i, 1);
//    }

//    return temp;
    return out;
}
//$ visvalingham-whyatt.m
