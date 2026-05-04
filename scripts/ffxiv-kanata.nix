{ pkgs, lib, ... }:
{
  # ── Kanata — remap Aerox 9 side buttons while FFXIV is running ───────────

  services.kanata = {
    enable = true;
    keyboards.ffxiv = {
      devices = [
        # The verified interface for the Aerox 9 side buttons
        "/dev/input/by-id/usb-SteelSeries_SteelSeries_Aerox_9_Wireless-if05-event-kbd"
      ];
      extraDefCfg = "process-unmapped-keys yes";
      config = ''
        (defsrc
          1 2 3 pause
        )
        (deflayer ffxiv
          left down right del
        )
      '';
    };
  };

  # Prevent kanata from grabbing the mouse on system boot —
  # the watcher service below starts/stops it on demand instead.
  systemd.services.kanata-ffxiv.wantedBy = lib.mkForce [ ];

  # Allow the watcher to toggle the kanata service without a password prompt.
  security.sudo.extraRules = [
    {
      users = [ "moara" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl start kanata-ffxiv.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl stop kanata-ffxiv.service";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # ── Watcher — auto-toggle Kanata when FFXIV is running ───────────────────

  systemd.user.services.kanata-ffxiv-watcher = {
    description = "Auto-toggle Kanata when FFXIV is running";
    wantedBy = [ "default.target" ];
    path = [ pkgs.procps ];
    script = ''
      is_running=false

      while true; do
        if pgrep -x "ffxiv_dx11.exe" > /dev/null; then
          if [ "$is_running" = false ]; then
            echo "FFXIV detected, starting Kanata..."
            /run/wrappers/bin/sudo /run/current-system/sw/bin/systemctl start kanata-ffxiv.service
            is_running=true
          fi
        else
          if [ "$is_running" = true ]; then
            echo "FFXIV closed, stopping Kanata..."
            /run/wrappers/bin/sudo /run/current-system/sw/bin/systemctl stop kanata-ffxiv.service
            is_running=false
          fi
        fi

        sleep 3
      done
    '';
  };
}
