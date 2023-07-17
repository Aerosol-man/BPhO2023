#ifndef PTOLEMY_H
#define PTOLEMY_H

#include <QObject>
#include <QVector>
#include <QVector2D>

#include <xtensor.hpp>

#include "planetdata.h"
#include "orbits.h"
#include "angleintegrator.h"

struct CacheInfo
{
    int cachedPlanet;
    int numSamples;
    int periods;
};

class Ptolemy : public QObject
{
    Q_OBJECT
public:
    explicit Ptolemy(QObject *parent = nullptr);
    Ptolemy(QObject *parent = nullptr, PlanetData *data = nullptr, Orbits *orbits = nullptr, AngleIntegrator *integrator = nullptr);
    Q_INVOKABLE QVector<QVector2D> getOrbit(int index, int numSamples = 100);
    Q_INVOKABLE void cacheOrbit(int index, int numSamples = 100, int periods = 1);

private:
    void newCache(int index, int numSamples, int periods);
    void extendCache(int index, int oldPeriods, int newPeriods, int numSamples);
    void reduceCache(int newPeriods, int numSamples);

    PlanetData *data;
    Orbits *orbits;
    AngleIntegrator *integrator;
    QVector<QVector2D> cache;
    xt::xtensor<double, 1> tCache;
    CacheInfo cacheInfo;
};

#endif // PTOLEMY_H
