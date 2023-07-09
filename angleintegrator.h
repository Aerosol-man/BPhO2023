#ifndef ANGLEINTEGRATOR_H
#define ANGLEINTEGRATOR_H

#include <QObject>
#include <QList>
#include <QVector>
#include <QVector2D>
#include <QtMath>
#include <QThread>

#include <xtensor.hpp>
//#include <cmath>
#include <algorithm>
#include <iterator>

#include "planetdata.h"
#include "math.h"

class AngleIntegrator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVector<QVector2D> points MEMBER _points NOTIFY pointsChanged)
public:
    explicit AngleIntegrator(QObject *parent = nullptr);
    AngleIntegrator(QObject *parent = nullptr, PlanetData *planetData = nullptr);

    Q_INVOKABLE QVector<QVector2D> fromPlanet(int index, int periods = 1);
    Q_INVOKABLE QVector<QVector2D> fromValues(double period, double ecc, int periods = 1);

    QVector<QVector2D> _points;
    xt::xarray<double> __points; //This is bad variable naming

    QThread workerThread;

signals:
    void pointsChanged();
private:
    PlanetData *data;

    const double sampleSize = 0.001;
    const int numPoints = 30;
};

#endif // ANGLEINTEGRATOR_H
