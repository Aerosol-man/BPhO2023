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

    Q_INVOKABLE void fromPlanet(int index, int periods = 1);
    Q_INVOKABLE void fromValues(double period, double ecc, int periods = 1);

    QVector<QVector2D> _points;
    xt::xarray<double> __points; //This is bad variable naming

    QThread workerThread;

signals:
    void pointsChanged();
    void finished();
public slots:
    void handleResults(QVector<QVector2D> points);
private:
    PlanetData *data;
};

#endif // ANGLEINTEGRATOR_H
