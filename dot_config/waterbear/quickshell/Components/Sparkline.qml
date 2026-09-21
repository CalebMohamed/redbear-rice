import QtQuick

Canvas {
  id: root

  // Array of objects containing the valueKey property.
  property var samples: []

  // Property to plot from each sample.
  property string valueKey: "percentage"

  property color lineColor: "white"
  property real lineWidth: 2

  property real horizontalPadding: 2
  property real verticalPadding: 2

  // Automatically scale the Y axis to recent values.
  property bool autoScale: true

  // Prevent small changes from being visually exaggerated.
  property real minimumRange: 5

  // Used when autoScale === false.
  property real minimum: 0
  property real maximum: 100

  onSamplesChanged: requestPaint()
  onValueKeyChanged: requestPaint()
  onLineColorChanged: requestPaint()
  onLineWidthChanged: requestPaint()
  onAutoScaleChanged: requestPaint()
  onMinimumRangeChanged: requestPaint()
  onMinimumChanged: requestPaint()
  onMaximumChanged: requestPaint()
  onWidthChanged: requestPaint()
  onHeightChanged: requestPaint()

  onPaint: {
    const ctx = getContext("2d")
    ctx.reset()

    if (!samples || samples.length < 2)
    return

    const values = samples
    .map(sample => sample[valueKey])
    .filter(value => Number.isFinite(value))

    if (values.length < 2)
    return

    let minValue
    let maxValue

    if (autoScale) {
      const observedMin = Math.min(...values)
      const observedMax = Math.max(...values)

      const observedRange = observedMax - observedMin
      const range = Math.max(observedRange, minimumRange)
      const center = (observedMin + observedMax) / 2

      minValue = center - range / 2
      maxValue = center + range / 2
    } else {
      minValue = minimum
      maxValue = maximum
    }

    const plotWidth = width - horizontalPadding * 2
    const plotHeight = height - verticalPadding * 2

    if (plotWidth <= 0 || plotHeight <= 0)
    return

    const xStep = plotWidth / (values.length - 1)
    const valueRange = Math.max(0.0001, maxValue - minValue)

    function yForValue(value) {
      const normalized = (value - minValue) / valueRange

      return verticalPadding +
      plotHeight * (1 - normalized)
    }

    ctx.beginPath()
    ctx.lineWidth = root.lineWidth
    ctx.lineCap = "round"
    ctx.lineJoin = "round"
    ctx.strokeStyle = root.lineColor

    for (let i = 0; i < values.length; i++) {
      const x = horizontalPadding + i * xStep
      const y = yForValue(values[i])

      if (i === 0)
      ctx.moveTo(x, y)
      else
      ctx.lineTo(x, y)
    }

    ctx.stroke()
  }
}

