#include "simulator.h"

#include <QDebug>

using vec2 = xt::xtensor_fixed<double, xt::xshape<2>>;

Simulator::Simulator(QObject *parent)
    : QObject{parent}
{
    masses = xt::zeros<double>({MAX_BODIES});
    positions = xt::zeros<double>({MAX_BODIES, 2});
    velocities = xt::zeros<double>({MAX_BODIES, 2});
    accelerations = xt::zeros<double>({MAX_BODIES, 2});;
}

QVector<QVector2D> Simulator::getPositions()
{
    QVector<QVector2D> out;
    out.reserve(numBodies);
    for (int i = 0; i < numBodies; i++)
    {
        out.append(QVector2D(positions(i, 0), positions(i, 1)));
    }
    return out;
}

QVector<double> Simulator::getMasses()
{
    QVector<double> out;
    out.reserve(numBodies);
    for (int i = 0; i < numBodies; i++)
    {
        out.append(masses(i));
    }
    return out;
}

void Simulator::updateAccelerations()
{
    for (int i = 0; i < numBodies; i++)
    {
        xt::row(accelerations, i) = getAcceleration(i);
    }
}

vec2 Simulator::getAcceleration(int idx)
{
    auto out = vec2({0, 0});

    for (int i = 0; i < numBodies; i++)
    {
        if (idx == i) { continue; }
        auto distance = xt::row(positions, i) - xt::row(positions, idx);
        double force = qPow(xt::sum(xt::pow(distance, 2))() + SQUARED(softening), -1.5);
        out += distance * force * G * masses(i);
    }
    return out;
}

void Simulator::updatePositions(double _dt, int substeps)
{
    double dt = _dt / substeps;
    for (int i = 0; i < substeps; i++)
    {
        velocities += accelerations * 0.5 * dt;
        positions += velocities * dt;

        updateAccelerations();

        velocities += accelerations * 0.5 * dt;
    }
}

void Simulator::addBody(double mass, QVector2D position)
{
    if (numBodies == MAX_BODIES) { return; }

    positions(numBodies, 0) = position.x();
    positions(numBodies, 1) = position.y();
    xt::xarray<double> acc = getAcceleration(numBodies);
    acc(0) = qMin(qMax((double) acc(0), -75.0), 75.0);
    acc(1) = qMin(qMax((double) acc(1), -75.0), 75.0);
    double meanMass = 0;
    double r = 1;

    if (numBodies != 0)
    {
        double centreOfMass[2] = {0, 0};
        auto _masses = xt::view(masses, xt::range(0, numBodies));
        double totalMass = xt::sum(_masses)();
        meanMass = xt::amax(_masses)();

        for (int i = 0; i < numBodies; i++)
        {
            centreOfMass[0] += positions(i, 0) * masses(i) / totalMass;
            centreOfMass[1] += positions(i, 1) * masses(i) / totalMass;
        }

        double dx = position.x() - centreOfMass[0];
        double dy = position.y() - centreOfMass[1];

        r = qMax(qSqrt(SQUARED(dx) + SQUARED(dy)), 0.001);
    }

    // Make starting velocity tangential to acceleration
    double accLength = qMax((SQUARED(acc(1)) + SQUARED(acc(0))), 0.001);
    xt::row(velocities, numBodies) = xt::xarray<double>({-acc(1), acc(0)}) * qSqrt(meanMass * G / (r * accLength));
//    qDebug() << "Acceleration: " << -acc(1) << ", " << acc(0);
//    qDebug() << "Velocity: " << velocities(numBodies, 0) << ", " << velocities(numBodies, 1);
    xt::row(accelerations, numBodies) = acc;
    masses(numBodies) = mass;

    numBodies += 1;
}

void Simulator::addBody(double mass, QVector2D position, QVector2D velocity)
{
    if (numBodies == MAX_BODIES) { return; }

    positions(numBodies, 0) = position.x();
    positions(numBodies, 1) = position.y();
    velocities(numBodies, 0) = velocity.x();
    velocities(numBodies, 1) = velocity.y();
    xt::row(accelerations, numBodies) = getAcceleration(numBodies);
    masses(numBodies) = mass;

    numBodies += 1;
}

void Simulator::reset()
{
    numBodies = 0;
//    masses.fill(0.);
//    positions.fill(0.);
//    velocities.fill(0.);
//    accelerations.fill(0.);
}

void Simulator::removeBody(int index)
{
    if (index != numBodies - 1 && index != -1)
    {
        xt::view(masses, xt::range(0, numBodies - 1)) = xt::view(masses, xt::drop(index));
        xt::view(positions, xt::range(0, numBodies - 1), xt::all()) = xt::view(positions, xt::drop(index), xt::all());
        xt::view(velocities, xt::range(0, numBodies - 1), xt::all()) = xt::view(velocities, xt::drop(index), xt::all());
        xt::view(accelerations, xt::range(0, numBodies - 1), xt::all()) = xt::view(accelerations, xt::drop(index), xt::all());
    }
    numBodies -= 1;
}
