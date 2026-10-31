//@ pragma UseQApplication
import QtQuick
import Quickshell
import qs.island

ShellRoot {
    Variants {
        model: Quickshell.screens

        Island {}
    }
}
