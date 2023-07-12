#ifndef ORBITS_H
#define ORBITS_H

#include <QObject>
#include <QVector2D>
#include "planetdata.h"
#include <QtMath>
#include <xtensor.hpp>
#include "linesimplify.h"

#include "math.h"

class Orbits : public QObject
{
    Q_OBJECT
public:
    explicit Orbits(QObject *parent = nullptr);
    Orbits(QObject *parent = nullptr, PlanetData* _data = nullptr);

    Q_INVOKABLE QVector<QVector2D> getOrbit(int index, int numSamples = 100, bool simplify = false);
    Q_INVOKABLE QVector<QVector3D> getOrbit3D(int index, int numSamples = 100, bool simplify = false);
    Q_INVOKABLE QVector2D getMaxDisplacement(int index);
    Q_INVOKABLE QVector2D displacementAt(double theta, int planet);
    Q_INVOKABLE QVector3D displacementAt3D(double theta, int planet);

    xt::xarray<double> _getOrbit(double radius, double eccentricity, int numSamples, bool simplify);

signals:

private:
    PlanetData* data;

};

#endif // ORBITS_H
