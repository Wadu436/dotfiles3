pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme

// CPU/RAM usage and CPU/GPU temperatures, sampled every 2s.
// hwmon indices shift between boots, so sensors are found by driver name.
Singleton {
    id: root

    property real cpu: 0 // 0..1
    property real mem: 0 // 0..1
    property real memUsedGb: 0
    property real memTotalGb: 0
    property real gpu: 0 // 0..1
    property real rxRate: 0 // bytes/s, all physical interfaces
    property real txRate: 0 // bytes/s
    property int cpuTemp: 0 // °C
    property int gpuTemp: 0 // °C

    property var lastCpu: null

    // The last minute of samples (oldest first), for sparklines
    readonly property int historyLength: 30
    property list<real> cpuHistory: []
    property list<real> gpuHistory: []
    property list<real> memHistory: []
    property list<real> rxHistory: []
    property list<real> txHistory: []
    property var lastNet: null

    function pushed(history: list<real>, v: real): list<real> {
        return [...history, v].slice(-historyLength);
    }

    // Only sample while something is showing the numbers.
    property int users: 0
    readonly property bool active: users > 0

    readonly property string script: `
        head -1 /proc/stat
        awk 'NR>2 { gsub(":", " "); if ($1 !~ /^(lo|veth|docker|br-|virbr|tailscale|tun|wg)/) { rx += $2; tx += $10 } } END { print "net", rx, tx }' /proc/net/dev
        awk '/^MemTotal|^MemAvailable/ {print $1, $2}' /proc/meminfo
        for h in /sys/class/hwmon/hwmon*; do
            case "$(cat $h/name)" in
                k10temp|coretemp) echo "cputemp $(cat $h/temp1_input)" ;;
                amdgpu) echo "gputemp $(cat $h/temp1_input)"
                        echo "gpubusy $(cat $h/device/gpu_busy_percent)" ;;
            esac
        done`

    Timer {
        interval: 2000
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    Process {
        id: proc
        command: ["sh", "-c", root.script]
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }

    function parse(text: string): void {
        let memTotal = 0, memAvail = 0;
        for (const line of text.trim().split("\n")) {
            const f = line.trim().split(/\s+/);
            switch (f[0]) {
            case "cpu":
                {
                    const v = f.slice(1).map(Number);
                    const idle = v[3] + v[4];
                    const total = v.reduce((a, b) => a + b, 0);
                    if (lastCpu)
                        cpu = 1 - (idle - lastCpu.idle) / Math.max(1, total - lastCpu.total);
                    lastCpu = {
                        idle,
                        total
                    };
                    break;
                }
            case "MemTotal:":
                memTotal = Number(f[1]);
                break;
            case "MemAvailable:":
                memAvail = Number(f[1]);
                break;
            case "cputemp":
                cpuTemp = Math.round(Number(f[1]) / 1000);
                break;
            case "gputemp":
                gpuTemp = Math.round(Number(f[1]) / 1000);
                break;
            case "net":
                {
                    const now = Date.now(), rx = Number(f[1]), tx = Number(f[2]);
                    if (lastNet) {
                        const dt = Math.max(0.001, (now - lastNet.t) / 1000);
                        rxRate = Math.max(0, (rx - lastNet.rx) / dt);
                        txRate = Math.max(0, (tx - lastNet.tx) / dt);
                    }
                    lastNet = {
                        rx,
                        tx,
                        t: now
                    };
                    break;
                }
            case "gpubusy":
                gpu = Number(f[1]) / 100;
                break;
            }
        }
        if (memTotal > 0) {
            mem = 1 - memAvail / memTotal;
            memTotalGb = memTotal / 1048576;
            memUsedGb = (memTotal - memAvail) / 1048576;
        }
        cpuHistory = pushed(cpuHistory, cpu);
        gpuHistory = pushed(gpuHistory, gpu);
        rxHistory = pushed(rxHistory, rxRate);
        txHistory = pushed(txHistory, txRate);
        memHistory = pushed(memHistory, mem);
    }

    // 1536 → "1.5 KB/s"
    function rate(bytes: real): string {
        const units = ["B", "KB", "MB", "GB"];
        let i = 0;
        while (bytes >= 1024 && i < units.length - 1) {
            bytes /= 1024;
            i++;
        }
        return (i === 0 ? Math.round(bytes) : bytes.toFixed(1)) + " " + units[i] + "/s";
    }

    function tempColor(t: int): color {
        return t >= 85 ? Theme.love : t >= 75 ? Theme.gold : Theme.subtle;
    }
}
