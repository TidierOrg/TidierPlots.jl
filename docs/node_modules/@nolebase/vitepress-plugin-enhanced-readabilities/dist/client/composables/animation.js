"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.useLayoutAppearanceChangeAnimation = useLayoutAppearanceChangeAnimation;
var _core = require("@vueuse/core");
function useLayoutAppearanceChangeAnimation() {
  const mounted = (0, _core.useMounted)();
  return {
    trigger: animateElement => {
      animateElement.classList.add("VPNolebaseEnhancedReadabilitiesLayoutSwitchAnimated");
      const removeAnimatedClassName = (0, _core.useDebounceFn)(() => {
        if (!(mounted.value && animateElement)) return;
        animateElement.classList.remove("VPNolebaseEnhancedReadabilitiesLayoutSwitchAnimated");
      }, 5e3);
      removeAnimatedClassName();
    }
  };
}