import QtQuick 2.15
import QtCharts
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: solarSystem2d
    width: (platform === 0) ? 640 : 800
    height: (platform === 0) ? 480 : 600
    anchors.centerIn: parent

    signal close

    property var planetPaths: [mercuryPath, venusPath, earthPath, marsPath, jupiterPath, saturnPath, uranusPath, neptunePath, plutoPath]
    property rect chartBounds: Qt.rect(-2.2, -2.2, 4.4, 4.4)
    property var maxBounds: []
    property var animationProgress: [0, 0, 0, 0, 0, 0, 0, 0, 0]
    property real animationSpeed: 0.01

    function innerPlanetsVisible(visible) {
        for(let i = 0; i < 4; i++) {
            planetPaths[i].visible = visible
        }
        for (let i = 4; i < 9; i++) {
            planetPaths[i].visible = !visible
        }
    }

    function setPlanetView(view) {
        let bounds;
        if (view === "inner") {
            innerPlanetsVisible(true)
            bounds = maxBounds[3].x
        }
        else if (view === "outer") {
            innerPlanetsVisible(false)
            bounds = maxBounds[8].x
        }
        chartBounds = Qt.rect(bounds * -1.1, bounds * -1.1, bounds * 2.2, bounds * 2.2)
        canvas.requestPaint()
    }

    function drawPlanet(ctx, index, progress) {
        let position = orbits.displacementAt(Math.PI * 2 * progress, index)

        position.x *= chart.plotArea.width / (2 * chartBounds.right);
        position.x += chart.plotArea.width / 2
        position.y *= chart.plotArea.height / (2 * chartBounds.bottom);
        position.y += chart.plotArea.height / 2

        ctx.beginPath()
        ctx.arc(position.x, position.y, 7.5, 0, Math.PI * 2)
        ctx.fill()
    }

    function changeAnimationSpeed(amount) {
        animationSpeed *= amount
        animationSpeed = Math.min(Math.max(animationSpeed, 0.005), 2)
        speedText.text =  "Animation speed: \n 1 second =\n" + (animationSpeed / (timer.interval * 10 ** -3)).toPrecision(3) + " Earth Years"
    }

    onChartBoundsChanged: {
        xAxis.min = chartBounds.x
        xAxis.max = chartBounds.x + chartBounds.width

        yAxis.min = chartBounds.y
        yAxis.max = chartBounds.y + chartBounds.height
    }

    Timer {
        id: timer
        interval: 32; repeat: true; running: true
        onTriggered: {
            for (let i = 0; i < 9; i++) {
                animationProgress[i] += animationSpeed / planetData.orbitalPeriods[i]
                animationProgress[i] -= Math.floor(animationProgress[i])
            }

            canvas.requestPaint()
        }
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
                text: "View planets:"
            }
            RadioButton {
                id: innerPlanetButton
                text: "Inner planets"
                checked: true
                onCheckedChanged: {
                    if (checked) {
                        setPlanetView("inner")
                    }
                }
            }
            RadioButton {
                id: outerPlanetButton
                text: "Outer planets"
                onCheckedChanged: {
                    if (checked) {
                        setPlanetView("outer")
                    }
                }
            }
        }

        CheckBox {
            text: "Animation \nvisible"
            checked: canvas.animationRunning
            onCheckedChanged: {
                canvas.animationRunning = checked
            }
        }

        ColumnLayout {
            Text {
                id: speedText
                text: "Animation speed:"
            }

            RowLayout {
                spacing: 10
                Button {
                    text: "<<"
                    Layout.alignment: Qt.AlignLeft
                    Layout.fillWidth: true
                    onClicked: changeAnimationSpeed(0.75)
                }
                Button {
                    text: ">>"
                    Layout.alignment: Qt.AlignRight
                    Layout.fillWidth: true
                    onClicked: changeAnimationSpeed(1.25)
                }
            }
        }

        Button {
            text: "Close"
            onClicked: solarSystem2d.parent.closePage()
        }
    }

    ChartView {
        id: chart
        title: "2D Planet Orbits"
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

    Canvas {
        id: canvas

        property var planetColours: []
        property bool animationRunning: false

        x: chart.plotArea.x + chart.x
        y: chart.plotArea.y + chart.y
        width: chart.plotArea.width
        height: chart.plotArea.height

        onPaint: {
            if (!animationRunning) { return; }

            let ctx = getContext("2d");

            ctx.clearRect(0, 0, chart.plotArea.width, chart.plotArea.width)
            let start;
            let end;
            if (innerPlanetButton.checked) {
                start = 0
                end = 4
            }
            else {
                start = 4
                end = 9
            }
            for (let i = start; i < end; i++) {
                ctx.fillStyle = planetColours[i]
                drawPlanet(ctx, i, animationProgress[i])
            }
        }

        onAnimationRunningChanged: {
            visible = animationRunning
        }
    }

    Component.onCompleted: {
        for (let i = 0; i < 9; i++) {
            let path = orbits.getOrbit(i, 100, true)
            maxBounds.push(orbits.getMaxDisplacement(i))
            canvas.planetColours.push(planetPaths[i].color)

            for (let j = 0; j < path.length; j++) {
                //if (path[j].x !== 0.0 || (path[j].y !== 0.0 && path[j].x !== 0.0) || path[j].x !== Infinity || path[j].x !== -Infinity)
                    planetPaths[i].append(path[j].x, path[j].y)
            }
        }
        setPlanetView("inner")
        canvas.animationRunning = true
        changeAnimationSpeed(1)
    }
}
