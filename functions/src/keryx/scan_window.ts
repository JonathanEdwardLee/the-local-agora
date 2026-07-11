/**
 * Maps client time-window labels to inclusive YYYY-MM-DD bounds.
 * Uses America/Chicago calendar days for Local Agora Dev Contest geography.
 */
export type ClientTimeWindow =
  | "TONIGHT"
  | "TOMORROW"
  | "THIS_WEEKEND"
  | "NEXT_7_DAYS";

export type ClientCategory =
  | "ALL_SIGNALS"
  | "MUSIC"
  | "ART"
  | "STAGE"
  | "COMEDY"
  | "GATHERINGS";

function pad(n: number): string {
  return n.toString().padStart(2, "0");
}

function ymdInChicago(date: Date): string {
  // en-CA yields YYYY-MM-DD
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: "America/Chicago",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(date);
}

function addDaysYmd(ymd: string, days: number): string {
  const [y, m, d] = ymd.split("-").map(Number);
  const utc = new Date(Date.UTC(y, m - 1, d));
  utc.setUTCDate(utc.getUTCDate() + days);
  return `${utc.getUTCFullYear()}-${pad(utc.getUTCMonth() + 1)}-${pad(utc.getUTCDate())}`;
}

function dayOfWeekChicago(date: Date): number {
  // 0=Sun .. 6=Sat in Chicago
  const weekday = new Intl.DateTimeFormat("en-US", {
    timeZone: "America/Chicago",
    weekday: "short",
  }).format(date);
  const map: Record<string, number> = {
    Sun: 0,
    Mon: 1,
    Tue: 2,
    Wed: 3,
    Thu: 4,
    Fri: 5,
    Sat: 6,
  };
  return map[weekday] ?? 0;
}

export function resolveScanWindow(
  timeWindow: ClientTimeWindow,
  now: Date = new Date(),
): { windowStartDate: string; windowEndDate: string; calendarContextDate: string } {
  const today = ymdInChicago(now);
  const dow = dayOfWeekChicago(now);

  let windowStartDate = today;
  let windowEndDate = today;

  switch (timeWindow) {
    case "TONIGHT":
      windowStartDate = today;
      windowEndDate = today;
      break;
    case "TOMORROW":
      windowStartDate = addDaysYmd(today, 1);
      windowEndDate = windowStartDate;
      break;
    case "THIS_WEEKEND": {
      // Friday–Sunday of the current/upcoming weekend
      const daysUntilFri = (5 - dow + 7) % 7;
      const friday = addDaysYmd(today, daysUntilFri === 0 && dow > 5 ? 0 : daysUntilFri);
      // If today is Sat/Sun, start from today; if Fri, Friday; else next Friday
      if (dow === 6) {
        windowStartDate = today;
        windowEndDate = addDaysYmd(today, 1);
      } else if (dow === 0) {
        windowStartDate = today;
        windowEndDate = today;
      } else {
        windowStartDate = friday;
        windowEndDate = addDaysYmd(friday, 2);
      }
      break;
    }
    case "NEXT_7_DAYS":
      windowStartDate = today;
      windowEndDate = addDaysYmd(today, 6);
      break;
  }

  const calendarContextDate = new Intl.DateTimeFormat("en-US", {
    timeZone: "America/Chicago",
    weekday: "long",
    year: "numeric",
    month: "long",
    day: "numeric",
  }).format(now);

  return { windowStartDate, windowEndDate, calendarContextDate };
}

export function mapClientCategory(
  category: ClientCategory,
): import("./request_builder").EventCategoryFilter {
  switch (category) {
    case "ALL_SIGNALS":
      return "ALL";
    case "MUSIC":
      return "MUSIC";
    case "ART":
      return "ART";
    case "STAGE":
      return "STAGE";
    case "COMEDY":
      return "COMEDY";
    case "GATHERINGS":
      return "GATHERINGS";
  }
}
