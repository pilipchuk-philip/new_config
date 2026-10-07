{ pkgs }:

let
  keyboardConfig = pkgs.writeText "ubuntu-keyd-default.conf" ''
    [ids]
    *

    [main]

    [alt]
    c = C-c
    v = C-v
    a = C-a
    x = C-x
  '';
  service = pkgs.writeText "ubuntu-keyd.service" ''
    [Unit]
    Description=Keyd keyboard remapping (Nix-managed)
    After=systemd-modules-load.service

    [Service]
    ExecStart=${pkgs.lib.getExe pkgs.keyd}
    Restart=on-failure
    RuntimeDirectory=keyd
    UMask=0077
    NoNewPrivileges=true
    ProtectSystem=strict
    ProtectHome=true
    PrivateTmp=true
    ProtectKernelTunables=true
    ProtectKernelModules=true
    ProtectControlGroups=true
    RestrictAddressFamilies=AF_UNIX
    LockPersonality=true

    [Install]
    WantedBy=multi-user.target
  '';
  modules = pkgs.writeText "ubuntu-keyd-modules.conf" "uinput\n";
  # Keep the daemon and all generated files alive across Nix garbage collection.
  bundle = pkgs.linkFarm "ubuntu-keyd-config" [
    { name = "default.conf"; path = keyboardConfig; }
    { name = "keyd.service"; path = service; }
    { name = "modules.conf"; path = modules; }
  ];
in
pkgs.writeShellApplication {
  name = "ubuntu-keyd-setup";
  runtimeInputs = [ pkgs.coreutils ];
  text = ''
    # Use Ubuntu's sudo/systemctl/modprobe; Nix supplies the daemon and config.
    /usr/bin/sudo -v
    /usr/bin/sudo install -d -m755 /etc/keyd /etc/modules-load.d /etc/systemd/system /nix/var/nix/gcroots
    /usr/bin/sudo ln -sfn ${bundle} /nix/var/nix/gcroots/ubuntu-keyd
    /usr/bin/sudo install -b -m644 ${bundle}/default.conf /etc/keyd/default.conf
    /usr/bin/sudo install -b -m644 ${bundle}/modules.conf /etc/modules-load.d/keyd.conf
    /usr/bin/sudo install -b -m644 ${bundle}/keyd.service /etc/systemd/system/keyd.service
    /usr/bin/sudo /usr/sbin/modprobe uinput
    /usr/bin/sudo /usr/bin/systemctl daemon-reload
    /usr/bin/sudo /usr/bin/systemctl enable keyd.service
    /usr/bin/sudo /usr/bin/systemctl restart keyd.service
    /usr/bin/sudo /usr/bin/systemctl --no-pager --full status keyd.service
  '';
}
