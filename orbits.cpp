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

QVector<QVector2D> Orbits::getOrbit(int index, int numSamples, bool simplify)
{
    qreal radius = data->_orbitalPeriods[index];
    qreal eccentricity = data->_eccentricities[index];

    QVector<QVector2D> out;

    xt::xtensor<double, 1> theta = xt::linspace(0.0, TAU, numSamples);

    xt::xtensor<double, 1> distances = getDistance(radius, eccentricity, theta);
    xt::xarray<double> displacements = xt::stack(xt::xtuple(distances * xt::cos(theta), distances * xt::sin(theta)));
    displacements = xt::rot90(displacements);

    if (simplify)
    {
        qDebug() << "Points before simplifying: {" << displacements.shape(0) << ", " << displacements.shape(1) << "}\n";
        xt::xarray<double> _displacements = LineSimplify::vwReduce(displacements, 1);

        for (int i = 0; i < _displacements.shape(0); i++)
        {
            out.append(QVector2D(_displacements(i, 0), _displacements(i, 1)));
        }
        qDebug() << "Points after simplifying: {" << _displacements.shape(0) << ", " << _displacements.shape(1) << "}\n";
    }
    else
    {
        for (int i = 0; i < numSamples; i++)
        {
            out.append(QVector2D(displacements(i, 0), displacements(i, 1)));
            //qDebug() << out[out.size() - 1];
        }
    }

    return out;
}

QVector<QVector3D> Orbits::getOrbit3D(int index, int numSamples, bool simplify)
{
    QVector<QVector2D> points2d = getOrbit(index, numSamples, simplify);
    QVector<QVector3D> out;

    double inc = data->_inclinations[index];
    double cosine = qCos(inc); double sine = qSin(inc);

    for (auto it = points2d.begin(); it != points2d.end(); it++)
    {
        out.append(QVector3D((*it).y(), (*it).x() * cosine, (*it).x() * sine));
    }

    return out;
}
