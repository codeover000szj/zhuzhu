const CHINA_TIME_ZONE = 'Asia/Shanghai'

const SOLAR_TERMS = [
  '小寒', '大寒', '立春', '雨水', '惊蛰', '春分', '清明', '谷雨',
  '立夏', '小满', '芒种', '夏至', '小暑', '大暑', '立秋', '处暑',
  '白露', '秋分', '寒露', '霜降', '立冬', '小雪', '大雪', '冬至'
]

const CHINESE_DIGITS = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九']
let cachedTermYear
let cachedTerms = []
const lunarFormatter = new Intl.DateTimeFormat('zh-CN-u-ca-chinese', {
  timeZone: CHINA_TIME_ZONE,
  month: 'long',
  day: 'numeric'
})
const dateFormatter = new Intl.DateTimeFormat('zh-CN', {
  timeZone: CHINA_TIME_ZONE,
  year: 'numeric',
  month: '2-digit',
  day: '2-digit'
})
const weekdayFormatter = new Intl.DateTimeFormat('zh-CN', {
  timeZone: CHINA_TIME_ZONE,
  weekday: 'long'
})
const timeFormatter = new Intl.DateTimeFormat('zh-CN', {
  timeZone: CHINA_TIME_ZONE,
  hour: '2-digit',
  minute: '2-digit',
  second: '2-digit',
  hourCycle: 'h23'
})

function dateParts(formatter, date) {
  return Object.fromEntries(formatter.formatToParts(date).map(({ type, value }) => [type, value]))
}

function lunarDayName(day) {
  const value = Number(day)
  if (value === 10) return '初十'
  if (value >= 1 && value < 10) return `初${CHINESE_DIGITS[value]}`
  if (value < 20) return `十${CHINESE_DIGITS[value - 10]}`
  if (value === 20) return '二十'
  if (value < 30) return `廿${CHINESE_DIGITS[value - 20]}`
  return '三十'
}

function solarLongitude(date) {
  // Apparent geocentric solar longitude: each 15-degree crossing begins a solar term.
  const julianDay = date.getTime() / 86400000 + 2440587.5
  const centuries = (julianDay - 2451545) / 36525
  const meanLongitude = 280.46646 + 36000.76983 * centuries + 0.0003032 * centuries ** 2
  const meanAnomaly = (357.52911 + 35999.05029 * centuries - 0.0001537 * centuries ** 2) * Math.PI / 180
  const equationOfCenter = (1.914602 - 0.004817 * centuries - 0.000014 * centuries ** 2) * Math.sin(meanAnomaly)
    + (0.019993 - 0.000101 * centuries) * Math.sin(2 * meanAnomaly)
    + 0.000289 * Math.sin(3 * meanAnomaly)
  const omega = (125.04 - 1934.136 * centuries) * Math.PI / 180
  return ((meanLongitude + equationOfCenter - 0.00569 - 0.00478 * Math.sin(omega)) % 360 + 360) % 360
}

function solarTermInstant(year, index) {
  const targetLongitude = 285 + index * 15
  const approximate = Date.UTC(year, 0, 5) + index * (365.2422 / 24) * 86400000
  let low = approximate - 7 * 86400000
  let high = approximate + 7 * 86400000

  for (let attempt = 0; attempt < 48; attempt += 1) {
    const middle = (low + high) / 2
    const longitude = solarLongitude(new Date(middle))
    const unwrappedLongitude = longitude + 360 * Math.round((targetLongitude - longitude) / 360)
    if (unwrappedLongitude < targetLongitude) low = middle
    else high = middle
  }

  return new Date((low + high) / 2)
}

function solarTermAt(date) {
  const year = Number(dateParts(dateFormatter, date).year)
  if (cachedTermYear !== year) {
    cachedTermYear = year
    cachedTerms = []
    for (let candidateYear = year - 1; candidateYear <= year + 1; candidateYear += 1) {
      SOLAR_TERMS.forEach((name, index) => {
        cachedTerms.push({ name, at: solarTermInstant(candidateYear, index) })
      })
    }
    cachedTerms.sort((left, right) => left.at - right.at)
  }
  const nextTerm = cachedTerms.findIndex(term => term.at > date)
  return cachedTerms[nextTerm - 1]?.name || SOLAR_TERMS[23]
}

export function getChineseCalendarSnapshot(date = new Date()) {
  const gregorian = dateParts(dateFormatter, date)
  const lunar = dateParts(lunarFormatter, date)

  return {
    gregorianDate: `${gregorian.year}-${gregorian.month}-${gregorian.day}`,
    weekday: weekdayFormatter.format(date),
    lunarDate: `${lunar.month}${lunarDayName(lunar.day)}`,
    solarTerm: solarTermAt(date),
    time: timeFormatter.format(date)
  }
}

