import QtQuick 2.15
import QtCharts
import QtQuick.Controls
import QtQuick.Layouts

Item {
    width:640
    height: 480
    anchors.centerIn: parent
    //anchors.fill: parent

    function plotData(rel){
        let numPoints = 50;

        scatterData.clear();
        lineData.clear();

        if (rel === 0) {
            for (let i = 0; i < 9; i++) {
                scatterData.append(planetData.distances[i] ** 1.5, planetData.orbitalPeriods[i]);
            }
            for (let i = 0; i < numPoints; i++) {
                lineData.append(i * 260 / 50, i * 260 / 50);
            }
            xAxis.max = 260;
            xAxis.titleText = "(Semi-major axis)^1.5 in AU";
        }
        else {
            for (let i = 0; i < 9; i++) {
                scatterData.append(planetData.distances[i], planetData.orbitalPeriods[i]);
            }
            for (let i = 0; i < numPoints; i++) {
                lineData.append(i * 260 / 50, (i * 260 / 50) ** 1.5);
            }
            xAxis.max = 40;
            xAxis.titleText = "Semi-major axis in AU";
        }
    }

    ColumnLayout { id: controlPanel
        width: 100
        anchors.left: parent.left
        anchors.top: parent.top
        //anchors.bottom: parent.bottom
        anchors.margins: 10

        spacing: 5

        Text { text: "Graph Type:" }
        RadioButton {
            checked: true
            text: "Linear"
            onCheckedChanged: {
                if (checked) {
                    plotData(0)
                }
            }
        }
        RadioButton {
            text: "Polynomial"
            onCheckedChanged: {
                if (checked) {
                    plotData(1)
                }
            }
        }
    }
    Flickable {
        anchors.left: controlPanel.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        ChartView {
            id: chart
            title: "Verifying Kepler's Third Law"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            //legend.visible: false
            antialiasing: false

            ValuesAxis {
                id: xAxis
                titleText: "(Semi-major axis)^1.5 in AU"
                min: 0
                max: 260
            }

            ValuesAxis {
                id: yAxis
                titleText: "Orbital period in Years"
                min: 0
                max: 250
            }

            LineSeries {
                id: lineData
                name: "y = x"
                axisX: xAxis
                axisY: yAxis
            }

            ScatterSeries {
                id: scatterData
                name: "Planet data"
                axisX: xAxis
                axisY: yAxis
                useOpenGL: false
                markerSize: 4
                markerShape: ScatterSeries.MarkerShapeRectangle
                color: "#FF000000"
                borderColor: "#00FFFFFF"
                visible: true
            }
        }

        Canvas {
            id: canvas

            x: chart.plotArea.x + chart.x
            y: chart.plotArea.y + chart.y
            width: chart.plotArea.width
            height: chart.plotArea.height

            onPaint: {
                let ctx = getContext("2d");

                ctx.clearRect(0, 0, chart.plotArea.width, chart.plotArea.width)
            }
        }
    }

    Component.onCompleted: {
        plotData(0);
    }
}
