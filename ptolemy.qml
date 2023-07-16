import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import QtCharts

Item {
    id: ptolemy
    width: 640
    height: 480

    property var planetPaths: [mercuryPath, venusPath, earthPath, marsPath, jupiterPath, saturnPath, uranusPath, neptunePath, plutoPath]
    property rect chartBounds: Qt.rect(-40, -40, 80, 80)
    property int currentPlanet: 2

    function setPlanet(planet) {
        ptolemyOrbits.cacheOrbit(planet, 100, 5)
        currentPlanet = planet

        if (currentPlanet < 4)
            chartBounds = Qt.rect(-2.2, -2.2, 4.4, 4.4)
        else
            chartBounds = Qt.rect(-40, -40, 80, 80)

        chart.plotGraph()
    }

    onChartBoundsChanged: {
        xAxis.min = chartBounds.x
        xAxis.max = chartBounds.x + chartBounds.width

        yAxis.min = chartBounds.y
        yAxis.max = chartBounds.y + chartBounds.height
    }

    ColumnLayout {
        id: controlPanel
        width: 100
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 10

        Button {
            text: "Close"
            onClicked: ptolemy.parent.closePage()
        }
    }

    ChartView {
        id: chart
        title: "Ptolemaic orbital model centered on Earth"
        anchors.left: controlPanel.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 640
        height: 480
        legend.visible: true
        antialiasing: false

        function plotGraph() {
            let start, end
            if (currentPlanet < 4) {
                for (let i = 0; i < 4; i++) {
                    planetPaths[i].visible = true
                }
                for (let i = 4; i < 9; i++) {
                    planetPaths[i].visible = false
                }
                start = 0
                end = 4
            }
            else {
                for (let i = 0; i < 4; i++) {
                    planetPaths[i].visible = false
                }
                for (let i = 4; i < 9; i++) {
                    planetPaths[i].visible = true
                }
                start = 4
                end = 9
            }


            for (let i = start; i < end; i++) {
                let data = ptolemyOrbits.getOrbit(i)
                planetPaths[i].clear()

                for (let j = 0; j < data.length; j++) {
                    planetPaths[i].append(data[j].x, data[j].y)
                }
            }

            let sunData = ptolemyOrbits.getOrbit(9)
            sunPath.clear()
            for (let i = 0; i < sunData.length; i++) {
                sunPath.append(sunData[i].x, sunData[i].y)
            }
        }

        ValuesAxis {
            id: xAxis
            titleText: "x (Astronomical Units)"
            min: chartBounds.x
            max: chartBounds.x + chartBounds.width
        }

        ValuesAxis {
            id: yAxis
            titleText: "y (Astronomical Units)"
            min: chartBounds.y
            max: chartBounds.y + chartBounds.height
        }

        SplineSeries {
            id: sunPath
            name: "sun"
            axisX: xAxis
            axisY: yAxis
        }
        SplineSeries {
            id: mercuryPath
            name: "mercury"
            axisX: xAxis
            axisY: yAxis
        }
        SplineSeries {
            id: venusPath
            name: "venus"
            axisX: xAxis
            axisY: yAxis
        }
        SplineSeries {
            id: earthPath
            name: "earth"
            axisX: xAxis
            axisY: yAxis
        }
        SplineSeries {
            id: marsPath
            name: "mars"
            axisX: xAxis
            axisY: yAxis
        }
        SplineSeries {
            id: jupiterPath
            name: "jupiter"
            axisX: xAxis
            axisY: yAxis
        }
        SplineSeries {
            id: saturnPath
            name: "saturn"
            axisX: xAxis
            axisY: yAxis
        }
        SplineSeries {
            id: uranusPath
            name: "uranus"
            axisX: xAxis
            axisY: yAxis
        }
        SplineSeries {
            id: neptunePath
            name: "neptune"
            axisX: xAxis
            axisY: yAxis
        }
        SplineSeries {
            id: plutoPath
            name: "pluto"
            axisX: xAxis
            axisY: yAxis
        }
    }

    Component.onCompleted: {
        setPlanet(2)
    }
}
