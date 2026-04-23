{ self, inputs, ... }: {

  flake.nixosModules.VMDisko = { ... }: {
    imports = [ inputs.disko.nixosModules.disko ];

    fileSystems."/nix/persist".neededForBoot = true;
    fileSystems."/var/log".neededForBoot = true;
    fileSystems."/var/lib".neededForBoot = true;

    disko.devices = {
      disk.main = {
        type = "disk";
        device = "/dev/vda";
        content = {
          type = "gpt";
          partitions = {
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
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [ "subvol=root" "compress=zstd" "noatime" ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [ "subvol=home" "compress=zstd" "noatime" ];
                  };
                  "/home/user" = {};

                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "subvol=nix" "compress=zstd" "noatime" ];
                  };
                  "/nix/persist" = {
                    mountpoint = "/nix/persist";
                    mountOptions = [ "subvol=persist" "compress=zstd" "noatime" ];
                  };
                  "/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "subvol=log" "compress=zstd" "noatime" ];
                  };
                  "/lib" = {
                    mountpoint = "/var/lib";
                    mountOptions = [ "subvol=lib" "compress=zstd" "noatime" ];
                  };
                  "/test" = {};
                };
              };
            };
          };
        };
      };
    };
  };

}
