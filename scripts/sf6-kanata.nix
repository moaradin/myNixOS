{ pkgs, lib, ... }:
let
  # ── Macro length ───────────────────────────────────────────────────────────
  # Each cycle = 15 ms (F down) + 50 ms + 15 ms (ESC down) + 50 ms = 130 ms
  # 10 hours = 36,000,000 ms / 130 ms = 276,924 cycles
  reps  = 276924;
  cycle = "(down f) 15 (up f) 50 (down esc) 15 (up esc) 50 ";
  loops = builtins.concatStringsSep ""
    (builtins.genList (_: cycle) reps);
in
{
  # ── Kanata ────────────────────────────────────────────────────────────────

  services.kanata = {
    enable = true;
    keyboards.sf6 = {
      devices = [
        # Run: ls /dev/input/by-id/
        "/dev/input/by-id/usb-HP__Inc_HyperX_Alloy_Origins-event-kbd"
      ];

      extraDefCfg = ''
        process-unmapped-keys yes
        danger-enable-cmd yes
      '';

      # Insert — start macro (hold L, tap F+ESC for up to 10 h)
      # End    — stop the kanata-sf6 service, cancelling the macro immediately.
      #          The watcher (below) detects the service went down while SF6
      #          is still running and restarts kanata, leaving it ready for the
      #          next Insert press.
      config = ''
        (defsrc
          ins end
        )

        (deflayer sf6
          @sf6-start
          @sf6-stop
        )

        (defalias
          sf6-start (macro
            (down l)
            ${loops}
            (up l)
          )

          ;; Stops the kanata-sf6 systemd service, which kills this process and
          ;; therefore the running macro. The kanata service user needs sudo
          ;; NOPASSWD for this — see the rule below.
          sf6-stop (cmd sudo /run/current-system/sw/bin/systemctl stop kanata-sf6.service)
        )
      '';
    };
  };

  # Don't grab the keyboard at boot; the watcher controls start/stop
  systemd.services.kanata-sf6.wantedBy = lib.mkForce [ ];

  # ── sudo rules ────────────────────────────────────────────────────────────

  security.sudo.extraRules = [
    # For the watcher service (runs as moara)
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
    # For kanata's own `cmd` action (the kanata NixOS module runs the service
    # as a `kanata` system user, not as root)
    {
      users = [ "kanata" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl stop kanata-sf6.service";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # ── Watcher ───────────────────────────────────────────────────────────────
  # Checks actual service state rather than a local boolean, so it correctly
  # handles the End-key cancel flow:
  #   End pressed → kanata-sf6 stops → watcher sees "SF6 up, kanata down"
  #   → restarts kanata → ready for the next Insert press.

  systemd.user.services.sf6-kanata-watcher = {
    description = "Auto-toggle Kanata when SF6 is running";
    wantedBy    = [ "default.target" ];
    path        = [ pkgs.procps ];
    script = ''
      while true; do
        if pgrep -f "StreetFighter6.exe" > /dev/null; then
          # SF6 is running — kanata should be active
          if ! systemctl is-active --quiet kanata-sf6.service; then
            echo "SF6 running but Kanata inactive — starting..."
            sudo /run/current-system/sw/bin/systemctl start kanata-sf6.service
          fi
        else
          # SF6 is not running — kanata should be stopped
          if systemctl is-active --quiet kanata-sf6.service; then
            echo "SF6 closed — stopping Kanata..."
            sudo /run/current-system/sw/bin/systemctl stop kanata-sf6.service
          fi
        fi

        sleep 3
      done
    '';
  };
}
