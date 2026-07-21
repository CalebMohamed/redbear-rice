pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick

Singleton {
    id: root

    // Access UPower directly via displayDevice
    readonly property string energy: {
        const device = UPower.displayDevice;
        return device ? Math.round(device.percentage * 100) + "%" : "N/A";
    }
}
