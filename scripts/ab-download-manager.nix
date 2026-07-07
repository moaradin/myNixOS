{ pkgs, ... }:
let
  ab-download-manager = pkgs.callPackage (
    {
      lib,
      stdenv,
      fetchurl,
      autoPatchelfHook,
      makeWrapper,
      copyDesktopItems,
      makeDesktopItem,
      alsa-lib,
      at-spi2-atk,
      cairo,
      cups,
      dbus,
      expat,
      fontconfig,
      freetype,
      glib,
      gtk3,
      libGL,
      mesa,
      nspr,
      nss,
      pango,
      zlib,
      libx11,
      libxcomposite,
      libxdamage,
      libxext,
      libxfixes,
      libxi,
      libxrandr,
      libxrender,
      libxtst,
      libxcb,
    }:

    let
      version = "1.9.2";

      sources = {
        "x86_64-linux" = {
          url = "https://github.com/amir1376/ab-download-manager/releases/download/v${version}/ABDownloadManager_${version}_linux_x64.tar.gz";
          sha256 = "sha256-+Au7DbLjRkm7zLIP0fl2fDld6OynDLEfMPFoNQV36Ig=";
        };
        "aarch64-linux" = {
          url = "https://github.com/amir1376/ab-download-manager/releases/download/v${version}/ABDownloadManager_${version}_linux_arm64.tar.gz";
          sha256 = "";
        };
      };

      srcInfo = sources.${stdenv.system} or (throw "Unsupported system: ${stdenv.system}");

      runtimeLibs = [
        alsa-lib
        at-spi2-atk
        cairo
        cups
        dbus
        expat
        fontconfig
        freetype
        glib
        gtk3
        libGL
        mesa
        nspr
        nss
        pango
        stdenv.cc.cc.lib
        libx11
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxi
        libxrandr
        libxrender
        libxtst
        libxcb
        zlib
      ];

    in
    stdenv.mkDerivation {
      pname = "ab-download-manager";
      inherit version;

      src = fetchurl {
        inherit (srcInfo) url sha256;
      };

      nativeBuildInputs = [
        autoPatchelfHook
        makeWrapper
        copyDesktopItems
      ];

      buildInputs = runtimeLibs;

      desktopItems = [
        (makeDesktopItem {
          name = "ab-download-manager";
          exec = "ab-download-manager";
          icon = "abdownloadmanager";
          desktopName = "AB Download Manager";
          comment = "Manage and organize your download files better than before";
          categories = [
            "Utility"
            "Network"
          ];
          startupWMClass = "com-abdownloadmanager-desktop-AppKt";
        })
      ];

      installPhase = ''
        runHook preInstall

        mkdir -p $out/opt/ab-download-manager $out/bin
        cp -r * $out/opt/ab-download-manager/

        ln -s $out/opt/ab-download-manager/bin/ABDownloadManager $out/bin/ab-download-manager

        if [ -f $out/opt/ab-download-manager/lib/ABDownloadManager.png ]; then
          install -Dm644 $out/opt/ab-download-manager/lib/ABDownloadManager.png $out/share/icons/hicolor/512x512/apps/ab-download-manager.png
        fi

        runHook postInstall
      '';

      postFixup = ''
        wrapProgram $out/bin/ab-download-manager \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"
      '';

      meta = with lib; {
        description = "A Download Manager that speeds up your downloads";
        homepage = "https://abdownloadmanager.com/";
        license = licenses.asl20;
        platforms = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        mainProgram = "ab-download-manager";
      };
    }
  ) { };
in
{
  home.packages = [ ab-download-manager ];

  xdg.configFile."autostart/ab-download-manager.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=AB Download Manager
    Exec=ab-download-manager --background
    Icon=abdownloadmanager
    Terminal=false
    NoDisplay=true
  '';
}
