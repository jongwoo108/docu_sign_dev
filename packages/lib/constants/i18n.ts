import { z } from 'zod';

export const SUPPORTED_LANGUAGE_CODES = ['de', 'en', 'fr', 'es', 'it', 'pl', 'ko'] as const;

export const ZSupportedLanguageCodeSchema = z.enum(SUPPORTED_LANGUAGE_CODES).catch('en');

export type SupportedLanguageCodes = (typeof SUPPORTED_LANGUAGE_CODES)[number];

export type I18nLocaleData = {
  /**
   * The supported language extracted from the locale.
   */
  lang: SupportedLanguageCodes;

  /**
   * The preferred locales.
   */
  locales: string[];
};

const getDefaultLanguage = (): SupportedLanguageCodes => {
  const envLang = process.env.NEXT_PUBLIC_DEFAULT_LANGUAGE as SupportedLanguageCodes;
  return SUPPORTED_LANGUAGE_CODES.includes(envLang) ? envLang : 'en';
};

export const APP_I18N_OPTIONS = {
  supportedLangs: SUPPORTED_LANGUAGE_CODES,
  sourceLang: getDefaultLanguage(),   // ← env 기반
  defaultLocale: 'en-US',
} as const;

type SupportedLanguage = {
  full: string;
  short: string;
};

export const SUPPORTED_LANGUAGES: Record<string, SupportedLanguage> = {
  de: {
    full: 'German',
    short: 'de',
  },
  en: {
    full: 'English',
    short: 'en',
  },
  fr: {
    full: 'French',
    short: 'fr',
  },
  es: {
    full: 'Spanish',
    short: 'es',
  },
  it: {
    full: 'Italian',
    short: 'it',
  },
  pl: {
    short: 'pl',
    full: 'Polish',
  },
  ko: {
    short: 'ko',
    full: 'Korean',
  },
} satisfies Record<SupportedLanguageCodes, SupportedLanguage>;

export const isValidLanguageCode = (code: unknown): code is SupportedLanguageCodes =>
  SUPPORTED_LANGUAGE_CODES.indexOf(code as SupportedLanguageCodes) !== -1;
