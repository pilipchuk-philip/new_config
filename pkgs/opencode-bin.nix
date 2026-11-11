{ pkgs }:
let
  release = builtins.fromJSON (builtins.readFile ./opencode-bin.json);
  platform = release.platforms.${pkgs.stdenv.hostPlatform.system};
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "opencode";
  inherit (release) version;
  src = pkgs.fetchurl {
    inherit (platform) url hash;
  };
  nativeBuildInputs = [
    pkgs.unzip
    pkgs.makeBinaryWrapper
  ]
  ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.autoPatchelfHook ];
  buildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    pkgs.stdenv.cc.cc.lib
  ];
  dontUnpack = true;
  dontStrip = true;
  # Preserve upstream's Mach-O signature. Linux needs its ELF interpreter patched.
  dontFixup = pkgs.stdenv.hostPlatform.isDarwin;
  installPhase = ''
    runHook preInstall
    mkdir release
    ${
      if pkgs.stdenv.hostPlatform.isDarwin then
        ''unzip "$src" -d release''
      else
        ''tar -xzf "$src" -C release''
    }
    install -Dm755 release/opencode "$out/bin/opencode"
    wrapProgram "$out/bin/opencode" \
      --set OPENCODE_DISABLE_AUTOUPDATE true \
      --suffix PATH : ${
        pkgs.lib.makeBinPath (
          [ pkgs.ripgrep ] ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.sysctl ]
        )
      } \
      ${pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isLinux "--prefix LD_LIBRARY_PATH : ${
        pkgs.lib.makeLibraryPath [
          pkgs.stdenv.cc.cc
          pkgs.wayland
        ]
      }"}
    runHook postInstall
  '';
  doInstallCheck = true;
  nativeInstallCheckInputs = [ pkgs.writableTmpDirAsHomeHook ];
  installCheckPhase = ''
    runHook preInstallCheck
    actual_version=$(OPENCODE_DISABLE_MODELS_FETCH=true "$out/bin/opencode" --version)
    echo "OpenCode version check: $actual_version"
    test "$actual_version" = "opencode v${release.version}"
    runHook postInstallCheck
  '';
  meta = {
    description = "AI coding agent (official prebuilt release)";
    homepage = "https://github.com/anomalyco/opencode";
    license = pkgs.lib.licenses.mit;
    platforms = builtins.attrNames release.platforms;
    mainProgram = "opencode";
  };
}
