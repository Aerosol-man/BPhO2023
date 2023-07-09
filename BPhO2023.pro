QT += quick charts gui
CONFIG += qmltypes

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

INCLUDEPATH += "C:/Users/ademo/cpp/xtensor-0.24.4/include" "C:/Users/ademo/cpp/xtl-0.7.5/include" "C:/Users/ademo/cpp/xtensor-0.24.4/build"

SOURCES += \
        angleintegrator.cpp \
        main.cpp \
        orbits.cpp \
        planetdata.cpp \
        simulator.cpp
HEADERS += \
    angleintegrator.h \
    math.h \
    orbits.h \
    planetdata.h \
    simulator.h \
    xtensor.hpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
# QML_IMPORT_PATH += $PWD
QML_IMPORT_NAME = com.aerosolm.keplergraph
QML_IMPORT_MAJOR_VERSION = 1

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES +=
