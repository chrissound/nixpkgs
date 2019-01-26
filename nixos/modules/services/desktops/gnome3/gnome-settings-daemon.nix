# GNOME Settings Daemon

{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.gnome3.gnome-settings-daemon;

in

{

  ###### interface

  options = {

    services.gnome3.gnome-settings-daemon = {

      enable = mkEnableOption "GNOME Settings Daemon.";

      # There are many forks of gnome-settings-daemon
      package = mkOption {
        type = types.package;
        default = pkgs.gnome3.gnome-settings-daemon;
        description = "Which gnome-settings-daemon package to use.";
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    services.udev.packages = [ cfg.package ];

    security.wrappers.gsd-backlight-helper.source = "${pkgs.gnome3.gnome-settings-daemon}/libexec/gsd-backlight-helper";

    nixpkgs.overlays = [
      (self: super: {
        gnome3 = super.gnome3.overrideScope' (gself: gsuper: {
          gnome-settings-daemon = gsuper.gnome-settings-daemon.override {
            inherit (config.security) wrapperDir;
          };
        });
      })
    ];

  };

}
