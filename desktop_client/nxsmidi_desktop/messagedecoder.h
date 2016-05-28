#ifndef MESSAGEDECODER_H
#define MESSAGEDECODER_H

#include <QObject>
#include <QUdpSocket>
#include <QHostAddress>
#include <functional>
#include <vector>

#include "message.h"

class MessageDecoder : public QObject
{
    Q_OBJECT
public:
    explicit MessageDecoder(QObject *parent = 0);
    void setProcessMidiMessage(std::function<void(MidiMessage)> f);
private slots:
    void readDatagrams();
private:
    enum DataStatusMode {
        NotReading,
        WaitingForF,
        WaitingForMessageType,
        ReadingMidiStatus,
        ReadingMidiData
    };
    DataStatusMode readingStatus = NotReading;
    int bytesRemaining;
    MidiMessage msg;
    
    void processData(unsigned char data);
    std::function<void(MidiMessage)> processMidiMessage;
    
    QUdpSocket *udpSocket;
};

#endif // MESSAGEDECODER_H
