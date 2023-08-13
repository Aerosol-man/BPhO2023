import QtQuick 2.15
import QtCharts
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

Item {
    id: verlet
    width: 800
    height: 600

    property var plotSize: Qt.vector2d(4, 4)
//    property real scale: 0.5
    property bool label: false
    property var labels: []

    function fitToScreen(p) {
        let x = (p.x / plotSize.x) * canvas.width / 2
        x += chart.plotArea.width / 2
        let y = (p.y / plotSize.y) * canvas.height / 2
        y += chart.plotArea.height / 2

        return Qt.vector2d(x, y)
    }

    function lerp(a, b, t) {
        return a + (b - a) * t
    }

    function loadScene(idx) {
        simulator.reset()
        labels = []
        plotSize.x = 1; plotSize.y = 1

        if (idx === -1) {
            let n = 10
            for (let i = 0; i < n; i++) {
                let theta = Math.PI * 2 * Math.random()
                simulator.addBody(20 + Math.random() * 80, Qt.vector2d(1 + Math.cos(theta) * 0.2 * i, 1 + Math.sin(theta) * 0.2 * i))
            }
            label = false
        }
        else if (idx === 0) {
            simulator.addBody(333030, Qt.vector2d(0, 0))
            for (let i = 0; i < 9; i++) {
                let theta = Math.PI * 2 * i / 9
                let d = planetData.distances[i]
                simulator.addBody(planetData.masses[i], Qt.vector2d(d * Math.cos(theta), d * Math.sin(theta)))
            }
            labels = ['sun', 'mercury', 'venus', 'earth', 'mars', 'jupiter', 'saturn', 'uranus', 'neptune', 'pluto']
            label = true
        }
        else {
            let system = exosystems.getSystem(idx - 1)
            for (let i = 0; i < system.length; i++) {
                let theta = Math.PI * 2 * i / system.length
                let d = system[i].distance
                simulator.addBody(system[i].mass, Qt.vector2d(d * Math.cos(theta), d * Math.sin(theta)))
                labels.push(system[i].name)
            }
            label = true
        }
    }

    onPlotSizeChanged: {
        xAxis.min = plotSize.x * -1.2
        xAxis.max = plotSize.x * 1.2
        yAxis.min = plotSize.y * -1.2
        yAxis.max = plotSize.y * 1.2
    }

    Item {
        id: exosystems
        property var systemNames: ["47 UMa", "61 Vir", "HD 107148", "Kepler-47"]
        property real solarMass: 333030

        property var systems: [
            [
                {name: "47 Ursa Majoris", mass: solarMass * 1.08, distance: 0},
                {name: "47 UMa b", mass: 774.9, distance: 2.059},
                {name: "47 UMa d", mass: 480, distance: 13.8},
                {name: "47 UMa c", mass: 158, distance: 3.404}
            ],
//            [
//                {name: "CNC 55 A", mass: solarMass * 0.905, distance: 0},
//                {name: "CNC 55 B", mass: solarMass * 0.264, distance: 34782.48},
//                {name: "CNC 55 d", mass: 909, distance: 5.54},
//                {name: "CNC 55 b", mass: 267, distance: 0.1162},
//                {name: "CNC 55 c", mass: 54.35, distance: 0.2432},
//                {name: "CNC 55 f", mass: 46.88, distance: 0792},
//                {name: "CNC 55 e", mass: 7.99, distance: 0.01544}
//            ]
            [
                {name: "61 Virginis", mass: solarMass * 0.93, distance: 0},
                {name: "61 Vir d", mass: 22.9, distance: 0.476},
                {name: "61 Vir c", mass: 18.2, distance: 0.2175},
//                {name: "61 Vir b", mass: 5.1, distance: 0.050201}
            ],
            [
                {name: "HD 107148", mass: solarMass * 1.1, distance: 0},
                {name: "HD 107148 b", mass: 66.741, distance: 0.269},
                {name: "HD 107148 c", mass: 19.9, distance: 0.1407},
//                {name: "HD 107148 B", mass: solarMass * 0.6, distance: 1790},
            ],
            [
                {name: "Kepler-47B", mass: solarMass * 0.342, distance: 0},
                {name: "Kepler-47 d", mass: 19.02, distance: 0.9638},
                {name: "Kepler-47 c", mass: 3.17, distance: 0.9638},
                {name: "Kepler-47 b", mass: 2.07, distance: 0.2877},
                {name: "Kepler-47A", mass: solarMass * 0.957, distance: 0.08145},
            ]
        ]

        function getSystem(i) {
            return systems[i]
        }
    }

    ColumnLayout {
        id: controlPanel
        width: 200
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 10

        ComboBox {
            id: sceneNum
            textRole: "key"
            valueRole: "value"
            currentIndex: 0
            model: ListModel {
                id: sceneModel

                ListElement {
                    key: "Random"
                    value: -1
                }
                ListElement {
                    key: "Solar System"
                    value: 0
                }
            }
        }

        Button {
            text: "Load System"
            onClicked: {
                loadScene(sceneNum.currentValue)
            }
        }
    }

    Timer {
        id: timer
        interval: 32; repeat: true; running: true
        onTriggered: {
            simulator.updatePositions(0.1, 25)
            canvas.requestPaint()
        }
    }

    ChartView {
        id: chart
        title: "2D Planet Orbits"
        anchors.left: controlPanel.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        legend.visible: false
        width: 640
        height: 480
        antialiasing: false

        ValuesAxis {
            id: xAxis
            titleText: "x (Astronomical Units)"
            min: -plotSize.x
            max: plotSize.x
        }

        ValuesAxis {
            id: yAxis
            titleText: "y (Astronomical Units)"
            min: -plotSize.y
            max: plotSize.y
        }

        SplineSeries {
            id: path
            name: "path"
            axisX: xAxis
            axisY: yAxis
        }
    }

    Canvas
    {
        id: canvas
        x: chart.plotArea.x + chart.x
        y: chart.plotArea.y + chart.y
        width: chart.plotArea.width
        height: chart.plotArea.height


        property var drawMargins: Qt.vector2d(50, 30)

        function drawBody(ctx, position) {
            let pos = fitToScreen(position)

            ctx.beginPath()
            ctx.arc(pos.x, pos.y, 7.5, 0, Math.PI * 2)
            ctx.fill()
        }

        function getColour(i) {
            let h = ((1 + Math.sqrt(5)) / 2 * i ) % 1

            return Qt.hsva(h, 0.6, 0.95, 1)
        }

        onPaint: {
            let ctx = getContext("2d")

            ctx.clearRect(0, 0, width, height)

            let positions = simulator.getPositions()
            let posMax = 0

            ctx.fillStyle = "black"
            ctx.strokeStyle = "black"

//            ctx.beginPath()
//            ctx.moveTo(drawMargins.x / 2, drawMargins.y / 2)
//            ctx.lineTo(drawMargins.x / 2, height - drawMargins.y / 2)
//            ctx.lineTo(width - drawMargins.x / 2, height - drawMargins.y / 2)
//            ctx.stroke()

//            let n = 4
//            for (let p = 0; p <= n; p++) {
//                ctx.fillText(lerp(-plotSize.y, plotSize.y, p / n).toFixed(2), 0, lerp(drawMargins.y / 2, height - drawMargins.y / 2, p / n))
//                ctx.fillText(lerp(-plotSize.x, plotSize.x, p / n).toFixed(2), lerp(drawMargins.x / 2, width - drawMargins.x / 2, p / n), height - 5)
//            }

            for (let i = 0; i < positions.length; i++) {
                ctx.fillStyle = getColour(i)
                if (label)
                    ctx.fillText(`${labels[i]}: (${positions[i].x.toFixed(2)}, ${positions[i].y.toFixed(2)})`, drawMargins.x + 3, 20 + i * 20)
                else
                    ctx.fillText(`${i}: ${positions[i]}`, drawMargins.x + 3, 20 + i * 20)
                posMax = Math.max(posMax, Math.abs(positions[i].x), Math.abs(positions[i].y))
                drawBody(ctx, positions[i])
            }

            if (posMax > plotSize.x) {
                plotSize = Qt.vector2d(posMax, posMax)
            }
        }
    }

    Button {
        x: 20
        y: parent.height - 40
        text: "Close"
        onClicked: {
            verlet.parent.closePage()
        }
    }

    Component.onCompleted: {
        loadScene(-1)

        for (let i = 0; i < exosystems.systemNames.length; i++) {
            sceneModel.append({"key": exosystems.systemNames[i], "value": sceneNum.valueAt(sceneModel.count - 1) + 1})
        }
    }
}
