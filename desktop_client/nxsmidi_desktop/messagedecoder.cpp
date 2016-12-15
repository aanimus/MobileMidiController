#include <iostream>
#include "messagedecoder.h"

MessageDecoder::MessageDecoder(QObject *parent) : QObject(parent),
    m_tcp_server(new QTcpServer(this)),
    m_data_mode(WaitingForSize),
    m_socket(nullptr)
{
    m_tcp_server->listen(QHostAddress::Any, 6000);
    connect(m_tcp_server, &QTcpServer::newConnection,
            this, &MessageDecoder::acceptNewConnections);
}

void MessageDecoder::acceptNewConnections() {
    if ( m_tcp_server->hasPendingConnections() &&
         m_socket == nullptr)
    {
        m_socket = m_tcp_server->nextPendingConnection();
        connect(m_socket, &QTcpSocket::readyRead,
                this, &MessageDecoder::readTcpMessage);
    }
}

void MessageDecoder::readTcpMessage()
{
    while (m_socket->bytesAvailable()) {
        int num_bytes = m_socket->bytesAvailable();
        std::vector<unsigned char> bytes(num_bytes);
        m_socket->read((char *)bytes.data(), num_bytes);
        for (unsigned char c : bytes) {
            processData(c);
        }
    }
}

void MessageDecoder::processData(unsigned char data)
{
    switch (m_data_mode) {
    case WaitingForSize:
        m_remaining_bytes = data;
        m_data_mode = Reading;
        break;
    case Reading:
        m_bytes_so_far.push_back(data);
        m_remaining_bytes--;
        if (m_remaining_bytes == 0) {
            m_data_mode = WaitingForSize;
            prepare_to_process();
            m_bytes_so_far = std::vector<unsigned char>();
        }
        break;
    }
}

void MessageDecoder::prepare_to_process()
{
    //only supports midi messages now
    MidiMessage msg = MidiMessage(0,0);
    if (m_bytes_so_far.size() == 4) {
        msg = MidiMessage(m_bytes_so_far[1],
                m_bytes_so_far[2],
                m_bytes_so_far[3]);
    } else { // 3
        msg = MidiMessage(m_bytes_so_far[1],
                    m_bytes_so_far[2]);
    }

    std::cout << "asdfsadF" << std::endl;
    processMidiMessage(msg);
}

void MessageDecoder::setProcessMidiMessage(std::function<void(MidiMessage)> f) {
    processMidiMessage = f;
}
