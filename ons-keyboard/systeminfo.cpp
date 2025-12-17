#include "systeminfo.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>

SystemInfo::SystemInfo(QObject *parent)
    : QObject(parent)
{
    fetchSystemInfo();
}

QString SystemInfo::execCommand(const QString &command)
{
    QProcess process;
    process.start("sh", QStringList() << "-c" << command);
    process.waitForFinished(2000); // 2 second timeout
    
    if (process.exitStatus() == QProcess::NormalExit && process.exitCode() == 0) {
        return QString::fromUtf8(process.readAllStandardOutput()).trimmed();
    }
    
    return QString();
}

void SystemInfo::fetchSystemInfo()
{
    qDebug() << "Fetching system information...";
    
    // Hostname
    m_hostname = execCommand("hostname");
    if (m_hostname.isEmpty()) {
        QFile hostnameFile("/etc/hostname");
        if (hostnameFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QTextStream in(&hostnameFile);
            m_hostname = in.readLine().trimmed();
            hostnameFile.close();
        }
    }
    if (m_hostname.isEmpty()) m_hostname = "Unknown";
    
    // Distro - try multiple methods
    m_distro = execCommand("cat /etc/os-release | grep '^PRETTY_NAME=' | cut -d'=' -f2 | tr -d '\"'");
    if (m_distro.isEmpty()) {
        m_distro = execCommand("lsb_release -d | cut -f2");
    }
    if (m_distro.isEmpty()) m_distro = "Linux";
    
    // CPU
    m_cpu = execCommand("cat /proc/cpuinfo | grep 'model name' | head -n1 | cut -d':' -f2");
    if (m_cpu.isEmpty()) m_cpu = "Unknown CPU";
    
    // RAM - used and total
    QString ramInfo = execCommand("free -h | awk '/^Mem:/ {print $3 \" / \" $2}'");
    if (!ramInfo.isEmpty()) {
        m_ramUsed = ramInfo.section('/', 0, 0).trimmed();
        m_ramTotal = ramInfo.section('/', 1, 1).trimmed();
    } else {
        m_ramUsed = "?";
        m_ramTotal = "?";
    }
    
    // CPU Temperature - try multiple sensors
    m_cpuTemp = execCommand("sensors | grep 'Package id 0:' | awk '{print $4}'");
    if (m_cpuTemp.isEmpty()) {
        m_cpuTemp = execCommand("sensors | grep 'Tdie:' | awk '{print $2}'");
    }
    if (m_cpuTemp.isEmpty()) {
        m_cpuTemp = execCommand("sensors | grep 'Core 0:' | awk '{print $3}'");
    }
    if (m_cpuTemp.isEmpty()) {
        m_cpuTemp = "N/A";
    }
    
    qDebug() << "System info fetched:";
    qDebug() << "  Hostname:" << m_hostname;
    qDebug() << "  Distro:" << m_distro;
    qDebug() << "  CPU:" << m_cpu;
    qDebug() << "  RAM:" << m_ramUsed << "/" << m_ramTotal;
    qDebug() << "  Temp:" << m_cpuTemp;
    
    emit systemInfoChanged();
}

void SystemInfo::refresh()
{
    fetchSystemInfo();
}

//I think dis is spaghetti code :woe:
