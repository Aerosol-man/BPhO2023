import QtQuick
//import QtQuick.Window 2.15
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

    Item {
        id: mainMenu
        width: 320
        height: 320
        anchors.centerIn: parent

        Grid {
            columns: 3
            spacing: 2

            Button {
                text: "Kepler Graph"
                onClicked: openPage("kepler.qml")
            }

            Button {
                text: "2D Solar system"
                onClicked: openPage("solarsystem2d.qml")
            }

            Button {
                text: "Simpson's rule"
                onClicked: openPage("simpson.qml")
            }
            Button {
                text: "3D Solar system"
                onClicked: openPage("solarsystem3d.qml")
            }
            Button {
                text: "Spirograph"
                onClicked: openPage("spirograph.qml")
            }
            Button {
                text: "Ptolemy"
                onClicked: openPage("ptolemy.qml")
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

