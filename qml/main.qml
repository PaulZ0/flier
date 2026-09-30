import QtQuick
import QtQuick.Window

Window {
    id: root

    width: 1100
    height: 700
    minimumWidth: 700
    minimumHeight: 400

    visible: true
    title: "explorer"

    color: "#111315"

    property color background_color: "#111315"
    property color panel_color: "#181b1f"
    property color row_hover_color: "#22262b"
    property color border_color: "#30343a"
    property color text_color: "#e8e8e8"
    property color secondary_text_color: "#9a9fa6"
    property color accent_color: "#4c8dff"

    Rectangle {
        id: toolbar

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: 54

        color: root.panel_color

        Rectangle {
            id: up_button

            width: 38
            height: 34

            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            radius: 5

            color: up_mouse.containsMouse
                ? root.row_hover_color
                : "transparent"

            Text {
                anchors.centerIn: parent

                text: "↑"

                color: root.text_color
                font.pixelSize: 20
            }

            MouseArea {
                id: up_mouse

                anchors.fill: parent

                hoverEnabled: true

                onClicked: {
                    file_model.go_up()
                }
            }
        }

        Rectangle {
            id: path_box

            anchors.left: up_button.right
            anchors.leftMargin: 8

            anchors.right: parent.right
            anchors.rightMargin: 10

            anchors.verticalCenter: parent.verticalCenter

            height: 34

            radius: 5

            color: root.background_color

            border.width: path_input.activeFocus ? 1 : 0
            border.color: root.accent_color

            TextInput {
                id: path_input

                anchors.fill: parent

                leftPadding: 10
                rightPadding: 10

                verticalAlignment: TextInput.AlignVCenter

                text: file_model.current_path

                color: root.text_color
                selectionColor: root.accent_color

                font.pixelSize: 14

                clip: true

                onAccepted: {
                    if (!file_model.set_path(text)) {
                        text = file_model.current_path
                    }

                    focus = false
                }

                Connections {
                    target: file_model

                    function onCurrent_path_changed() {
                        path_input.text = file_model.current_path
                    }
                }
            }
        }
    }

    Rectangle {
        id: column_header

        anchors.top: toolbar.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        height: 32

        color: root.background_color

        border.color: root.border_color
        border.width: 1

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 48
            anchors.verticalCenter: parent.verticalCenter

            width: parent.width * 0.55

            text: "Name"

            color: root.secondary_text_color
            font.pixelSize: 12
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.60
            anchors.verticalCenter: parent.verticalCenter

            width: parent.width * 0.18

            text: "Size"

            color: root.secondary_text_color
            font.pixelSize: 12
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.78
            anchors.verticalCenter: parent.verticalCenter

            text: "Modified"

            color: root.secondary_text_color
            font.pixelSize: 12
        }
    }

    ListView {
        id: file_list

        anchors.top: column_header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: status_bar.top

        clip: true

        model: file_model

        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
            id: row

            required property string name
            required property string path
            required property bool is_dir
            required property string size
            required property string modified

            width: file_list.width
            height: 40

            color: row_mouse.containsMouse
                ? root.row_hover_color
                : "transparent"

            Rectangle {
                width: 18
                height: 18

                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter

                radius: row.is_dir ? 3 : 1

                color: row.is_dir
                    ? "#d0a650"
                    : "#737a83"
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 48
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width * 0.50

                text: row.name

                color: root.text_color

                font.pixelSize: 14

                elide: Text.ElideRight
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.60
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width * 0.17

                text: row.size

                color: root.secondary_text_color

                font.pixelSize: 13

                elide: Text.ElideRight
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.78
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width * 0.20

                text: row.modified

                color: root.secondary_text_color

                font.pixelSize: 13

                elide: Text.ElideRight
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                height: 1

                color: "#1d2024"
            }

            MouseArea {
                id: row_mouse

                anchors.fill: parent

                hoverEnabled: true

                acceptedButtons: Qt.LeftButton

                onDoubleClicked: {
                    if (row.is_dir) {
                        file_model.open_path(row.path)
                    }
                }
            }
        }
    }

    Rectangle {
        id: status_bar

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 26

        color: root.panel_color

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            text: file_model.error_message

            color: "#e26a6a"

            font.pixelSize: 12

            visible: text.length > 0
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            text: file_list.count + " items"

            color: root.secondary_text_color

            font.pixelSize: 12
        }
    }
}