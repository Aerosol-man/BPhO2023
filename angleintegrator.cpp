#include "angleintegrator.h"

#include <QDebug>
//#include <stdexcept>
//#include <iostream>

AngleIntegrator::AngleIntegrator(QObject *parent, PlanetData *planetData)
    : QObject{parent}
{
    data = planetData;
}

static auto angleFunction = xt::vectorize([](double ecc, double angle) -> double {
    return qPow(1 - ecc * qCos(angle), -2);
});

class Worker : public QObject
{
    Q_OBJECT
public:
    void process(double period, double ecc, int periods);
    xt::xarray<double> data;
signals:
    void resultReady(QList<QVector2D> points);
private:
    static xt::xtensor<double, 1> interpolate(xt::xtensor<double, 1> &x, xt::xtensor<double, 1> &y, xt::xtensor<double, 1> &samplePoints)
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

    const double sampleSize = 0.001;
    const int numPoints = 30;


};

void Worker::process(double period, double ecc, int periods)
{
       QVector<QVector2D> out;
       double lastOrbitPeriod = 0.0;
       xt::xarray<double> data;

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

           if (i == 0)
           {
               data = xt::stack(xt::xtuple(t, interpolatedTheta));
           }

           for (int ii = 0; ii < t.size(); ii++)
           {
               out.append(QVector2D(t[ii], interpolatedTheta[ii]));
           }

           lastOrbitPeriod = t[t.size() - 1];
       }

       emit resultReady(out);
   }

void AngleIntegrator::fromValues(double period, double ecc, int periods)
{
    Worker* worker = new Worker();
    worker->process(period, ecc, periods);
    connect(&workerThread, &QThread::finished, worker, &QObject::deleteLater);
    connect(worker, &Worker::resultReady, this, &AngleIntegrator::handleResults);
    workerThread.start();
}

void AngleIntegrator::fromPlanet(int index, int periods)
{
    fromValues(data->_orbitalPeriods[index], data->_eccentricities[index], periods);
}

void AngleIntegrator::handleResults(QVector<QVector2D> points)
{
    //This isn't confusing at all!
    _points = points;
    //__points = data;
    emit finished();
}
