#include <QtWidgets/QApplication>
#include <QtCore/QDir>
#include <QtQuick/QQuickView>
#include <QtQml/QQmlEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QtQml/qqmlregistration.h>

#include "planetdata.h"
#include "angleintegrator.h"
#include "orbits.h"
#include "linegenerator.h"
#include "ptolemy.h"

int main(int argc, char *argv[])
{
    QScopedPointer<PlanetData> planetData(new PlanetData);
    QScopedPointer<Orbits> orbits(new Orbits(nullptr, planetData.data()));
    QScopedPointer<AngleIntegrator> angleIntegrator(new AngleIntegrator(nullptr, planetData.data()));
    QScopedPointer<LineGenerator> lineGenerator(new LineGenerator(nullptr, planetData.data(), orbits.data(), angleIntegrator.data()));
    QScopedPointer<Ptolemy> ptolemy(new Ptolemy(nullptr, planetData.data(), orbits.data(), angleIntegrator.data()));

    // Qt Charts uses Qt Graphics View Framework for drawing, therefore QApplication must be used.
    QApplication app(argc, argv);

    QQuickView viewer;

    // The following are needed to make examples run without having to install the module
    // in desktop environments.
#ifdef Q_OS_WIN
    QString extraImportPath(QStringLiteral("%1/../../../../%2"));
    int PLATFORM_NUM = 0;
#else
    QString extraImportPath(QStringLiteral("%1/../../../%2"));
    int PLATFORM_NUM = 1;
#endif
    viewer.engine()->addImportPath(extraImportPath.arg(QGuiApplication::applicationDirPath(),
                                      QString::fromLatin1("qml")));
    QObject::connect(viewer.engine(), &QQmlEngine::quit, &viewer, &QWindow::close);

    viewer.setTitle(QStringLiteral("BPhO 2023"));
    viewer.setSource(QUrl("qrc:/main.qml"));
    viewer.setResizeMode(QQuickView::SizeRootObjectToView);
    viewer.show();

    QQmlContext* rootContext = viewer.engine()->rootContext();

    rootContext->setContextProperty("platform", PLATFORM_NUM);

    rootContext->setContextProperty("planetData", planetData.data());
    rootContext->setContextProperty("orbits", orbits.data());
    rootContext->setContextProperty("angleIntegrator", angleIntegrator.data());
    rootContext->setContextProperty("lineGenerator", lineGenerator.data());
    rootContext->setContextProperty("ptolemyOrbits", ptolemy.data());

    return app.exec();
}

