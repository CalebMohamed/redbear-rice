pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
  id: root

  readonly property PwNode sink: Pipewire.defaultAudioSink

  // exposed data to display
  readonly property bool available: sink !== null && sink.audio !== null && sink.ready
  readonly property real volume: available ? sink.audio.volume : 0
  readonly property bool muted: available ? sink.audio.muted : false
  readonly property int percentage: Math.round(volume * 100)

  PwObjectTracker {
    objects: root.sink ? [root.sink] : []
  }

  function setVolume(value: real): void {
    if (!available)
    return

    sink.audio.volume = Math.max(0, Math.min(1, value))
  }

  function changeVolume(delta: real): void {
    setVolume(volume + delta)
  }

  function volumeUp(): void {
    changeVolume(0.05)
  }

  function volumeDown(): void {
    changeVolume(-0.05)
  }

  function toggleMute(): void {
    if (!available)
    return

    sink.audio.muted = !sink.audio.muted
  }

  function setMuted(value: bool): void {
    if (!available)
    return

    sink.audio.muted = value
  }
}
