import QtQuick 2.15
import QtCharts
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: simpson
    width: (platform === 0) ? 640 : 800
    height: (platform === 0) ? 480 : 600
    anchors.centerIn: parent

    signal close

    property rect chartBounds: Qt.rect(0, 0, 300, 10)
    property bool canPlot: false

    function plotGraph(index, periods=1) {
        let data;

        if (index !== -1) {
            data = angleIntegrator.fromPlanet(index, periods)
            updateSliders(index)
        }
        else {
            data = angleIntegrator.fromValues(periodSlider.value, eccSlider.value, periods)
        }

        spline.clear()
        for (let i = 0; i < data.length; i++) {
            spline.append(data[i].x, data[i].y)
        }

        data = angleIntegrator.fromValues(periodSlider.value, 0, periods)
        line.clear()
        for (let i = 0; i < data.length; i++) {
            line.append(data[i].x, data[i].y)
        }

        chartBounds = Qt.rect(0, 0, data[data.length - 1].x, Math.PI * 2 * periods)
        canPlot = true
    }

    function updateSliders(index) {
        if (!(planetData.orbitalPeriods[index])) { return }
        periodSlider.value = planetData.orbitalPeriods[index]
        eccSlider.value = planetData.eccentricities[index]
    }

    onChartBoundsChanged: {
        xAxis.min = chartBounds.x
        xAxis.max = chartBounds.x + chartBounds.width

        yAxis.min = chartBounds.y
        yAxis.max = chartBounds.y + chartBounds.height
    }

    Timer {
        id: plotTimer
        interval: 1000
        repeat: false
        running: false

        onTriggered: {
            plotButton.enabled = true
        }
    }

    ColumnLayout {
        id: controlPanel
        width: 200
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 10

        RowLayout {
            Text {
                text: "Plot Graph for:"
            }
            ComboBox {
                id: plotType
                textRole: "text"
                valueRole: "value"
                currentIndex: 8
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
                     {text: "Custom", value: -1}
                ]
                onCurrentTextChanged: { // The Combobox's text is updated after its current index
                    if (currentIndex !== 9) {
                        chart.title = `Orbit angle vs time for ${currentText}`
                        updateSliders(currentIndex)
                    }
                    else
                        chart.title = "Orbit angle vs time"
                }

                onCurrentValueChanged: plotGraph(currentValue, numPeriods.value)
            }
        }

        Text {
            text: "Eccentricity:"
            Layout.alignment: Qt.AlignHCenter
        }
        Slider {
            id: eccSlider
            from: 0
            to: 0.9
            stepSize: 0.05
            Layout.fillWidth: true
            onValueChanged: {
                eccLabel.text = value.toPrecision(3)
                plotGraph(plotType.currentValue, numPeriods.value)
            }
            onMoved: plotType.currentIndex = 9

        }
        Text {
            id: eccLabel
            text: eccSlider.value.toPrecision(3)
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "Orbital Period:"
            Layout.alignment: Qt.AlignHCenter

        }
        Slider {
            id: periodSlider
            from: 0.1
            to: 300
            Layout.fillWidth: true
            onValueChanged: {
                periodLabel.text = value.toPrecision(3)
                plotGraph(plotType.currentValue, numPeriods.value)
            }
            onMoved: plotType.currentIndex = 9

        }
        Text {
            id: periodLabel
            text: periodSlider.value.toPrecision(3)
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            Text {
                text: "Number of Orbits:"
            }
            SpinBox {
                id: numPeriods
                from: 1
                to: 10
                value: 5

                onValueChanged: plotGraph(plotType.currentValue, value)
            }
        }

//        Button {
//            id: plotButton
//            text: "Plot Graph"
//            onClicked: {
//                // Avoid sending too many requests to the C++ backend
//                //if (plotTimer.running && canPlot) { return }

//                // This crashes sometimes. I don't know why.
//                plotGraph(plotType.currentValue, numPeriods.value)

//                //plotButton.enabled = false
//                plotTimer.start()
//                canPlot = false
//            }
//        }

        Button {
            text: "Close"
            onClicked: simpson.parent.closePage()
        }
    }

    ChartView {
        id: chart
        title: "Orbit angle vs time for Pluto"
        anchors.left: controlPanel.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        legend.visible: true
        antialiasing: false

        ValuesAxis {
            id: xAxis
            titleText: "Time in years"
            min: chartBounds.x
            max: chartBounds.x + chartBounds.width
        }

        ValuesAxis {
            id: yAxis
            titleText: "Orbit angle in radians"
            min: chartBounds.y
            max: chartBounds.y + chartBounds.height
        }

        SplineSeries {
            id: line
            axisX: xAxis; axisY: yAxis
            name: "e = 0"
        }

        SplineSeries {
            id: spline
            axisX: xAxis; axisY: yAxis
            name: "e = 0.244"
        }
    }

    Component.onCompleted: {
        plotGraph(8, 1)
    }
}
