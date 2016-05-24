import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.3
import App 1.0

Window {
    visible: true

    AppManager {
        id: app
    }

    ColumnLayout {

        anchors.centerIn: parent

        Text {
            id: titleText
            horizontalAlignment: Text.AlignHCenter
            text: "nxsmidi_desktop"
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ComboBox {
            id: portSelector
            width: titleText.width
            anchors.horizontalCenter: parent.horizontalCenter

            onCurrentTextChanged: {
                if (currentText != "--") {
                    console.log("selected text = " + currentText);
                    app.selectPortText("asd");
                }
            }

            model: app.portNameList
        }
    }
}
