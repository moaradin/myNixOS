{ pkgs, lib, ... }:
let
  # ── Macro length ───────────────────────────────────────────────────────────
  # Each cycle = 15 ms (F down) + 50 ms + 15 ms (ESC down) + 50 ms = 130 ms
  # 10 hours = 36,000,000 ms / 130 ms = 276,924 cycles
  reps = 276924;

  # (down l) is included in every cycle, not just at the start.
  # Wine/Proton requires periodic key-repeat events to register a key as
  # "still held" — a single key-down at the top of the macro isn't enough.
  cycle = "(down l) (down f) 15 (up f) 50 (down esc) 15 (up esc) 50 ";

  loops = builtins.concatStringsSep ""
    (builtins.genList (_: cycle) reps);
in
{
  # ── Kanata ────────────────────────────────────────────────────────────────

  services.kanata = {
    enable = true;
    keyboards.sf6 = {
      devices = [
        "/dev/input/by-id/usb-HP__Inc_HyperX_Alloy_Origins-event-kbd"
      ];

      extraDefCfg = "process-unmapped-keys yes";

      # Insert — hold L, tap F+ESC for up to 10 hours.
      # Stop via kanata's built-in chord: LCtrl + Space + Esc.
      config = ''
        (defsrc
          ins
        )

        (deflayer sf6
          @sf6-start
        )

        (defalias
          sf6-start (macro
            (down l)
            ${loops}
            (up l)
          )
        )
      '';
    };
  };

  # Don't grab the keyboard at boot; the watcher controls start/stop
  systemd.services.kanata-sf6.wantedBy = lib.mkForce [ ];

  # ── sudo rules — watcher only ─────────────────────────────────────────────

  security.sudo.extraRules = [
    {
      users = [ "moara" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl start kanata-sf6.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl stop kanata-sf6.service";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # ── Watcher — auto-toggle Kanata when SF6 is running ─────────────────────
  # Uses /run/wrappers/bin/sudo (the NixOS sudo wrapper) rather than bare
  # `sudo`, which isn't in PATH inside a systemd user service.
  # Checks actual service state so it correctly handles manual stops too.

  systemd.user.services.sf6-kanata-watcher = {
    description = "Auto-toggle Kanata when SF6 is running";
    wantedBy = [ "default.target" ];
    path = [ pkgs.procps ];
    script = ''
      while true; do
        if pgrep -f "StreetFighter6.exe" > /dev/null; then
          if ! systemctl is-active --quiet kanata-sf6.service; then
            echo "SF6 running but Kanata inactive — starting..."
            /run/wrappers/bin/sudo /run/current-system/sw/bin/systemctl start kanata-sf6.service
          fi
        else
          if systemctl is-active --quiet kanata-sf6.service; then
            echo "SF6 closed — stopping Kanata..."
            /run/wrappers/bin/sudo /run/current-system/sw/bin/systemctl stop kanata-sf6.service
          fi
        fi

        sleep 3
      done
    '';
  };
}
