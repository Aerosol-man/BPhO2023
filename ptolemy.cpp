#include "ptolemy.h"

Ptolemy::Ptolemy(QObject *parent, PlanetData *planetData, Orbits *orb, AngleIntegrator *intg)
    : QObject{parent}
{
    data = planetData;
    orbits = orb;
    integrator = intg;
}

void Ptolemy::cacheOrbit(int index, int numSamples, int periods)
{
    double ecc = data->_eccentricities[index];

    xt::xtensor<double, 2> timeAngles = integrator->integrate(data->_orbitalPeriods[index], ecc, periods, false, numSamples);

    tCache = xt::col(timeAngles, 0);

    xt::xtensor<double, 1> angles = xt::col(timeAngles, 1);

    cache.clear();
    for (int i = 0; i < angles.shape(0); i++)
    {
        cache.append(orbits->displacementAt(angles(i), index));
    }
}

QVector<QVector2D> Ptolemy::getOrbit(int index, int numSamples)
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
        out.resize(tCache.shape(0));
        for (int i = 0; i < out.size(); i++)
        {
            out[i] = QVector2D(0, 0);
        }
    }

    return out;
}
