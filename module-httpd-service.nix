{ pkgs, lib, ... }:
let
  utils = rec {
    makeVhost =
      {
        forceSSL ? true,
        useACMEHost ? "0.0.0.0",
        ...
      }@args:
      { inherit forceSSL useACMEHost; } // args;

    makeLocationProxy =
      {
        host,
        protocol ? "http",
        location ? "/",
        extraConfig ? "",
      }:
      {
        proxyPass = "${protocol}://${host}/";
        extraConfig = ''
          ${extraConfig}
          RewriteEngine On
          RewriteCond %{HTTP:Upgrade} =websocket [NC]
          RewriteRule ${location}(.*)           ws://${host}/$1 [P,L]
        '';
      };

    # Same as above but for reverse proxying with websocket support.
    # Additional args can be added to the result attrset with the // syntax.
    makeVhostProxy =
      {
        location ? "/",
        ...
      }@args:
      (makeVhost { locations."${location}" = makeLocationProxy args; });

  };
in
{
  # Required by Akaunting
  systemd.services.httpd.path = [
    pkgs.php83
    pkgs.zip
    pkgs.unzip
    pkgs.gd
  ];

  services.httpd = {
    enablePHP = true;
    phpPackage = pkgs.php83;
    phpOptions = ''
      extension = ${pkgs.php83Extensions.pgsql}/lib/php/extensions/pgsql.so
      extension = ${pkgs.php83Extensions.gd}/lib/php/extensions/gd.so
      extension = ${pkgs.php83Extensions.zip}/lib/php/extensions/zip.so
      extension = ${pkgs.php83Extensions.pdo_mysql}/lib/php/extensions/pdo_mysql.so
      error_reporting = E_ALL & ~E_DEPRECATED
    '';
    extraConfig = ''
      DavLockDB /mnt/c/MT/repos/davlock
    '';
    virtualHosts = {
      "192.168.137.5" = {
        documentRoot = "/mnt/c/MT/repos";
        extraConfig = ''
          # Let Apache generate DAV-compatible indexes
          DirectoryIndex enabled
          php_admin_flag engine off
          <Directory "/mnt/c/MT/repos">
            Require all granted
            Dav On
          </Directory>
          <FilesMatch \.php$>
            SetHandler None
          </FilesMatch>
        '';
      };
      "brb" = {
        documentRoot = "/mnt/c/MT/repos/zabbix/ui";
        extraConfig = ''
          Listen 8889
        '';
      };
      "repairs" = {
        documentRoot = "/mnt/c/MT/repos/zabbix";
      };
      "domains" = {
        documentRoot = "/mnt/c/MT/repos/zabbix/ui";
      };
      "bgrs" = {
        documentRoot = "/mnt/c/MT/repos/zabbix";
      };
      "partman" = {
        documentRoot = "/mnt/c/MT/repos/zabbix";
      };
      "akaunting" = {
        documentRoot = "/mnt/c/MT/repos/zabbix";
        extraConfig = ''
          <Directory "/mnt/c/MT/repos/zabbix">
            AllowOverride All
          </Directory>
        '';
      };
      "invoiceplane" = {
        documentRoot = "/mnt/c/MT/repos/zabbix";
        extraConfig = ''
          <Directory "/mnt/c/MT/repos/zabbix">
            AllowOverride All
          </Directory>
        '';
      };
      "ledgersmb" = (utils.makeVhostProxy { host = "127.0.0.1:5762"; }) // {
        forceSSL = false;
        useACMEHost = null;
      };
    };
  };
}
