#include <iostream>
#include "messagedecoder.h"

MessageDecoder::MessageDecoder(QObject *parent) : QObject(parent) ,
    msg(MidiMessage(0,0))
{
    udpSocket = new QUdpSocket(this);
    connect(udpSocket, SIGNAL(readyRead()),
            this, SLOT(readDatagrams()));
    if (udpSocket->bind(6000)) {
        qDebug("bind ok");
    }
}

void MessageDecoder::readDatagrams()
{
    qDebug("recieved datagrams");
    while (udpSocket->hasPendingDatagrams()) {
        std::vector<char> datagram;
        datagram.resize(udpSocket->pendingDatagramSize());
        udpSocket->readDatagram(datagram.data(), datagram.size());

        for (unsigned char c : datagram) {
            processData(c);
        }
    }
}

void MessageDecoder::processData(unsigned char data)
{
    std::cout << "reading char " << (int)data << std::endl;
    switch (readingStatus) {
    case NotReading:
        if (data == 0xff) {
            readingStatus = WaitingForF;
        }
        break;
        
    case WaitingForF:
        if (data == 0xff) {
            readingStatus = WaitingForMessageType;
        } else {
            readingStatus = NotReading;
        }
        break;

    case WaitingForMessageType:
        if (data == 0x01) {
            readingStatus = ReadingMidiStatus;
        } else { //INVALID
            readingStatus = NotReading;
        }
        break;

    case ReadingMidiStatus:
    {
        unsigned char head = data >> 4;
        if (head == 0x8 ||
            head == 0x9 || head == 0xA ||
            head == 0xB || head == 0xE ) {
            bytesRemaining = 2;
            msg = MidiMessage(data, 0, 0);
        } else {
            bytesRemaining = 1;
            msg = MidiMessage(data, 0);
        }
        readingStatus = ReadingMidiData;
        break;
    }

    case ReadingMidiData:
        if (bytesRemaining == 2) {
            msg.data1 = data;
        } else {
            if (msg.length() == 2) {
                msg.data1 = data;
            } else {
                msg.data2 = data;
            }
        }

        bytesRemaining--;
        if (bytesRemaining == 0) {
            readingStatus = NotReading;
            processMidiMessage(msg);
        }
        break;
    }
}

void MessageDecoder::setProcessMidiMessage(std::function<void(MidiMessage)> f) {
    processMidiMessage = f;
}
