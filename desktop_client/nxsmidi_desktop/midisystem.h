#ifndef MIDISYSTEM_H
#define MIDISYSTEM_H

#include <QObject>
#include <map>
#include "message.h"
#include "RtMidi.h"

class MidiSystem : public QObject
{
    Q_OBJECT
public:
    MidiSystem();

    /**
     * @return a map of port names to port number
     */
    std::map<std::string, int> map_of_ports();

    /**
      * @return true if successful, false if device not found.
    */
    bool open_port(int port_num);
    bool open_port(std::string port_name);

    /**
     * @brief sends message to each opened port
     * @param msg
     * @return true if success
     */
    bool send_message(MidiMessage msg);
private:
    std::unique_ptr<RtMidiOut> m_midiout;
};

#endif // MIDISYSTEM_H
