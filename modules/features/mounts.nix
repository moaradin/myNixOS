{ self, inputs, ... }: {

  flake.nixosModules.mounts = { ... }: {
    
    fileSystems."/mnt/ArchHome" = {
      device  = "UUID=634d3146-612e-4503-b89c-4f982c9cd5c2";
      fsType  = "btrfs";
      options = [ "subvol=@home" "defaults" "nofail" "x-systemd.automount" ];
    };

    fileSystems."/mnt/Windows" = {
      device  = "UUID=5A2C210D2C20E62B";
      fsType  = "ntfs";
      options = [ "defaults" "nofail" "x-systemd.automount" ];
    };

    fileSystems."/mnt/Recordings" = {
      device  = "UUID=6915a09f-f041-4e19-8e83-c6f58f4ace1e";
      fsType  = "btrfs";
      options = [ "defaults" "nofail" "x-systemd.automount" ];
    };

    fileSystems."/mnt/Games" = {
      device  = "UUID=d0dbdb49-994c-478e-b921-453c506546e1";
      fsType  = "ext4";
      options = [ "defaults" "nofail" "x-systemd.automount" ];
    };

    fileSystems."/mnt/Storage" = {
      device  = "UUID=C440C30840C30062";
      fsType  = "ntfs";
      options = [ "defaults" "nofail" "x-systemd.automount" ];
    };

  };
}
