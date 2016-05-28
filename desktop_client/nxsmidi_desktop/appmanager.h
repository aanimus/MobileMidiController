#ifndef APPMANAGER_H
#define APPMANAGER_H

#include <QObject>
#include <QQmlListProperty>

#include "messagedecoder.h"
#include "midisystem.h"

//impl property
class AppManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList portNameList
               READ get_port_names
               NOTIFY port_names_did_change)
public:
    explicit AppManager(QObject *parent = 0);

    //QML INVOKABLES
    Q_INVOKABLE void selectPortText(QString str);

    QStringList get_port_names();

signals:
    void port_names_did_change();

private:
    MidiSystem m_midi_system;
    MessageDecoder *m_message_decoder;

};

#endif // APPMANAGER_H
