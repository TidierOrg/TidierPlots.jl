"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.useI18n = void 0;
var _ui = require("@nolebase/ui");
var _constants = require("../constants");
var _locales = require("../locales");
const useI18n = exports.useI18n = (0, _ui.createI18n)(_constants.InjectionKey, _locales.defaultLocales, _locales.defaultEnLocale);