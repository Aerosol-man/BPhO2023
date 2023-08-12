#ifndef SIMULATOR_H
#define SIMULATOR_H

#include <QObject>
#include <xtensor.hpp>
#include "simplemath.h"
#include <QVector>
#include <QVector2D>
#include <qmath.h>

class Simulator : public QObject
{
    Q_OBJECT
public:
    explicit Simulator(QObject *parent = nullptr);
    Q_INVOKABLE void addBody(double mass, QVector2D position);
    Q_INVOKABLE void removeBody(int index);
    Q_INVOKABLE QVector<QVector2D> getPositions();
    Q_INVOKABLE void updatePositions(double dt, int subSteps=1);
    Q_INVOKABLE void reset();

signals:

private:
    static const int MAX_BODIES = 20;
    const double G = 0.00011841761; // AU^3/(Mearth * year^2)
    int numBodies = 0;
    double softening = 0.2;

    void updateAccelerations();
    xt::xtensor_fixed<double, xt::xshape<2>> getAcceleration(int idx);

    xt::xtensor_fixed<double, xt::xshape<MAX_BODIES>> masses;
    xt::xtensor_fixed<double, xt::xshape<MAX_BODIES, 2>> positions;
    xt::xtensor_fixed<double, xt::xshape<MAX_BODIES, 2>> velocities;
    xt::xtensor_fixed<double, xt::xshape<MAX_BODIES, 2>> accelerations;
};

#endif // SIMULATOR_H
