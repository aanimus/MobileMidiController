#include "appmanager.h"

AppManager::AppManager(QObject *parent) : QObject(parent)
{
    emit port_names_did_change();
    m_message_decoder = new MessageDecoder(this);
    m_message_decoder->setProcessMidiMessage([&](MidiMessage msg){
        m_midi_system.send_message(msg);
    });
}

QStringList AppManager::get_port_names() {
    auto map_of_ports = m_midi_system.map_of_ports();
    QStringList result;
    result.append("--");
    for (auto iter = map_of_ports.begin(); iter != map_of_ports.end(); iter++) {
        result.append(QString( (iter->first).c_str() ));
    }
    return result;
}

void AppManager::selectPortText(QString str) {
    m_midi_system.open_port(str.toStdString());
}
