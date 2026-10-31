import QtQuick
import qs.theme

// Tiny filled line graph of 0..1 values, newest on the right. The graph keeps
// a fixed size and scale (0..1), so it never resizes as the values change.
Canvas {
    id: root

    property list<real> values: []
    property int capacity: 30 // samples across the full width
    property color color: Theme.iris

    implicitWidth: 56
    implicitHeight: 18

    onValuesChanged: requestPaint()
    onColorChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        // Faint baseline so an idle (flat-zero) graph is still visible
        ctx.fillStyle = Qt.alpha(Theme.highlightHigh, 0.5);
        ctx.fillRect(0, height - 1, width, 1);
        if (values.length < 2)
            return;

        const step = width / (capacity - 1);
        const x0 = width - (values.length - 1) * step;
        const y = v => 1 + (height - 2) * (1 - Math.max(0, Math.min(1, v)));

        ctx.beginPath();
        ctx.moveTo(x0, y(values[0]));
        for (let i = 1; i < values.length; i++)
            ctx.lineTo(x0 + i * step, y(values[i]));
        ctx.lineWidth = 1.5;
        ctx.lineJoin = "round";
        ctx.strokeStyle = color;
        ctx.stroke();

        ctx.lineTo(width, height);
        ctx.lineTo(x0, height);
        ctx.closePath();
        ctx.fillStyle = Qt.alpha(color, 0.25);
        ctx.fill();
    }
}
