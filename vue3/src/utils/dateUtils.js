/**
 * 日期格式化工具类
 */
const DISPLAY_YEAR = 2026

function parseDate(value) {
  if (value instanceof Date) return new Date(value.getTime())

  if (typeof value === 'string') {
    const match = value.trim().match(/^(\d{4})-(\d{2})-(\d{2})(?:[ T](\d{2}):(\d{2})(?::(\d{2})(?:\.(\d+))?)?)?$/)
    if (match) {
      const milliseconds = Number((match[7] || '').padEnd(3, '0').slice(0, 3))
      return new Date(
        Number(match[1]),
        Number(match[2]) - 1,
        Number(match[3]),
        Number(match[4] || 0),
        Number(match[5] || 0),
        Number(match[6] || 0),
        milliseconds
      )
    }
  }

  return new Date(value)
}

export function withDisplayYear(value) {
  if (!value) return null
  const date = parseDate(value)
  if (Number.isNaN(date.getTime())) return null
  date.setFullYear(DISPLAY_YEAR)
  return date
}

export default class DateUtils {
  /**
   * 格式化日期
   * @param {Date|string|number} date 日期对象/日期字符串/时间戳
   * @param {string} format 格式化模式 支持：
   * YYYY: 年
   * MM: 月
   * DD: 日
   * HH: 时
   * mm: 分
   * ss: 秒
   * @returns {string} 格式化后的日期字符串
   */
  static format(date, format = 'YYYY-MM-DD') {
    // 转换输入日期为Date对象
    const dateObj = withDisplayYear(date);
    
    // 如果日期无效则返回空字符串
    if (!dateObj) {
      return '';
    }

    // 获取日期各个部分
    const year = dateObj.getFullYear();
    const month = dateObj.getMonth() + 1;
    const day = dateObj.getDate();
    const hours = dateObj.getHours();
    const minutes = dateObj.getMinutes();
    const seconds = dateObj.getSeconds();

    // 补零函数
    const padZero = (num) => num.toString().padStart(2, '0');

    // 替换格式字符串
    return format
      .replace('YYYY', year)
      .replace('MM', padZero(month))
      .replace('DD', padZero(day))
      .replace('HH', padZero(hours))
      .replace('mm', padZero(minutes))
      .replace('ss', padZero(seconds));
  }

  /**
   * 格式化为年月 YYYY-MM
   * @param {Date|string|number} date 日期
   * @returns {string}
   */
  static formatYearMonth(date) {
    return this.format(date, 'YYYY-MM');
  }

  /**
   * 格式化为年月日 YYYY-MM-DD
   * @param {Date|string|number} date 日期
   * @returns {string}
   */
  static formatDate(date) {
    return this.format(date, 'YYYY-MM-DD');
  }

  /**
   * 格式化为完整日期时间 YYYY-MM-DD HH:mm:ss
   * @param {Date|string|number} date 日期
   * @returns {string}
   */
  static formatDateTime(date) {
    return this.format(date, 'YYYY-MM-DD HH:mm:ss');
  }
}

/**
 * 格式化本地日期为 YYYY-MM-DD 格式
 * 避免时区转换问题的本地日期格式化函数
 * @param {Date|string|number} date 日期对象/日期字符串/时间戳
 * @returns {string} 格式化后的日期字符串
 */
export function formatLocalDate(date) {
  if (!date) return ''
  
  try {
    const d = withDisplayYear(date)
    if (!d) return ''
    
    const year = d.getFullYear()
    const month = String(d.getMonth() + 1).padStart(2, '0')
    const day = String(d.getDate()).padStart(2, '0')
    
    return `${year}-${month}-${day}`
  } catch (error) {
    return ''
  }
} 
