#ifndef SIMULATOR_H
#define SIMULATOR_H

#include <QObject>
#include <xtensor.hpp>
#include "simplemath.h"
#include <QVector>
#include <QVector3D>
#include <qmath.h>

class Simulator : public QObject
{
    Q_OBJECT
public:
    explicit Simulator(QObject *parent = nullptr);
    Q_INVOKABLE void addBody(double mass, QVector3D position);
    Q_INVOKABLE void removeBody(int index);


signals:

private:
    static const int MAX_BODIES = 20;
    const double G = 0.0000000000667;
    int numBodies = 2;
    double softening = 0.2;

    void updateAccelerations();
    void updatePositions(double dt);
    xt::xtensor_fixed<double, xt::xshape<MAX_BODIES>> masses;
    xt::xtensor_fixed<double, xt::xshape<MAX_BODIES, 3>> positions;
    xt::xtensor_fixed<double, xt::xshape<MAX_BODIES, 3>> velocities;
    xt::xtensor_fixed<double, xt::xshape<MAX_BODIES, 3>> accelerations;
};

#endif // SIMULATOR_H
