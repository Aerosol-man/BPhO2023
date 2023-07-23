#include "linegenerator.h"

LineGenerator::LineGenerator(QObject *parent, PlanetData *planetData, Orbits *orb, AngleIntegrator *intg)
    : QObject{parent}
{
    data = planetData;
    orbits = orb;
    integrator = intg;
}

QVector<QVector4D> LineGenerator::lines(int p1, int p2, int periods, int samples)
{
    QVector<QVector4D> out;

    int outer = std::max(p1, p2);
    int inner = std::min(p1, p2);

    double innerPeriod = data->_orbitalPeriods[inner];
    double outerPeriod = data->_orbitalPeriods[outer];

    xt::xtensor<double, 2> outerAngleTimes = integrator->integrate(outerPeriod, data->_eccentricities[outer], periods, false, samples);
    xt::xtensor<double, 1> t = xt::col(outerAngleTimes, 0);
    xt::xtensor<double, 1> outerAngles = xt::col(outerAngleTimes, 1);

    xt::xarray<double> innerAngleTimes = integrator->integrate(innerPeriod, data->_eccentricities[inner], 1, false, samples);
    xt::xtensor<double, 1> innerTimes = xt::col(innerAngleTimes, 0);
    xt::xtensor<double, 1> innerAngles = xt::col(innerAngleTimes, 1);
    xt::xtensor<double, 1> wrappedTimes = xt::fmod(t, innerPeriod);

    //Find the angle of the inner planet for each t
    xt::xtensor<double, 1> interpInnerAngles = integrator->interpolate(innerTimes, innerAngles, wrappedTimes);

    out.reserve(t.shape(0));
    for (int i = 0; i < t.shape(0); i++) {
        QVector2D start = orbits->displacementAt(outerAngles(i), outer);
        QVector2D end = orbits->displacementAt(interpInnerAngles(i), inner);

        out.append(QVector4D(start.x(), start.y(), end.x(), end.y()));
    }

    return out;
}
