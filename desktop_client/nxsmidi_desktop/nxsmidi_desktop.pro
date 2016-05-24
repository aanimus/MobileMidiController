TEMPLATE = app

QT += qml quick testlib
CONFIG += c++11 testcase

SOURCES += main.cpp \
    midisystem.cpp \
    message.cpp \
    appmanager.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

INCLUDEPATH += /usr/local/opt/rtmidi/include
LIBS += -L/usr/local/opt/rtmidi/lib -lrtmidi

HEADERS += \
    midisystem.h \
    message.h \
    appmanager.h

