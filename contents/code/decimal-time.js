.pragma library

function pad(n, width) {
    var s = String(Math.floor(n))
    while (s.length < width) s = "0" + s
    return s
}

// Splits `date` into decimal hours/minutes/seconds and the raw day fraction.
// Day is local-midnight to local-midnight, split into 10:00:00 decimal units,
// mirroring the macOS "Metric" app so DST days stretch/squeeze the last
// decimal second instead of the clock ever showing past 10:00:00.
function decimalTime(date) {
    var midnight = new Date(date.getFullYear(), date.getMonth(), date.getDate())
    var msSinceMidnight = date.getTime() - midnight.getTime()
    var nextMidnight = new Date(date.getFullYear(), date.getMonth(), date.getDate() + 1)
    var realDayLengthMs = nextMidnight.getTime() - midnight.getTime()
    var fraction = msSinceMidnight / realDayLengthMs
    if (fraction < 0) fraction = 0
    if (fraction >= 1) fraction = 0.999999999

    var totalDecSeconds = fraction * 100000 // 10h * 100m * 100s
    var decHours = Math.floor(totalDecSeconds / 10000)
    var rem = totalDecSeconds - decHours * 10000
    var decMinutes = Math.floor(rem / 100)
    var decSeconds = Math.floor(rem - decMinutes * 100)

    return {
        hours: decHours,
        minutes: decMinutes,
        seconds: decSeconds,
        fraction: fraction
    }
}
