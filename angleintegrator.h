#ifndef ANGLEINTEGRATOR_H
#define ANGLEINTEGRATOR_H

#include <QObject>
#include <QVector>
#include <QVector2D>
#include <QtMath>

#include <xtensor.hpp>
//#include <cmath>
#include <algorithm>
#include <iterator>

#include "planetdata.h"
#include "math.h"

class AngleIntegrator : public QObject
{
    Q_OBJECT
public:
    explicit AngleIntegrator(QObject *parent = nullptr);
    AngleIntegrator(QObject *parent = nullptr, PlanetData *planetData = nullptr);

    Q_INVOKABLE QVector<QVector2D> fromPlanet(int index, int periods = 1);
    Q_INVOKABLE QVector<QVector2D> fromValues(double period, double ecc, int periods = 1);

private:
    PlanetData *data;

    const double sampleSize = 0.001;
    const int numPoints = 30;
};

#endif // ANGLEINTEGRATOR_H
