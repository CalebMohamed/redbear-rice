pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  // Root filesystem usage, 0..100.
  readonly property real usage: _usage

  // Root filesystem, bytes.
  readonly property real totalBytes: _totalBytes
  readonly property real usedBytes: _usedBytes
  readonly property real availableBytes: _availableBytes

  // Real block-device filesystems.
  //
  // Each entry contains:
  //   device
  //   mountpoint
  //   totalBytes
  //   usedBytes
  //   availableBytes
  //   usage
  readonly property var filesystems: _filesystems

  // Aggregate block-device throughput, bytes/sec.
  readonly property real readBytesPerSecond: _readBytesPerSecond
  readonly property real writeBytesPerSecond: _writeBytesPerSecond

  // Recent I/O samples, oldest -> newest.
  //
  // Each sample contains:
  //   timestamp
  //   readBytesPerSecond
  //   writeBytesPerSecond
  readonly property var history: _history

  property real _usage: 0

  property real _totalBytes: 0
  property real _usedBytes: 0
  property real _availableBytes: 0

  property var _filesystems: []

  property real _readBytesPerSecond: 0
  property real _writeBytesPerSecond: 0

  property var _history: []
  property var _previousDisks: ({})
  property real _previousTimestamp: 0

  readonly property int historySize: 60
  readonly property int pollIntervalMs: 5000

  Process {
    id: storageReader

    command: [
      "sh", "-c",
      "printf '%s\\n' 'FILESYSTEMS'; " +
      "df -P -B1; " +
      "printf '%s\\n' 'DISKS'; " +
      "cat /proc/diskstats"
    ]

    stdout: StdioCollector {
      onStreamFinished: root.parse(text)
    }

    running: true

    onRunningChanged: {
      if (!running)
      pollTimer.start()
    }
  }

  Timer {
    id: pollTimer

    interval: root.pollIntervalMs
    repeat: false

    onTriggered: storageReader.running = true
  }

  function parse(output) {
    const sections = output.split("\nDISKS\n")

    if (sections.length < 2)
    return

    const filesystemText = sections[0]
    .replace(/^FILESYSTEMS\n/, "")
    .trim()

    const diskText = sections[1].trim()

    parseFilesystems(filesystemText)
    parseDiskStats(diskText)
  }

  function parseFilesystems(output) {
    const lines = output.split("\n")
    const filesystems = []

    for (let i = 1; i < lines.length; i++) {
      const fields = lines[i].trim().split(/\s+/)

      if (fields.length < 6)
      continue

      const device = fields[0]
      const mountpoint = fields[5]

      const totalBytes = Number(fields[1])
      const usedBytes = Number(fields[2])
      const availableBytes = Number(fields[3])
      const usage = parseInt(fields[4], 10)

      if (!device.startsWith("/dev/"))
      continue

      if (!Number.isFinite(totalBytes))
      continue

      filesystems.push({
        device,
        mountpoint,
        totalBytes,
        usedBytes,
        availableBytes,
        usage: Number.isFinite(usage) ? usage : 0
      })
    }

    root._filesystems = filesystems

    const filesystem = filesystems.find(
      item => item.mountpoint === "/"
    )

    if (!filesystem)
    return

    root._totalBytes = filesystem.totalBytes
    root._usedBytes = filesystem.usedBytes
    root._availableBytes = filesystem.availableBytes
    root._usage = filesystem.usage
  }

  function parseDiskStats(output) {
    const now = Date.now()
    const disks = {}

    for (const line of output.split("\n")) {
      const fields = line.trim().split(/\s+/)

      // major minor name ... sectors_read ... sectors_written ...
      if (fields.length < 14)
      continue

      const name = fields[2]

      if (!isPhysicalDisk(name))
      continue

      const readSectors = Number(fields[5])
      const writeSectors = Number(fields[9])

      if (
        !Number.isFinite(readSectors) ||
        !Number.isFinite(writeSectors)
      ) {
        continue
      }

      disks[name] = {
        readSectors,
        writeSectors
      }
    }

    if (root._previousTimestamp > 0) {
      const elapsedSeconds =
      (now - root._previousTimestamp) / 1000

      if (elapsedSeconds > 0) {
        let readBytes = 0
        let writeBytes = 0

        for (const name in disks) {
          const current = disks[name]
          const previous = root._previousDisks[name]

          if (!previous)
          continue

          const readDelta = Math.max(
            0,
            current.readSectors - previous.readSectors
          )

          const writeDelta = Math.max(
            0,
            current.writeSectors - previous.writeSectors
          )

          // Linux block statistics use 512-byte sectors.
          readBytes += readDelta * 512
          writeBytes += writeDelta * 512
        }

        root._readBytesPerSecond =
        readBytes / elapsedSeconds

        root._writeBytesPerSecond =
        writeBytes / elapsedSeconds

        root.recordSample(now)
      }
    }

    root._previousDisks = disks
    root._previousTimestamp = now
  }

  function isPhysicalDisk(name) {
    // Ignore virtual devices.
    if (
      name.startsWith("loop") ||
      name.startsWith("ram") ||
      name.startsWith("zram") ||
      name.startsWith("dm-")
    ) {
      return false
    }

    // Ignore common partition naming schemes.
    if (
      /^sd[a-z]+[0-9]+$/.test(name) ||
      /^hd[a-z]+[0-9]+$/.test(name) ||
      /^vd[a-z]+[0-9]+$/.test(name) ||
      /^xvd[a-z]+[0-9]+$/.test(name) ||
      /^nvme[0-9]+n[0-9]+p[0-9]+$/.test(name) ||
      /^mmcblk[0-9]+p[0-9]+$/.test(name)
    ) {
      return false
    }

    return true
  }

  function recordSample(timestamp) {
    const next = root._history.slice()

    next.push({
      timestamp,
      readBytesPerSecond: root._readBytesPerSecond,
      writeBytesPerSecond: root._writeBytesPerSecond
    })

    while (next.length > root.historySize)
    next.shift()

    root._history = next
  }
}
