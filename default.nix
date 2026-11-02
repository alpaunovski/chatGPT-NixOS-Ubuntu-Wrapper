# SPDX-License-Identifier: MIT
{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

let
  version = "26.1027.51404";
  payload = pkgs.stdenvNoCC.mkDerivation {
    pname = "chatgpt-official-payload";
    inherit version;
    src = if builtins.pathExists ./chatgpt_amd64.deb then ./chatgpt_amd64.deb else
      pkgs.fetchurl {
        url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb";
        sha256 = "46f1e22d028698fe9edaefd5847aece07c4509a30d3709e104220719d8c12822";
      };
    nativeBuildInputs = [ pkgs.dpkg ];
    dontUnpack = true;
    dontFixup = true;
    installPhase = ''
      runHook preInstall
      echo '46f1e22d028698fe9edaefd5847aece07c4509a30d3709e104220719d8c12822  '"$src" | sha256sum --check
      dpkg-deb -x "$src" extracted
      test "$(dpkg-deb -f "$src" Architecture)" = amd64
      test "$(dpkg-deb -f "$src" Version)" = '${version}'
      mkdir -p "$out/lib" "$out/share"
      cp -a extracted/usr/lib/chatgpt "$out/lib/"
      cp -a extracted/usr/share/. "$out/share/"
      test -x "$out/lib/chatgpt/ChatGPT"
      runHook postInstall
    '';
    meta.license = pkgs.lib.licenses.unfree;
  };
in
assert pkgs.stdenv.hostPlatform.system == "x86_64-linux";
pkgs.buildFHSEnv {
  pname = "chatgpt";
  inherit version;
  targetPkgs = p: with p; [
    payload
    alsa-lib at-spi2-atk at-spi2-core atk cairo cups dbus expat
    gdk-pixbuf glib gtk3 libGL libgbm libnotify libsecret
    libusb1 libxkbcommon nspr nss openssl pango stdenv.cc.cc.lib
    systemd tpm2-tss vulkan-loader wayland
    xorg.libX11 xorg.libXext xorg.libXcomposite xorg.libXdamage
    xorg.libXfixes xorg.libXrandr xorg.libxcb xorg.libxshmfence
    bash coreutils curl git xdg-utils xz cacert
  ];
  multiArch = false;
  runScript = pkgs.writeShellScript "chatgpt-start" ''
    export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
    exec ${payload}/lib/chatgpt/ChatGPT "$@"
  '';
  extraInstallCommands = ''
    mkdir -p "$out/share"
    cp -a ${payload}/share/applications "$out/share/"
    cp -a ${payload}/share/pixmaps "$out/share/"
    substituteInPlace "$out/share/applications/chatgpt.desktop" \
      --replace-fail 'Exec=chatgpt %U' "Exec=$out/bin/chatgpt %U"
    # Only register the application callback; leave web/file defaults alone.
    sed -i 's|^MimeType=.*|MimeType=x-scheme-handler/codex;|' \
      "$out/share/applications/chatgpt.desktop"
  '';
  meta = {
    description = "Official ChatGPT Linux app in a Nix FHS environment (experimental)";
    homepage = "https://learn.chatgpt.com/docs/linux/linux-app";
    license = pkgs.lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "chatgpt";
  };
}
