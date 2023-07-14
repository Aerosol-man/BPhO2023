#include "angleintegrator.h"

#include <QDebug>

AngleIntegrator::AngleIntegrator(QObject *parent, PlanetData *planetData)
    : QObject{parent}
{
    data = planetData;
}

static auto angleFunction = xt::vectorize([](double ecc, double angle) -> double {
    return qPow(1 - ecc * qCos(angle), -2);
});

xt::xtensor<double, 1> AngleIntegrator::interpolate(xt::xtensor<double, 1> &x, xt::xtensor<double, 1> &y, xt::xtensor<double, 1> &samplePoints)
{
    xt::xtensor<double, 1> out = xt::empty_like(samplePoints);

    for (int i = 0; i < samplePoints.size(); i++)
    {
        // Get the first number greater than the sample value
        auto upperBound = std::upper_bound(x.begin(), x.end(), samplePoints[i]);

        if (*upperBound != x[0])
        {
            // Get the last number less than the sample value
            auto lowerBound = upperBound; lowerBound--;
            // Get floating-point index of the value
            double index = std::distance(x.begin(), lowerBound) + (samplePoints[i] - *lowerBound) / (*upperBound - *lowerBound);
            out[i] = y[qFloor(index)] + (y[qCeil(index)] - y[ qFloor(index)]) * (index - qFloor(index));
        }
        else
        {
            out[i] = *upperBound;
        }
    }
    return out;
}

xt::xarray<double> AngleIntegrator::integrate(double period, double ecc, int periods, bool simplify, int n)
{
    double lastOrbitPeriod = 0.0;
    xt::xtensor<double, 1>::shape_type shape = {n * periods};
    auto interpolatedTheta = xt::xtensor<double, 1>::from_shape(shape);
    auto t = xt::xtensor<double, 1>::from_shape(shape);

    double start = 0;
    xt::xtensor<double, 1> theta = xt::arange(start, start + TAU, sampleSize);
    xt::xtensor<double, 1> integral = angleFunction(ecc, theta);

    // get all the even-numbered values (excluding the first & last value)
    auto evens = xt::view(integral, xt::range(2, integral.size() - 1, 2));
    // get all the odd-numbered values (excluding the fist & last value)
    auto odds = xt::view(integral, xt::range(1, integral.size() - 1, 2));
    evens *= 2;
    odds *= 4;

    // Calculate the cumulative sum to get the sum at each t
    integral = xt::cumsum(integral);
    integral *= sampleSize / 3;

    xt::xtensor<double, 1> calculatedTime = period * qPow(1 - SQUARED(ecc), 1.5) * 1 / TAU * integral;
    xt::xtensor<double, 1> _t = xt::linspace(xt::amin(calculatedTime)(), xt::amax(calculatedTime)(), n);
    xt::xtensor<double, 1> _interpolatedTheta = interpolate(calculatedTime, theta, _t);

    if (periods > 1)
    {
        xt::view(t, xt::range(0, n)) = _t;
        xt::view(interpolatedTheta, xt::range(0, n)) = _interpolatedTheta;

        for (int i = 1; i < periods; i++)
        {
            xt::view(t, xt::range(i * n, (i + 1) * n)) = xt::view(t, xt::range(0, n)) + t[i * n - 1];
            xt::view(interpolatedTheta, xt::range(i * n, (i + 1) * n)) = xt::view(interpolatedTheta, xt::range(0, n)) + TAU * i;
        }
    }
    else {
        t = _t;
        interpolatedTheta = _interpolatedTheta;
    }

    xt::xarray<double> out = xt::stack(xt::xtuple(interpolatedTheta, t));
    out = xt::rot90<-1>(out);

    if (simplify)
    {

        xt::xarray<double> _out = LineSimplify::vwReduce(out, 0.01);
        return _out;
    }

    return out;
}

//$ simpson.m
QVector<QVector2D> AngleIntegrator::fromValues(double period, double ecc, int periods, bool simplify)
{
    QVector<QVector2D> out;
    xt::xarray<double> theta = integrate(period, ecc, periods, simplify, numPoints);

    for (int i = 0; i < theta.shape(0); i++)
    {
        out.append(QVector2D(theta(i, 0), theta(i, 1)));
    }

    return out;
}
//$ simpson.m

QVector<QVector2D> AngleIntegrator::fromPlanet(int index, int periods, bool simplify)
{
    return fromValues(data->_orbitalPeriods[index], data->_eccentricities[index], periods, simplify);
}


