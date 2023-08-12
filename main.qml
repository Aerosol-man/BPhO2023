import QtQuick
//import QtQuick.Window 2.15
import QtQuick.Layouts
import QtQuick.Controls
import QtCharts

Item {
    width: 800
    height: 600
    visible: true
    //title: qsTr("Hello World")

    function openPage(url) {
        currentPage.visible = true
        mainMenu.visible = false
        currentPage.model.set(0, {component: url})
    }


    ColumnLayout {
        id: mainMenu
        anchors.fill: parent
        width: 800
        height: 600

        Label {
            id: title
            Layout.alignment: Qt.AlignHCenter
            //Layout.fillWidth: true
            text: "Solar System Model"
            font.pointSize: 32
        }

        Column {
//            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            leftPadding: 30
            spacing: 10

            Button {
                text: "Verifying Kepler's Third Law"
                onClicked: openPage("kepler.qml")
            }

            Button {
                text: "2D Solar System Animation"
                onClicked: openPage("solarsystem2d.qml")
            }
            Button {
                text: "3D Solar System Animation"
                onClicked: openPage("solarsystem3d.qml")
            }
            Button {
                text: "Calculating Orbit Angle vs Time"
                onClicked: openPage("simpson.qml")
            }
            Button {
                text: "Solar System Spirographs"
                onClicked: openPage("spirograph.qml")
            }
            Button {
                text: "Ptolemaic Orbits"
                onClicked: openPage("ptolemy.qml")
            }
            Button {
                text: "Gravity Simulator"
                onClicked: openPage("verlet.qml")
            }
        }
    }

    GridView {
        id: currentPage
        visible: false
        anchors.centerIn: parent
        anchors.fill: parent
        boundsMovement: Flickable.StopAtBounds

        model: ListModel {
            ListElement {component: "kepler.qml"}
        }

        delegate: Loader {
            id: pageLoader
            source: component
            asynchronous: true

            function closePage() {
                currentPage.visible = false
                mainMenu.visible = true
            }
        }
    }
}

