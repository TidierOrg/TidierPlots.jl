import type { InjectionKey as VueInjectionKey } from 'vue';
import type { Options } from './types';
export declare const InjectionKey: VueInjectionKey<Options>;
export declare const LayoutSwitchModeStorageKey = "vitepress-nolebase-enhanced-readabilities-layout-switch-mode";
export declare const LayoutSwitchMaxWidthStrategyStorageKey = "vitepress-nolebase-enhanced-readabilities-layout-switch-max-width-strategy";
export declare const ContentLayoutMaxWidthStorageKey = "vitepress-nolebase-enhanced-readabilities-content-layout-max-width";
export declare const PageLayoutMaxWidthStorageKey = "vitepress-nolebase-enhanced-readabilities-page-layout-max-width";
export declare const SpotlightToggledStorageKey = "vitepress-nolebase-enhanced-readabilities-spotlight-mode";
export declare const SpotlightStylesStorageKey = "vitepress-nolebase-enhanced-readabilities-spotlight-styles";
export declare enum LayoutMode {
    FullWidth = 1,
    Original = 3,
    SidebarWidthAdjustableOnly = 4,
    BothWidthAdjustable = 5
}
export declare const supportedLayoutModes: LayoutMode[];
export declare enum SpotlightStyle {
    Under = 1,
    Aside = 2
}
export declare const supportedSpotlightStyles: SpotlightStyle[];
