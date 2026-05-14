{ pkgs, lib, ... }:
let
  # ── Python macro script ───────────────────────────────────────────────────
  # Kanata's macro system can only send key-press (1) and key-release (0)
  # events. Wine/Proton requires periodic KEY_REPEAT (2) events to keep
  # registering a key as held — without them it stops seeing L as pressed
  # after ~500 ms. Python + evdev lets us send all three event types directly.
  #
  # The script runs inside the kanata-sf6 systemd cgroup, so when the service
  # is stopped (via LCtrl+Space+Esc or SF6 closing), systemd sends SIGTERM to
  # the whole cgroup. The finally block catches it and releases KEY_L cleanly.

  pythonWithEvdev = pkgs.python3.withPackages (ps: [ ps.evdev ]);

  sf6Macro = pkgs.writeTextFile {
    name = "sf6-macro";
    executable = true;
    destination = "/bin/sf6-macro";
    text = ''
      #!${pythonWithEvdev}/bin/python3
      import evdev, time, signal, sys, fcntl, os, random
      from evdev import UInput, ecodes as e

      # ── Single-instance guard ──────────────────────────────────────────
      # Prevents a second macro starting if Insert is pressed while one
      # is already running.
      lock = open('/tmp/sf6-macro.lock', 'w')
      try:
          fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
      except IOError:
          sys.exit(0)

      # ── Virtual input device ───────────────────────────────────────────
      ui = UInput(
          {e.EV_KEY: [e.KEY_L, e.KEY_F, e.KEY_ESC]},
          name='sf6-macro-virtual',
      )

      # ── Signal handling ────────────────────────────────────────────────
      running = True
      def stop(sig, _):
          global running
          running = False
      signal.signal(signal.SIGTERM, stop)
      signal.signal(signal.SIGINT, stop)

      # ── Macro loop ─────────────────────────────────────────────────────
      try:
          # Initial KEY_L press
          ui.write(e.EV_KEY, e.KEY_L, 1)
          ui.syn()

          while running:
              # KEY_REPEAT (value=2) — re-asserts L as held.
              # Sent before every F and ESC tap so Wine/Proton always sees
              # L as actively held, not just "pressed once long ago."
              ui.write(e.EV_KEY, e.KEY_L, 2)
              ui.syn()

              # Tap F: randomised hold (1–300 ms) and gap (1–300 ms)
              ui.write(e.EV_KEY, e.KEY_F, 1)
              ui.syn()
              time.sleep(random.uniform(0.001, 0.300))
              ui.write(e.EV_KEY, e.KEY_F, 0)
              ui.syn()
              time.sleep(random.uniform(0.001, 0.300))

              # Repeat before ESC too
              ui.write(e.EV_KEY, e.KEY_L, 2)
              ui.syn()

              # Tap ESC: randomised hold (1–300 ms) and gap (1–300 ms)
              ui.write(e.EV_KEY, e.KEY_ESC, 1)
              ui.syn()
              time.sleep(random.uniform(0.001, 0.300))
              ui.write(e.EV_KEY, e.KEY_ESC, 0)
              ui.syn()
              time.sleep(random.uniform(0.001, 0.300))

      finally:
          # Always release L, even if killed mid-cycle
          ui.write(e.EV_KEY, e.KEY_L, 0)
          ui.syn()
          ui.close()
          lock.close()
          try:
              os.unlink('/tmp/sf6-macro.lock')
          except OSError:
              pass
    '';
  };
in
{
  # ── Kanata ────────────────────────────────────────────────────────────────
  # Only job here is to watch for Insert and fire the macro script via cmd.
  # All actual key logic lives in sf6Macro above.

  services.kanata = {
    enable = true;
    package = pkgs.kanata-with-cmd;
    keyboards.sf6 = {
      devices = [
        "/dev/input/by-id/usb-HP__Inc_HyperX_Alloy_Origins-event-kbd"
      ];
      extraDefCfg = ''
        process-unmapped-keys yes
        danger-enable-cmd yes
      '';
      config = ''
        (defsrc
          ins
        )
        (deflayer sf6
          @sf6-start
        )
        (defalias
          ;; Fires the Python script. Runs inside the kanata-sf6 cgroup so
          ;; systemd kills it automatically when the service stops.
          sf6-start (cmd ${sf6Macro}/bin/sf6-macro)
        )
      '';
    };
  };

  # Don't grab the keyboard at boot; the watcher controls start/stop
  systemd.services.kanata-sf6.wantedBy = lib.mkForce [ ];

  # ── sudo rules ────────────────────────────────────────────────────────────

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

  # ── Watcher ───────────────────────────────────────────────────────────────

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
