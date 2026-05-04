{ ... }:
{
  xdg.desktopEntries."zen" = {
    name = "Zen Browser";
    genericName = "Web Browser";
    exec = "zen --name zen %U";
    icon = "zen-browser";
    terminal = false;
    categories = [
      "Network"
      "WebBrowser"
    ];
    mimeType = [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
    settings = {
      StartupWMClass = "zen";
      StartupNotify = "true";
      Version = "1.5";
    };
    actions = {
      "new-window" = {
        name = "New Window";
        exec = "zen --new-window %U";
      };
      "new-private-window" = {
        name = "New Private Window";
        exec = "zen --private-window %U";
      };
      "profile-manager-window" = {
        name = "Profile Manager";
        exec = "zen --ProfileManager";
      };
    };
  };
}
