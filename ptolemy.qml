import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import QtCharts

Item {
    id: ptolemy
    width: (platform === 0) ? 640 : 800
    height: (platform === 0) ? 480 : 600

    property var planetPaths: [mercuryPath, venusPath, earthPath, marsPath, jupiterPath, saturnPath, uranusPath, neptunePath, plutoPath]
    property rect chartBounds: Qt.rect(-40, -40, 80, 80)
    property int currentPlanet: 2
    property int numSamples: 50

    function setPlanet(planet) {
        ptolemyOrbits.cacheOrbit(planet, numSamples, numOrbits.value)
        currentPlanet = planet

        if (plotPlanet.currentIndex < 4)
            chart.title = `Inner solar system relative to ${plotPlanet.currentText}`
        else
            chart.title = `Outer solar system relative to ${plotPlanet.currentText}`

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

        ColumnLayout {
            Text {
                text: "Plot Graph for:"
            }
            ComboBox {
                id: plotPlanet
                textRole: "text"
                valueRole: "value"
                currentIndex: 2
                model: [
                     {text: "Mercury", value: 0},
                     {text: "Venus", value: 1},
                     {text: "Earth", value: 2},
                     {text: "Mars", value: 3},
                     {text: "Jupiter", value: 4},
                     {text: "Saturn", value: 5},
                     {text: "Uranus", value: 6},
                     {text: "Neptune", value: 7},
                     {text: "Pluto", value: 8},
                ]
            }
        }

        ColumnLayout {
            Text {
                text: "Number of Orbits:"
            }
            SpinBox {
                id: numOrbits
                from: 1
                to: 20
                value: 5
            }
        }

        Button {
            text: "Plot Graph"
            onClicked: setPlanet(plotPlanet.currentValue)
        }

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

        function plotGraph() {
            let start, end
            let newBound = 0
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
                let data = ptolemyOrbits.getOrbit(i, numSamples, true)
                planetPaths[i].clear()

                if (i == currentPlanet) { continue }

                for (let j = 0; j < data.length; j++) {
                    planetPaths[i].append(data[j].x, data[j].y)
                    if (Math.abs(data[j].x) > newBound) {
                        newBound = Math.abs(data[j].x)
                    }
                    if (Math.abs(data[j].y) > newBound) {
                        newBound = Math.abs(data[j].y)
                    }
                }
            }

            let sunData = ptolemyOrbits.getOrbit(9, numSamples, true)
            sunPath.clear()
            for (let i = 0; i < sunData.length; i++) {
                sunPath.append(sunData[i].x, sunData[i].y)
                if (Math.abs(sunData[i].x) > newBound) {
                    newBound = Math.abs(sunData[i].x)
                }
                if (Math.abs(sunData[i].y) > newBound) {
                    newBound = Math.abs(sunData[i].y)
                }
            }
            newBound *= 1.1
            chartBounds = Qt.rect(-newBound, -newBound, newBound * 2, newBound * 2)
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
            color: "#000000"
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
        sunPath.color = "black"
    }
}
