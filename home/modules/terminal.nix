{ ... }:

{
  xdg.configFile."ghostty/config".text = ''
    term = xterm-256color
    theme = Carbonfox
    cursor-style = block
    cursor-style-blink = false
    copy-on-select = clipboard
    clipboard-read = allow
    clipboard-write = allow
  '';
}
