#include "orbits.h"

#include <QDebug>

Orbits::Orbits(QObject *parent, PlanetData *_data) : QObject{parent}
{
    data = _data;
}

static double _getDistance(double r, double ecc, double theta) {
    return (r * (1 - SQUARED(ecc))) / (1 - ecc * std::cos(theta));
}
static auto getDistance = xt::vectorize(_getDistance);

QVector2D Orbits::getMaxDisplacement(int index)
{
    qreal radius = data->_orbitalPeriods[index];
    qreal eccentricity = data->_eccentricities[index];

    return QVector2D(_getDistance(radius, eccentricity, 0.0), _getDistance(radius, eccentricity, PI / 2));
}

QVector<QVector2D> Orbits::getOrbit(int index, int numSamples)
{
    qreal radius = data->_orbitalPeriods[index];
    qreal eccentricity = data->_eccentricities[index];

    QVector<QVector2D> out;

    xt::xtensor<double, 1> theta = xt::linspace(0.0, TAU, numSamples);

    xt::xtensor<double, 1> distances = getDistance(radius, eccentricity, theta);
    auto displacements = xt::stack(xt::xtuple(distances * xt::cos(theta), distances * xt::sin(theta)));

    for (int i = 0; i < numSamples; i++)
    {
        out.append(QVector2D(displacements(0, i), displacements(1, i)));
    }

    return out;
}

QVector<QVector3D> Orbits::getOrbit3D(int index, int numSamples)
{
    QVector<QVector2D> points2d = getOrbit(index, numSamples);
    QVector<QVector3D> out;

    double inc = data->_inclinations[index];
    double cosine = qCos(inc); double sine = qSin(inc);

    for (auto it = points2d.begin(); it != points2d.end(); it++)
    {
        out.append(QVector3D((*it).y(), (*it).x() * cosine, (*it).x() * sine));
    }

    return out;
}
