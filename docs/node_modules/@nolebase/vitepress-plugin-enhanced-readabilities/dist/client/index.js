"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
Object.defineProperty(exports, "InjectionKey", {
  enumerable: true,
  get: function () {
    return _constants.InjectionKey;
  }
});
Object.defineProperty(exports, "LayoutMode", {
  enumerable: true,
  get: function () {
    return _constants.LayoutMode;
  }
});
Object.defineProperty(exports, "LayoutSwitch", {
  enumerable: true,
  get: function () {
    return _LayoutSwitch.default;
  }
});
Object.defineProperty(exports, "LayoutSwitchContentLayoutMaxWidthSlider", {
  enumerable: true,
  get: function () {
    return _LayoutSwitchContentLayoutMaxWidthSlider.default;
  }
});
Object.defineProperty(exports, "LayoutSwitchModeStorageKey", {
  enumerable: true,
  get: function () {
    return _constants.LayoutSwitchModeStorageKey;
  }
});
Object.defineProperty(exports, "LayoutSwitchPageLayoutMaxWidthSlider", {
  enumerable: true,
  get: function () {
    return _LayoutSwitchPageLayoutMaxWidthSlider.default;
  }
});
Object.defineProperty(exports, "NolebaseEnhancedReadabilitiesMenu", {
  enumerable: true,
  get: function () {
    return _Menu.default;
  }
});
exports.NolebaseEnhancedReadabilitiesPlugin = void 0;
Object.defineProperty(exports, "NolebaseEnhancedReadabilitiesScreenMenu", {
  enumerable: true,
  get: function () {
    return _ScreenMenu.default;
  }
});
Object.defineProperty(exports, "ScreenLayoutSwitch", {
  enumerable: true,
  get: function () {
    return _ScreenLayoutSwitch.default;
  }
});
Object.defineProperty(exports, "ScreenSpotlight", {
  enumerable: true,
  get: function () {
    return _ScreenSpotlight.default;
  }
});
Object.defineProperty(exports, "Spotlight", {
  enumerable: true,
  get: function () {
    return _Spotlight.default;
  }
});
Object.defineProperty(exports, "SpotlightStyle", {
  enumerable: true,
  get: function () {
    return _constants.SpotlightStyle;
  }
});
Object.defineProperty(exports, "SpotlightStyles", {
  enumerable: true,
  get: function () {
    return _SpotlightStyles.default;
  }
});
Object.defineProperty(exports, "SpotlightToggledStorageKey", {
  enumerable: true,
  get: function () {
    return _constants.SpotlightToggledStorageKey;
  }
});
var _LayoutSwitch = _interopRequireDefault(require("./components/LayoutSwitch.vue"));
var _LayoutSwitchContentLayoutMaxWidthSlider = _interopRequireDefault(require("./components/LayoutSwitchContentLayoutMaxWidthSlider.vue"));
var _LayoutSwitchPageLayoutMaxWidthSlider = _interopRequireDefault(require("./components/LayoutSwitchPageLayoutMaxWidthSlider.vue"));
var _Menu = _interopRequireDefault(require("./components/Menu.vue"));
var _ScreenLayoutSwitch = _interopRequireDefault(require("./components/ScreenLayoutSwitch.vue"));
var _ScreenMenu = _interopRequireDefault(require("./components/ScreenMenu.vue"));
var _ScreenSpotlight = _interopRequireDefault(require("./components/ScreenSpotlight.vue"));
var _Spotlight = _interopRequireDefault(require("./components/Spotlight.vue"));
var _SpotlightStyles = _interopRequireDefault(require("./components/SpotlightStyles.vue"));
var _constants = require("./constants");
function _interopRequireDefault(e) { return e && e.__esModule ? e : { default: e }; }
const components = {
  NolebaseEnhancedReadabilitiesMenu: _Menu.default,
  NolebaseEnhancedReadabilitiesScreenMenu: _ScreenMenu.default,
  NolebaseEnhancedReadabilitiesLayoutSwitch: _LayoutSwitch.default,
  NolebaseEnhancedReadabilitiesScreenLayoutSwitch: _ScreenLayoutSwitch.default,
  NolebaseEnhancedReadabilitiesSpotlight: _Spotlight.default,
  NolebaseEnhancedReadabilitiesSpotlightStyles: _SpotlightStyles.default,
  NolebaseEnhancedReadabilitiesScreenSpotlight: _ScreenSpotlight.default
};
const NolebaseEnhancedReadabilitiesPlugin = exports.NolebaseEnhancedReadabilitiesPlugin = {
  install(app, options) {
    if (typeof options !== "undefined" && typeof options === "object") app.provide(_constants.InjectionKey, options);
    for (const key of Object.keys(components)) app.component(key, components[key]);
  }
};