#include "linesimplify.h"

//$ visvalingham-whyatt.m
xt::xtensor<double, 2> LineSimplify::vwReduce(xt::xarray<double> points, double epsilon)
{
    /*
    Implementation of the Visvalingham-Whyatt line simplification algorithm
    points - Nx2 array of points
    epsilon - minimum area for each triangle as a percentage of the total area.
              Controls the level of detail produced
    */
    xt::xtensor<double, 2> out = points;
    int length = points.shape(0);

    //Calculate area covered by the curve
    auto max = xt::amax(out, {0});
    auto min = xt::amin(out, {0});
    double epsArea = (max(0) - min(0)) * (max(1) - min(1)) * epsilon;
    int start = 1;

    while(length > 3)
    {
        //Store the index & area of the point with the lowest efective area
        int minIndex = -1;
        double minArea = epsArea;

        for (int i = start; i < length - 1; i++)
        {
            //Calulate the area of the triangle
            double area = std::abs((out(i - 1, 0) - out(i + 1, 0)) * (out(i, 1) - out(i - 1, 1))
                                   - (out(i - 1, 0) - out(i, 0)) * (out(i + 1, 1) - out(i - 1, 1))) * 0.5;

            if (area < epsArea)
            {
                if (area < minArea)
                {
                    minIndex = i;
                    minArea = area;
                }
            }
            else if (minIndex == -1)
            {
                start = i;
            }
        }

        if (minIndex != -1)
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

QVector<QVector2D> LineSimplify::vwReduce(QVector<QVector2D> points, double epsilon)
{
    QVector<QVector2D> out = points;
    double bounds[4] = {INFINITY, INFINITY, -INFINITY, -INFINITY};
    for (int i = 0; i < points.size(); i++)
    {
        if (points[i].x() < bounds[0]) { bounds[0] = points[i].x(); }
        else if (points[i].x() > bounds[2]) { bounds[2] = points[i].x(); }
        if (points[i].y() < bounds[1]) { bounds[1] = points[i].y(); }
        else if (points[i].y() > bounds[3]) { bounds[3] = points[i].y(); }
    }

    double epsArea = epsilon * (bounds[2] - bounds[0]) * (bounds[3] - bounds[1]);
    int length = points.size();
    int start = 1;

    while (length > 3)
    {
        int minIndex = -1;
        double minArea = epsArea;

        for (int i = start; i < length - 1; i++)
        {
            double area = std::abs((out[i - 1].x() - out[i + 1].x()) * (out[i].y() - out[i - 1].y())
                                   - (out[i - 1].x() - out[i].x()) * (out[i + 1].y() - out[i - 1].y())) * 0.5 ;

            if (area < epsArea)
            {
                if (area < minArea)
                {
                    minArea = area;
                    minIndex = i;
                }
            }
            else if (minIndex == -1)
            {
                start = i;
            }
        }

        if (minIndex != -1)
        {
            out.removeAt(minIndex);
            length--;
        }
        else
        {
            break;
        }
    }

    out.squeeze();
    return out;
}
