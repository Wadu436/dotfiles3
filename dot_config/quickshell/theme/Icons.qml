pragma Singleton

import QtQuick
import Quickshell

// Nerd Font (Material Design) glyphs, by codepoint so the source stays ASCII.
Singleton {
    function g(cp: int): string {
        return String.fromCodePoint(cp);
    }

    readonly property string volumeHigh: g(0xF057E)
    readonly property string volumeMedium: g(0xF0580)
    readonly property string volumeLow: g(0xF057F)
    readonly property string volumeOff: g(0xF0581)
    readonly property string mic: g(0xF036C)
    readonly property string micOff: g(0xF036D)
    readonly property string speaker: g(0xF04C3)
    readonly property string headphones: g(0xF02CB)

    readonly property string bell: g(0xF009A)
    readonly property string bellOff: g(0xF009B)
    readonly property string close: g(0xF0156)
    readonly property string search: g(0xF0349)

    readonly property string music: g(0xF075A)
    readonly property string play: g(0xF040A)
    readonly property string pause: g(0xF03E4)
    readonly property string next: g(0xF04AD)
    readonly property string prev: g(0xF04AE)

    readonly property string cpu: g(0xF0EE0)
    readonly property string memory: g(0xF035B)
    readonly property string gpu: g(0xF08AE)
    readonly property string temp: g(0xF050F)

    readonly property string wifi: g(0xF05A9)
    readonly property string ethernet: g(0xF0200)
    readonly property string offline: g(0xF0319)

    readonly property string lock: g(0xF033E)
    readonly property string logout: g(0xF0343)
    readonly property string reboot: g(0xF0709)
    readonly property string power: g(0xF0425)

    function volume(muted: bool, vol: real): string {
        if (muted || vol <= 0)
            return volumeOff;
        if (vol < 0.34)
            return volumeLow;
        if (vol < 0.67)
            return volumeMedium;
        return volumeHigh;
    }
}
