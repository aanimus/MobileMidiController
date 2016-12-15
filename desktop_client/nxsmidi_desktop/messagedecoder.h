#ifndef MESSAGEDECODER_H
#define MESSAGEDECODER_H

#include <QObject>
#include <QTcpServer>
#include <QTcpSocket>
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
    void acceptNewConnections();
    void readTcpMessage();
private:

    enum DataMode {
        WaitingForSize,
        Reading
    };
    
    void processData(unsigned char data);
    void prepare_to_process();

    std::function<void(MidiMessage)> processMidiMessage;

    QTcpServer *m_tcp_server;
    QTcpSocket *m_socket;

    std::vector<unsigned char> m_bytes_so_far;
    DataMode m_data_mode;
    uint8_t m_remaining_bytes;
};

#endif // MESSAGEDECODER_H
