-- Colors for Hyprland
-- Generated with matugen

return {
<* for name, value in colors *>
  {{ name }} = "{{ value.default.hex }}",
<* endfor *>
}
