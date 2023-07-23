#ifndef LINESIMPLIFY_H
#define LINESIMPLIFY_H

#include <cmath>

#include <QVector>
#include <QVector2D>

#include <xtensor.hpp>

class LineSimplify
{
public:
    static xt::xtensor<double, 2> vwReduce(xt::xarray<double> points, double epsilon);
    static QVector<QVector2D> vwReduce(QVector<QVector2D> points, double epsilon);
};

#endif // LINESIMPLIFY_H
