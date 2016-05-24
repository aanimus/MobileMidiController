#include <iostream>
#include "message.h"

MidiMessage::MidiMessage(unsigned char t_status,
                         unsigned char t_data1,
                         unsigned char t_data2)
{
    m_length = 3;
    status = t_status;
    data1 = t_data1;
    data2 = t_data2;
}

MidiMessage::MidiMessage(unsigned char t_status, unsigned char t_data1)
    :MidiMessage(t_status, t_data1, 0)
{
    m_length = 2;
}

std::vector<unsigned char> MidiMessage::toVector()
{
    if (m_length == 2) {
        return std::vector<unsigned char> {status, data1};
    } else if (m_length == 3) {
        return std::vector<unsigned char> {status, data1, data2};
    } else {
        std::cerr << "ERROR: length of midi message is not 2 or 3." << std::endl;
        exit(EXIT_FAILURE);
    }
}

int MidiMessage::length() const {
    return m_length;
}
