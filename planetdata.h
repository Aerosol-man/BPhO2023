#ifndef PLANETDATA_H
#define PLANETDATA_H

#include <QObject>
#include <qqml.h>
#include <QtCore/QDir>

#define NUM_PLANETS 9

class PlanetData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVector<qreal> masses MEMBER _masses NOTIFY massesChanged)
    Q_PROPERTY(QVector<qreal> distances MEMBER _distances NOTIFY distancesChanged)
    Q_PROPERTY(QVector<qreal> radii MEMBER _radii NOTIFY radiiChanged)
    Q_PROPERTY(QVector<qreal> rotationalPeriods MEMBER _rotationalPeriods NOTIFY rotationalPeriodsChanged)
    Q_PROPERTY(QVector<qreal> orbitalPeriods MEMBER _orbitalPeriods NOTIFY orbitalPeriodsChanged)
    Q_PROPERTY(QVector<qreal> eccentricities MEMBER _eccentricities NOTIFY eccentricitiesChanged)
    Q_PROPERTY(QVector<qreal> inclinations MEMBER _inclinations NOTIFY inclinationsChanged)
    QML_ELEMENT
public:
    explicit PlanetData(QObject *parent = nullptr);

    QVector<qreal> _masses;
    QVector<qreal> _distances;
    QVector<qreal> _radii;
    QVector<qreal> _rotationalPeriods;
    QVector<qreal> _orbitalPeriods;
    QVector<qreal> _eccentricities;
    QVector<qreal> _inclinations;

    Q_INVOKABLE qreal getMax(QString name);

private:

signals:
    void massesChanged();
    void distancesChanged();
    void radiiChanged();
    void rotationalPeriodsChanged();
    void orbitalPeriodsChanged();
    void eccentricitiesChanged();
    void inclinationsChanged();

public slots:

};

#endif // PLANETDATA_H
