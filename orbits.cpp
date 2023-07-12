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

QVector2D Orbits::displacementAt(double theta, int planet)
{
    double r = _getDistance(data->_distances[planet], data->_eccentricities[planet], theta);

    return QVector2D(r * qCos(theta), r * qSin(theta));
}

QVector3D Orbits::displacementAt3D(double theta, int planet)
{
    double r = _getDistance(data->_distances[planet], data->_eccentricities[planet], theta);
    double inc = TO_RAD(data->_inclinations[planet]);
    double xz = r * qCos(theta);

    return QVector3D(xz * qCos(inc), r * qSin(theta), xz * qSin(inc));
}

QVector2D Orbits::getMaxDisplacement(int index)
{
    /*
    This is just an estimate
    */
    qreal radius = data->_distances[index];
    qreal eccentricity = data->_eccentricities[index];

    return QVector2D(_getDistance(radius, eccentricity, 0.0), _getDistance(radius, eccentricity, PI / 2));
}

xt::xarray<double> Orbits::_getOrbit(double radius, double eccentricity, int numSamples, bool simplify)
{
    xt::xtensor<double, 1> theta = xt::linspace(0.0, TAU, numSamples);

    xt::xtensor<double, 1> distances = getDistance(radius, eccentricity, theta);
    xt::xarray<double> displacements = xt::stack(xt::xtuple(distances * xt::cos(theta), distances * xt::sin(theta)));
    displacements = xt::rot90(displacements);

    if (simplify)
    {
        xt::xarray<double> _displacements = LineSimplify::vwReduce(displacements, 0.0001);
        return _displacements;
    }
    else
    {
        return displacements;
    }
}

QVector<QVector2D> Orbits::getOrbit(int index, int numSamples, bool simplify)
{
    double radius = data->_distances[index];
    double eccentricity = data->_eccentricities[index];

    QVector<QVector2D> out;

    xt::xarray<double> displacements = _getOrbit(radius, eccentricity, numSamples, simplify);

    for (int i = 0; i < displacements.shape(0); i++)
    {
        out.append(QVector2D(displacements(i, 0), displacements(i, 1)));
    }

    return out;
}

QVector<QVector3D> Orbits::getOrbit3D(int index, int numSamples, bool simplify)
{
    QVector<QVector3D> out;

    double radius = data->_distances[index];
    double eccentricity = data->_eccentricities[index];

    xt::xarray<double> points2d = _getOrbit(radius, eccentricity, numSamples, simplify);

    double inc = TO_RAD(data->_inclinations[index]);

    xt::xarray<double> z = xt::eval(xt::col(points2d, 0));

    xt::col(points2d, 0) *= qCos(inc);
    z *= qSin(inc);

    for (int i = 0; i < points2d.shape(0); i++)
    {
        out.append(QVector3D(points2d(i, 0), points2d(i, 1), z(i)));
    }

    return out;
}
