#include "angleintegrator.h"

AngleIntegrator::AngleIntegrator(QObject *parent, PlanetData *planetData)
    : QObject{parent}
{
    data = planetData;
}

static auto angleFunction = xt::vectorize([](double ecc, double angle) -> double {
    return qPow(1 - ecc * qCos(angle), -2);
});

xt::xtensor<double, 1> interpolate(xt::xtensor<double, 1> &x, xt::xtensor<double, 1> &y, xt::xtensor<double, 1> &samplePoints)
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

//$ simpson.m
QVector<QVector2D> AngleIntegrator::fromValues(double period, double ecc, int periods)
{
    QVector<QVector2D> out;
    double lastOrbitPeriod = 0.0;

    for (int i = 0; i < periods; i++)
    {
        double start = TAU * i;
        xt::xtensor<double, 1> theta = xt::arange(start, start + TAU, sampleSize);
        xt::xtensor<double, 1> integral = angleFunction(ecc, theta);

        // get all the even-numbered values (excluding the first & last value)
        auto evens = xt::view(integral, xt::range(2, integral.size() - 1, 2));
        // get all the odd-numbered values (excluding the fist & last value)
        auto odds = xt::view(integral, xt::range(1, integral.size() - 1, 2));
        evens *= 2;
        odds *= 4;

        integral = xt::cumsum(integral);
        integral *= sampleSize / 3;

        xt::xtensor<double, 1> calculatedTime = period * qPow(1 - SQUARED(ecc), 1.5) * 1 / TAU * integral;
        calculatedTime += lastOrbitPeriod;
        xt::xtensor<double, 1> t = xt::linspace(xt::amin(calculatedTime)(), xt::amax(calculatedTime)(), numPoints);
        xt::xtensor<double, 1> interpolatedTheta = interpolate(calculatedTime, theta, t);

        for (int ii = 0; ii < t.size(); ii++)
        {
            out.append(QVector2D(t[ii], interpolatedTheta[ii]));
        }

        lastOrbitPeriod = t[t.size() - 1];
    }

    return out;
}
//$ simpson.m

QVector<QVector2D> AngleIntegrator::fromPlanet(int index, int periods)
{
    return fromValues(data->_orbitalPeriods[index], data->_eccentricities[index], periods);
}


