#ifndef MESSAGE_H
#define MESSAGE_H

#include <vector>

struct MidiMessage {
    MidiMessage(unsigned char t_status,
                unsigned char t_data1,
                unsigned char t_data2);
    MidiMessage(unsigned char t_status,
                unsigned char t_data1);

    unsigned char status, data1, data2;

    int length() const;
    std::vector<unsigned char> toVector();

private:
    int m_length;
};

#endif // MESSAGE_H
