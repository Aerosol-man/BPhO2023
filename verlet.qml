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
            simulator.addBody(100000, Qt.vector2d(0, 0))
            let n = 19
            for (let i = 0; i < n; i++) {
                let theta = Math.PI * 2 * Math.random()
                simulator.addBody(1 + Math.random() * 180, Qt.vector2d(Math.cos(theta) * Math.max(Math.random(), 0.3), Math.sin(theta) * Math.max(Math.random(), 0.3)))
            }
            label = false
            chart.title = "Random Bodies"
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
            chart.title = "Solar System Verlet Model"
        }
        else {
            let system = exosystems.getSystem(idx - 1)
            for (let i = 0; i < system.length; i++) {
                let theta = Math.PI * 2 * i / system.length
                let d = system[i].distance
                if (system[i].static) {
                    simulator.addBody(system[i].mass, Qt.vector2d(d * Math.sin(theta), d * Math.cos(theta)), Qt.vector2d(0, 0))
                }
                else
                    simulator.addBody(system[i].mass, Qt.vector2d(d * Math.cos(theta), d * Math.sin(theta)))

                labels.push(system[i].name)
            }
            label = true
            chart.title = `${exosystems.systems[idx - 1].name} Verlet Model`
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
        property real solarMass: 333030

        property var systems: [
            {
                name: "47 UMa",
                bodies: [
                    {name: "47 Ursa Majoris", mass: solarMass * 1.08, distance: 0},
                    {name: "47 UMa b", mass: 774.9, distance: 2.059},
                    {name: "47 UMa d", mass: 480, distance: 13.8},
                    {name: "47 UMa c", mass: 158, distance: 3.404}
                ]
            },
//            {
//                name: "CNC 55",
//                bodies: [
//                    {name: "CNC 55 A", mass: solarMass * 0.905, distance: 0},
//                    {name: "CNC 55 B", mass: solarMass * 0.264, distance: 34782.48},
//                    {name: "CNC 55 d", mass: 909, distance: 5.54},
//                    {name: "CNC 55 b", mass: 267, distance: 0.1162},
//                    {name: "CNC 55 c", mass: 54.35, distance: 0.2432},
//                    {name: "CNC 55 f", mass: 46.88, distance: 0792},
//                    {name: "CNC 55 e", mass: 7.99, distance: 0.01544}
//                ],
//            },
//            {
//                name: "61 Vir",
//                bodies: [
//                    {name: "61 Virginis", mass: solarMass * 0.93, distance: 0, static: true},
//                    {name: "61 Vir b", mass: 5.1, distance: 0.050201},
//                    {name: "61 Vir d", mass: 22.9, distance: 0.476},
//                    {name: "61 Vir c", mass: 18.2, distance: 0.2175},
//                ],
//            },
            {
                name: "HD 107148",
                bodies: [
                    {name: "HD 107148", mass: solarMass * 1.1, distance: 0},
                    {name: "HD 107148 b", mass: 66.741, distance: 0.269},
                    {name: "HD 107148 c", mass: 19.9, distance: 0.1407},
//                    {name: "HD 107148 B", mass: solarMass * 0.6, distance: 1790},
                ],
            },
//            {
//                name: "Kepler-47",
//                bodies: [
//                    {name: "Kepler-47B", mass: solarMass * 0.342, distance: 0},
//                    {name: "Kepler-47 d", mass: 19.02, distance: 0.9638},
//                    {name: "Kepler-47 c", mass: 3.17, distance: 0.9638},
//                    {name: "Kepler-47 b", mass: 2.07, distance: 0.2877},
//                    {name: "Kepler-47A", mass: solarMass * 0.957, distance: 0.08145},
//                ]
//            },
//            {
//                name: "HD 160691",
//                bodies: [
//                    { name: 'HD160691', mass: solarMass * 1.1, distance: 0, static: true},
//                    { name: 'HD160691 c', mass: 990, distance: 4.17 },
//                    { name: 'HD160691 b', mass: 531, distance: 1.5 },
//                    { name: 'HD160691 d', mass: 14, distance: 0.09 },
//                    { name: 'HD160691 e', mass: 166, distance: 0.921 },
//                ],
//            },
//            {
//                name: "Castor C",
//                bodies: [
//                    { name: 'Castor Ca', mass: solarMass * 0.5992, distance: 0 },
//                    { name: 'Castor Cb', mass: solarMass * 0.5992, distance: 0.018 }
//                ]
//            },
            {
                name: "OGLE-06-109L",
                bodies: [
                    { name: 'OGLE-06-109L', mass: solarMass * 0.51, distance: 0 },
                    { name: 'OGLE-06-109L b', mass: 230, distance: 2.3 },
                    { name: 'OGLE-06-109L c', mass: 86, distance: 4.6 },
                ]
            },
            {
                name: "11 Com",
                bodies: [
                    { name: '11 Comae Berenices', mass: solarMass * 1.66, distance: 0 },
                    { name: '11 Com B b', mass: 6167.3958, distance: 1.29 },
                ]
            },
        ]

        function getSystem(i) {
            return systems[i].bodies
        }
    }

    ColumnLayout {
        id: controlPanel
        width: 200
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 10

        ColumnLayout {
            Label { text: "Choose System"; font.pointSize: 10 }
            ComboBox {
                id: sceneNum
                textRole: "key"
                valueRole: "value"
                currentIndex: 0
                font.pointSize: 10
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
        }

        Button {
            text: "Load Preset"
            font.pointSize: 10
            onClicked: {
                loadScene(sceneNum.currentValue)
            }
        }

        Button {
            text: "Close"
            onClicked: {
                verlet.parent.closePage()
            }
        }
    }

    Timer {
        id: timer
        interval: 32; repeat: true; running: true
        onTriggered: {
            simulator.updatePositions(0.05, 15)
            canvas.requestPaint()
        }
    }

    ChartView {
        id: chart
        title: "Random Bodies"
        anchors.left: controlPanel.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        legend.visible: false
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

            let masses
            if (!label)
                masses = simulator.getMasses()

            for (let i = 0; i < positions.length; i++) {
                ctx.fillStyle = getColour(i)
                if (label)
                    ctx.fillText(`${labels[i]}: (${positions[i].x.toFixed(2)}, ${positions[i].y.toFixed(2)})`, 10, 20 + i * 20)
                else {
                    ctx.fillText(`m = ${masses[i].toExponential(2)}`, 10, 20 + i * 20)
                }
                posMax = Math.max(posMax, Math.abs(positions[i].x), Math.abs(positions[i].y))
                drawBody(ctx, positions[i])
            }

            if (posMax > plotSize.x) {
                plotSize = Qt.vector2d(posMax, posMax)
            }
        }
    }

    Component.onCompleted: {
        loadScene(-1)

        for (let i = 0; i < exosystems.systems.length; i++) {
            sceneModel.append({"key": exosystems.systems[i].name, "value": sceneNum.valueAt(sceneModel.count - 1) + 1})
        }
    }
}
