#ifndef LINESIMPLIFY_H
#define LINESIMPLIFY_H

#include <cmath>
#include<iterator>
#include <xtensor.hpp>

class LineSimplify
{
public:
    static xt::xarray<double> vwReduce(xt::xarray<double> points, double epsilon);
};

#endif // LINESIMPLIFY_H
