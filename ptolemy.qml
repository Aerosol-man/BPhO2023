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

    Button {
        x: 15
        y: parent.height - 30
        text: "Close"
        onClicked: ptolemy.parent.closePage()
    }
}
