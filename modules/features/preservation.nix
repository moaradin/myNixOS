{ self, inputs, ... }:
{
  flake.nixosModules.preservation =
    { ... }:
    {
      imports = [ inputs.preservation.nixosModules.preservation ];

      preservation = {
        enable = true;

        # All paths listed here are bind-mounted from /persistent/<path>
        # into / at early boot. If a path doesn't exist yet under /persistent,
        # preservation creates it automatically on first boot.
        preserveAt."/persistent" = {

          directories = [

            # ── Critical NixOS state ────────────────────────────────────
            # Tracks UID/GID assignments across rebuilds. Without this,
            # UIDs can silently shift between reboots, breaking file
            # ownership on /home and anywhere else UIDs are used.
            # inInitrd: true — mounted during initrd, before anything else.
            {
              directory = "/var/lib/nixos";
              inInitrd = true;
            }

            # ── Systemd timer state ─────────────────────────────────────
            # Stores when each timer last triggered. Without this, any
            # OnCalendar/OnBootSec timers that already ran will fire again
            # on the next boot as if they never ran.
            "/var/lib/systemd/timers"

            # ── Bluetooth pairings ──────────────────────────────────────
            # Stores the link keys negotiated when you paired a device.
            # Without this, every reboot is a clean slate — all your
            # controllers, headsets, and peripherals need re-pairing.
            "/var/lib/bluetooth"

            # ── NetworkManager connections ──────────────────────────────
            # Stores saved connection profiles: WiFi SSIDs, passwords,
            # static IP configs etc. More precise than persisting all of
            # /var/lib/NetworkManager — only the config files, not runtime
            # state.
            "/etc/NetworkManager/system-connections"

            # ── Flatpak ─────────────────────────────────────────────────
            # Stores installed Flatpak runtimes, apps, and their per-app
            # data. Without this, all Flatpak apps disappear on reboot.
            "/var/lib/flatpak"

            # ── System logs ─────────────────────────────────────────────
            # Persists journald and other logs across reboots. Useful for
            # diagnosing issues that happened before the last reboot.
            "/var/log"

            # LACT SETTINGS
            "/etc/lact"

            # ── /tmp ─────────────────────────────────────────────────────
            # Puts /tmp on disk instead of in the root tmpfs. Without this,
            # large temp files (game shader caches, downloads in progress,
            # video encoding scratch space) eat directly into the 25% RAM
            # budget of the tmpfs root.
            # boot.tmp.cleanOnBoot = true in configuration.nix ensures it
            # is wiped on each boot the same way a real tmpfs would be.
            {
              directory = "/tmp";
              mode = "1777";
            }

          ];

          files = [

            # ── System identity ─────────────────────────────────────────
            # A unique ID used by systemd, D-Bus, and some applications
            # to identify this machine. If it changes, things like
            # journald log continuity and some licensed software break.
            # inInitrd: true — needed very early in boot.
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }

            # ── SSH host keys ───────────────────────────────────────────
            # The key pair that identifies this machine to SSH clients.
            # If these change, anyone who has connected before will get a
            # "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED" error.
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_ed25519_key.pub"
            "/etc/ssh/ssh_host_rsa_key"
            "/etc/ssh/ssh_host_rsa_key.pub"

          ];
        };
      };
    };
}
