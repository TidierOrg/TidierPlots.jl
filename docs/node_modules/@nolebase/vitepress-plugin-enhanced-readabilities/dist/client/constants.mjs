export const InjectionKey = Symbol("vitepress-nolebase-enhanced-readabilities");
export const LayoutSwitchModeStorageKey = "vitepress-nolebase-enhanced-readabilities-layout-switch-mode";
export const LayoutSwitchMaxWidthStrategyStorageKey = "vitepress-nolebase-enhanced-readabilities-layout-switch-max-width-strategy";
export const ContentLayoutMaxWidthStorageKey = "vitepress-nolebase-enhanced-readabilities-content-layout-max-width";
export const PageLayoutMaxWidthStorageKey = "vitepress-nolebase-enhanced-readabilities-page-layout-max-width";
export const SpotlightToggledStorageKey = "vitepress-nolebase-enhanced-readabilities-spotlight-mode";
export const SpotlightStylesStorageKey = "vitepress-nolebase-enhanced-readabilities-spotlight-styles";
export var LayoutMode = /* @__PURE__ */ ((LayoutMode2) => {
  LayoutMode2[LayoutMode2["FullWidth"] = 1] = "FullWidth";
  LayoutMode2[LayoutMode2["Original"] = 3] = "Original";
  LayoutMode2[LayoutMode2["SidebarWidthAdjustableOnly"] = 4] = "SidebarWidthAdjustableOnly";
  LayoutMode2[LayoutMode2["BothWidthAdjustable"] = 5] = "BothWidthAdjustable";
  return LayoutMode2;
})(LayoutMode || {});
export const supportedLayoutModes = [
  1 /* FullWidth */,
  3 /* Original */,
  4 /* SidebarWidthAdjustableOnly */,
  5 /* BothWidthAdjustable */
];
export var SpotlightStyle = /* @__PURE__ */ ((SpotlightStyle2) => {
  SpotlightStyle2[SpotlightStyle2["Under"] = 1] = "Under";
  SpotlightStyle2[SpotlightStyle2["Aside"] = 2] = "Aside";
  return SpotlightStyle2;
})(SpotlightStyle || {});
export const supportedSpotlightStyles = [
  1 /* Under */,
  2 /* Aside */
];
