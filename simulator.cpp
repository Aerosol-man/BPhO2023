#include "simulator.h"

Simulator::Simulator(QObject *parent)
    : QObject{parent}
{
    masses = xt::empty<double>({MAX_BODIES});
    positions = xt::empty<double>({MAX_BODIES, 3});
    velocities = xt::empty<double>({MAX_BODIES, 3});
    accelerations = xt::empty<double>({MAX_BODIES, 3});;
}



void Simulator::updateAccelerations()
{
    auto _positions = xt::view(positions, xt::range(0, numBodies), xt::all());

    for (int i = 0; i < numBodies; i++)
    {
        auto acceleration = xt::view(accelerations, i, xt::all());

        for (int j = 0; j < numBodies; j++)
        {
            if (i == j) { continue; }
            auto distance = xt::row(_positions, j) - xt::row(_positions, i);

            double force = qPow(SQUARED(distance(0))
                                    + SQUARED(distance(1))
                                    + SQUARED(distance(2)
                                    + SQUARED(softening)), -1.5);

            acceleration += distance * force * G * masses(j);
        }
    }
}

void Simulator::updatePositions(double dt)
{
    velocities += accelerations * 0.5 * dt;
    positions += velocities * dt;

    updateAccelerations();

    velocities += accelerations * 0.5 * dt;
}

void Simulator::addBody(double mass, QVector3D position)
{
    if (numBodies == MAX_BODIES) { return; }
}

void Simulator::removeBody(int index)
{
    if (index != numBodies - 1)
    {
        // TODO: Body deletion logic (yay!)
    }
    else
    {
        numBodies -= 1;
    }
}
