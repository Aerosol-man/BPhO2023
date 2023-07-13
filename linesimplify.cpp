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

    //Calculate area covered by the curve
    auto x = xt::view(out, xt::all(), 0);
    auto y = xt::view(out, xt::all(), 1);
    double curveArea = (xt::amax(x)() - xt::amin(x)()) * (xt::amax(y)() - xt::amin(y)());
    double epsArea = curveArea * epsilon;

    while(length > 3)
    {
        //Store the index & area of the point with the lowest efective area
        int minIndex = -1;
        double minArea = curveArea;

        for (int i = 1; i < length - 1; i++)
        {
            //Calulate the area of the triangle
            double area = std::abs((out(i - 1, 0) - out(i + 1, 0)) * (out(i, 1) - out(i - 1, 1))
                                   - (out(i - 1, 0) - out(i, 0)) * (out(i + 1, 1) - out(i - 1, 1))) * 0.5 ;

            if (area < minArea)
            {
                minIndex = i;
                minArea = area;
            }
        }

        if (minArea < epsArea)
        {
            //exclude the point
            out = xt::view(out, xt::drop(minIndex), xt::all());
            length -= 1;
        }
        else
        {
            break;
        }
    }
    return out;
}
//$ visvalingham-whyatt.m
