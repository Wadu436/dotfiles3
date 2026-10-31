import QtQuick
import qs.theme

// Tiny filled line graph, newest on the right, with an optional second series
// drawn on top. Values are scaled against `max` (1 for 0..1 data); the graph
// keeps a fixed size so it never resizes as the values change.
Canvas {
    id: root

    property list<real> values: []
    property color color: Theme.iris
    property list<real> values2: []
    property color color2: Theme.rose
    property real max: 1
    property int capacity: 30 // samples across the full width

    implicitWidth: 56
    implicitHeight: 18

    onValuesChanged: requestPaint()
    onValues2Changed: requestPaint()
    onColorChanged: requestPaint()
    onMaxChanged: requestPaint()

    function series(ctx: var, values: list<real>, color: color): void {
        if (values.length < 2)
            return;
        const step = width / (capacity - 1);
        const x0 = width - (values.length - 1) * step;
        const y = v => 1 + (height - 2) * (1 - Math.max(0, Math.min(1, v / root.max)));

        // Smooth curve: bend through the midpoints between samples, using each
        // sample as the control point, so there are no sharp corners.
        ctx.beginPath();
        ctx.moveTo(x0, y(values[0]));
        for (let i = 1; i < values.length - 1; i++) {
            const mx = x0 + (i + 0.5) * step;
            const my = (y(values[i]) + y(values[i + 1])) / 2;
            ctx.quadraticCurveTo(x0 + i * step, y(values[i]), mx, my);
        }
        ctx.lineTo(width, y(values[values.length - 1]));
        ctx.lineWidth = 1.5;
        ctx.lineJoin = "round";
        ctx.strokeStyle = color;
        ctx.stroke();

        ctx.lineTo(width, height);
        ctx.lineTo(x0, height);
        ctx.closePath();
        ctx.fillStyle = Qt.alpha(color, 0.22);
        ctx.fill();
    }

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        // Faint baseline so an idle (flat-zero) graph is still visible
        ctx.fillStyle = Qt.alpha(Theme.highlightHigh, 0.5);
        ctx.fillRect(0, height - 1, width, 1);
        series(ctx, values, color);
        series(ctx, values2, color2);
    }
}
