{ self, inputs, ... }:
{
  flake.nixosModules.myMachineDisko =
    { ... }:
    {
      imports = [ inputs.disko.nixosModules.disko ];

      # /persistent must be mounted before systemd activates services,
      # since preservation bind-mounts paths from here into / at early boot.
      fileSystems."/persistent".neededForBoot = true;

      # ── Root filesystem ──────────────────────────────────────────────────
      # / is a tmpfs — wiped completely on every reboot.
      # Anything you want to survive a reboot must be explicitly listed
      # in preservation.nix, which bind-mounts it from /persistent.
      #
      # size=25% caps RAM usage; mode=755 matches normal / permissions.
      disko.devices.nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=25%"
          "mode=755"
        ];
      };

      # ── Disk layout ──────────────────────────────────────────────────────
      disko.devices.disk.main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Fanxiang_S501_128GB_26030409611000389";

        content = {
          type = "gpt";
          partitions = {

            # EFI System Partition — bootloader lives here
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            # Root btrfs partition — holds all subvolumes below
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];

                subvolumes = {

                  # ── /home ────────────────────────────────────────────────
                  # User home directories. Kept as its own subvolume so all
                  # dotfiles, game saves, downloads etc. survive reboots
                  # automatically without needing individual preservation rules.
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "subvol=home"
                      "compress=zstd"
                      "noatime"
                    ];
                  };

                  # ── /nix ─────────────────────────────────────────────────
                  # The Nix store. Must be persistent — this is where all
                  # built packages, system generations, and the bootloader
                  # entries live.
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "subvol=nix"
                      "compress=zstd"
                      "noatime"
                    ];
                  };

                  # ── /persistent ──────────────────────────────────────────
                  # Explicit persistent state. preservation.nix bind-mounts
                  # specific paths from here (e.g. /persistent/var/log) into
                  # the tmpfs / at boot. Only what is listed in preservation
                  # survives a reboot — everything else in / is wiped.
                  "/persistent" = {
                    mountpoint = "/persistent";
                    mountOptions = [
                      "subvol=persistent"
                      "compress=zstd"
                      "noatime"
                    ];
                  };

                };
              };
            };
          };
        };
      };
    };
}
