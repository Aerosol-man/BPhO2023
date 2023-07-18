#include "ptolemy.h"

#include <QDebug>

Ptolemy::Ptolemy(QObject *parent, PlanetData *planetData, Orbits *orb, AngleIntegrator *intg)
    : QObject{parent}
{
    data = planetData;
    orbits = orb;
    integrator = intg;

    cacheInfo.cachedPlanet = -1;
}

void Ptolemy::cacheOrbit(int index, int numSamples, int periods)
{
    if (index != cacheInfo.cachedPlanet || numSamples != cacheInfo.numSamples)
    {
        newCache(index, numSamples, periods);
    }
    else if (periods < cacheInfo.periods)
    {
        reduceCache(periods, numSamples);
    }
    else if (periods > cacheInfo.periods)
    {
        extendCache(index, cacheInfo.periods, periods, numSamples);
    }

    cacheInfo.cachedPlanet = index;
    cacheInfo.numSamples = numSamples;
    cacheInfo.periods = periods;
}

void Ptolemy::newCache(int index, int numSamples, int periods)
{
    double ecc = data->_eccentricities[index];

    xt::xtensor<double, 2> timeAngles = integrator->integrate(data->_orbitalPeriods[index], ecc, periods, false, numSamples);

    tCache = xt::col(timeAngles, 0);

    xt::xtensor<double, 1> angles = xt::col(timeAngles, 1);

    cache.clear();
    cache.reserve(angles.shape(0));
    for (int i = 0; i < angles.shape(0); i++)
    {
        cache.append(orbits->displacementAt(angles(i), index));
    }
}

void Ptolemy::extendCache(int index, int oldPeriods, int newPeriods, int numSamples)
{
    xt::xtensor<double, 2> timeAngles = integrator->integrate(data->_orbitalPeriods[index],
                                                              data->_eccentricities[index],
                                                              newPeriods - oldPeriods,
                                                              false,
                                                              numSamples);
    xt::xtensor<double, 1> angles = xt::col(timeAngles, 1);

    xt::xtensor<double, 1>::shape_type shape({(unsigned long)(newPeriods * numSamples)});
    auto temp = xt::xtensor<double, 1>::from_shape(shape);

    xt::view(temp, xt::range(0, tCache.shape(0))) = tCache;
    xt::view(temp, xt::range(tCache.shape(0), newPeriods * numSamples)) = xt::col(timeAngles, 0) + tCache(tCache.shape(0) - 1);
    tCache = temp;

    cache.reserve(newPeriods * numSamples);
    for (int i = 0; i < angles.shape(0); i++)
    {
        cache.append(orbits->displacementAt(angles(i), index));
    }
}

void Ptolemy::reduceCache(int newPeriods, int numSamples)
{
    tCache = xt::view(tCache, xt::range(0, newPeriods * numSamples));
    cache.resize(newPeriods * numSamples);
}

QVector<QVector2D> Ptolemy::getOrbit(int index, int numSamples, bool simplify)
{
    QVector<QVector2D> out;

    if (index < 9)
    {
        double ecc = data->_eccentricities[index];
        double period = data->_orbitalPeriods[index];

        xt::xtensor<double, 2> timeAngles = integrator->integrate(period, ecc, 1, false, numSamples);
        xt::xtensor<double, 1> x = xt::col(timeAngles, 0);
        xt::xtensor<double, 1> y = xt::col(timeAngles, 1);
        xt::xtensor<double, 1> t = xt::fmod(tCache, period);

        xt::xtensor<double, 1> theta = integrator->interpolate(x, y, t);

        for (int i = 0; i < theta.shape(0); i++)
        {
            out.append(orbits->displacementAt(theta(i), index) - cache[i]);
        }
    }
    else
    {
        for (int i = 0; i < cache.size(); i++)
        {
            out.append(cache[i] * -1);
        }
    }

    if (simplify)
    {
        out = LineSimplify::vwReduce(out, 0.00005);
    }

    return out;
}
