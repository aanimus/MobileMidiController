#include "midisystem.h"

MidiSystem::MidiSystem()
    :m_midiout(std::unique_ptr<RtMidiOut>(new RtMidiOut))
{}

std::map<std::string, int> MidiSystem::map_of_ports()
{
    std::map<std::string, int> ret;
    int num_ports = m_midiout->getPortCount();
    for (int i = 0; i < num_ports; i++) {
        std::string port_name = m_midiout->getPortName(i);
        ret[port_name] = i;
    }
    return ret;
}

bool MidiSystem::open_port(int port_num)
{
    try {
        m_midiout->openPort(port_num);
    } catch (RtMidiError &err) {
        err.printMessage();
        return false;
    }
    return true;
}

bool MidiSystem::open_port(std::string port_name) {
    auto mp = map_of_ports();
    if (mp.count(port_name)>0) {
        return open_port(mp[port_name]);
    } else {
        return false;
    }
}

bool MidiSystem::send_message(MidiMessage msg)
{
    std::vector<unsigned char> msgvec = msg.toVector();
    try {
        m_midiout->sendMessage(&msgvec);
    } catch (RtMidiError &err) {
        err.printMessage();
        return false;
    }
    return true;
}
