"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.supportedSpotlightStyles = exports.supportedLayoutModes = exports.SpotlightToggledStorageKey = exports.SpotlightStylesStorageKey = exports.SpotlightStyle = exports.PageLayoutMaxWidthStorageKey = exports.LayoutSwitchModeStorageKey = exports.LayoutSwitchMaxWidthStrategyStorageKey = exports.LayoutMode = exports.InjectionKey = exports.ContentLayoutMaxWidthStorageKey = void 0;
const InjectionKey = exports.InjectionKey = Symbol("vitepress-nolebase-enhanced-readabilities");
const LayoutSwitchModeStorageKey = exports.LayoutSwitchModeStorageKey = "vitepress-nolebase-enhanced-readabilities-layout-switch-mode";
const LayoutSwitchMaxWidthStrategyStorageKey = exports.LayoutSwitchMaxWidthStrategyStorageKey = "vitepress-nolebase-enhanced-readabilities-layout-switch-max-width-strategy";
const ContentLayoutMaxWidthStorageKey = exports.ContentLayoutMaxWidthStorageKey = "vitepress-nolebase-enhanced-readabilities-content-layout-max-width";
const PageLayoutMaxWidthStorageKey = exports.PageLayoutMaxWidthStorageKey = "vitepress-nolebase-enhanced-readabilities-page-layout-max-width";
const SpotlightToggledStorageKey = exports.SpotlightToggledStorageKey = "vitepress-nolebase-enhanced-readabilities-spotlight-mode";
const SpotlightStylesStorageKey = exports.SpotlightStylesStorageKey = "vitepress-nolebase-enhanced-readabilities-spotlight-styles";
var LayoutMode = exports.LayoutMode = /* @__PURE__ */(LayoutMode2 => {
  LayoutMode2[LayoutMode2["FullWidth"] = 1] = "FullWidth";
  LayoutMode2[LayoutMode2["Original"] = 3] = "Original";
  LayoutMode2[LayoutMode2["SidebarWidthAdjustableOnly"] = 4] = "SidebarWidthAdjustableOnly";
  LayoutMode2[LayoutMode2["BothWidthAdjustable"] = 5] = "BothWidthAdjustable";
  return LayoutMode2;
})(LayoutMode || {});
const supportedLayoutModes = exports.supportedLayoutModes = [1 /* FullWidth */, 3 /* Original */, 4 /* SidebarWidthAdjustableOnly */, 5 /* BothWidthAdjustable */];
var SpotlightStyle = exports.SpotlightStyle = /* @__PURE__ */(SpotlightStyle2 => {
  SpotlightStyle2[SpotlightStyle2["Under"] = 1] = "Under";
  SpotlightStyle2[SpotlightStyle2["Aside"] = 2] = "Aside";
  return SpotlightStyle2;
})(SpotlightStyle || {});
const supportedSpotlightStyles = exports.supportedSpotlightStyles = [1 /* Under */, 2 /* Aside */];