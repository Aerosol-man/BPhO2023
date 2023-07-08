#include "planetdata.h"
#include <QFile>
#include <QDebug>

PlanetData::PlanetData(QObject *parent)
    : QObject{parent}
{
    QFile planetData(":/planet_data.csv");

    if (!planetData.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        qDebug() << "File opening failed :(";
        return;
    }

    QTextStream stream(&planetData);

    int rowNumber = 0;
    QStringList row;
    QString currentLine;

    while (stream.readLineInto(&currentLine))
    {
        if (rowNumber == 0) { ++rowNumber; continue; }  // Ignore the header row

        row.clear();

        row = currentLine.split(",");

        for (int i = 0; i < NUM_PLANETS; i++)
        {
            double value = (row[i + 1].toDouble());

            switch (rowNumber - 1)
            {
            case 0:
                _masses.append(value);
                break;
            case 1:
                _distances.append(value);
                break;
            case 2:
                _radii.append(value);
                break;
            case 3:
                _rotationalPeriods.append(value);
                break;
            case 4:
                _orbitalPeriods.append(value);
                break;
            case 5:
                _eccentricities.append(value);
                break;
            case 6:
                _inclinations.append(value);
                break;
            }
        }
        ++rowNumber;
    }

    planetData.close();
}

qreal PlanetData::getMax(QString name)
{
    QList<QVariant> values = property(name.toLocal8Bit().data()).toList();
    qreal out = 0.0;

    for (int i = 0; i < 9; i++)
    {
        if (values[i].toReal() > out)
        {
            out = values[i].toReal();
        }
    }

    return out;
}
