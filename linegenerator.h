#ifndef LINEGENERATOR_H
#define LINEGENERATOR_H

#include <QObject>
#include <QVector>
#include <QVector2D>
#include <QVector4D>

#include <cmath>

#include <xtensor.hpp>

#include "angleintegrator.h"
#include "planetdata.h"
#include "orbits.h"

class LineGenerator : public QObject
{
    Q_OBJECT
public:
    explicit LineGenerator(QObject *parent = nullptr);
    LineGenerator(QObject *parent = nullptr, PlanetData *planetData = nullptr, Orbits *orb = nullptr, AngleIntegrator *intg = nullptr);

    Q_INVOKABLE QVector<QVector4D> lines(int p1, int p2, int periods, int samples);

private:
    PlanetData *data;
    Orbits *orbits;
    AngleIntegrator *integrator;
};

#endif // LINEGENERATOR_H
