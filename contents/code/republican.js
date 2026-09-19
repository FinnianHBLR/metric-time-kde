.pragma library

// Decimal (French-Revolutionary style) calendar logic.
// Ported from the Cinnamon applet (Arranlr/Decimal-Time-and-Calendar-Linux-Mint-Applet).
//
//   * 12 months of 30 days, each month = 3 "decades" of 10 days
//   * 5 or 6 epagomenal days at the end of the year, belonging to no month
//   * Year 1 began on 22 Sept 1792; each year is approximated as starting
//     on 22 Sept (not the true astronomical equinox)

var MONTHS = ["Unember", "Duember", "Triember", "Quadember", "Quintember", "Sextember",
              "September", "October", "November", "December", "Undecember", "Duodecember"]

var DAYS = ["Monoday", "Diday", "Triday", "Tetraday", "Pentaday",
            "Hexaday", "Heptaday", "Octaday", "Enneaday", "Decaday"]

var DAYS_ABBR = ["Mo", "Di", "Tr", "Te", "Pe", "He", "Hp", "Oc", "En", "De"]

var EPAGOMENAL = ["Epagomenal I", "Epagomenal II", "Epagomenal III",
                  "Epagomenal IV", "Epagomenal V", "Epagomenal VI (Leap)"]

// "Month" slot used by the calendar view for the epagomenal block.
var EPAGOMENAL_SLOT = 12

var MS_PER_DAY = 86400000

function isGregorianLeap(y) {
    return (y % 4 === 0 && y % 100 !== 0) || (y % 400 === 0)
}

// Number of epagomenal days closing the given Republican year (5, or 6 when
// the Gregorian leap day falls inside that Republican year).
function epagomenalCount(republicanYear) {
    var epochYear = republicanYear + 1791
    return isGregorianLeap(epochYear + 1) ? 6 : 5
}

// Converts a JS Date to a Republican date.
//
// Normal day:      { republicanYear, monthIndex, dayOfMonth, decadeIndex,
//                    dayInDecadeIndex, isEpagomenal: false, complementaryCount }
// Epagomenal day:  { republicanYear, epagIndex, isEpagomenal: true, complementaryCount }
function fromDate(date) {
    var y = date.getFullYear()
    var m = date.getMonth()
    var d = date.getDate()

    // Republican year starts on 22 Sept (month index 8).
    var epochYear = (m < 8 || (m === 8 && d < 22)) ? y - 1 : y
    var republicanYear = epochYear - 1791

    // Count whole calendar days using UTC arithmetic. Subtracting local
    // midnights instead would be off by an hour across a DST change, and
    // flooring that can land on the wrong day for the whole DST period
    // (this bites in the southern hemisphere, where DST starts after 22 Sept).
    var dayIndex = Math.round((Date.UTC(y, m, d) - Date.UTC(epochYear, 8, 22)) / MS_PER_DAY)

    var complementaryCount = epagomenalCount(republicanYear)

    if (dayIndex < 360) {
        var dayOfMonth = (dayIndex % 30) + 1
        return {
            republicanYear: republicanYear,
            monthIndex: Math.floor(dayIndex / 30),
            dayOfMonth: dayOfMonth,
            decadeIndex: Math.floor((dayOfMonth - 1) / 10),
            dayInDecadeIndex: (dayOfMonth - 1) % 10,
            isEpagomenal: false,
            complementaryCount: complementaryCount
        }
    }
    return {
        republicanYear: republicanYear,
        epagIndex: dayIndex - 360,
        isEpagomenal: true,
        complementaryCount: complementaryCount
    }
}

// Which (year, month-slot) a calendar view should open on to show `rd`.
function viewFor(rd) {
    return {
        year: rd.republicanYear,
        month: rd.isEpagomenal ? EPAGOMENAL_SLOT : rd.monthIndex
    }
}

// "Pentaday, 5 Unember, Year 235"  /  "Epagomenal III, Year 235"
function describe(rd) {
    if (rd.isEpagomenal)
        return EPAGOMENAL[rd.epagIndex] + ", Year " + rd.republicanYear
    return DAYS[rd.dayInDecadeIndex] + ", " + rd.dayOfMonth + " " + MONTHS[rd.monthIndex]
           + ", Year " + rd.republicanYear
}

// Heading for a calendar view: "Unember — Year 235" / "Epagomenal Days — Year 235"
function monthTitle(year, month) {
    var name = month === EPAGOMENAL_SLOT ? "Epagomenal Days" : MONTHS[month]
    return name + " \u2014 Year " + year
}
