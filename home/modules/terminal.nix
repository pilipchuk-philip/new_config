{ pkgs, ... }:

let
  ghosttyConfig = ''
    term = xterm-256color
    theme = Ayu
    cursor-style = block
    cursor-style-blink = false
    copy-on-select = clipboard
    clipboard-read = allow
    clipboard-write = allow
  '';
in
{
  home.file =
    if pkgs.stdenv.hostPlatform.isDarwin then
      { "Library/Application Support/com.mitchellh.ghostty/config.ghostty".text = ghosttyConfig; }
    else
      { };

  xdg.configFile =
    if pkgs.stdenv.hostPlatform.isDarwin then
      { }
    else
      { "ghostty/config.ghostty".text = ghosttyConfig; };
}
