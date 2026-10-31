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
    property int cpuTemp: 0 // °C
    property int gpuTemp: 0 // °C

    property var lastCpu: null

    // Only sample while something is showing the numbers.
    property int users: 0
    readonly property bool active: users > 0

    readonly property string script: `
        head -1 /proc/stat
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
    }

    function tempColor(t: int): color {
        return t >= 85 ? Theme.love : t >= 75 ? Theme.gold : Theme.subtle;
    }
}
