{ pkgs, lib, ... }:
{
  services.httpd.enable = true;
  services.httpd.adminAddr = "post@mysite.com";
  services.httpd.enablePHP = true; # oof... not a great idea in my opinion
  services.httpd.configFile = pkgs.writeText "httpd.conf" "# my custom config file ...";

  services.httpd.virtualHosts."example.org" = {
    documentRoot = "/mnt/c/MT/repos/zabbix";
  };
  # systemd.tmpfiles.rules = [
  #   "d /var/www/mysite.com"
  #   "f /var/www/mysite.com/index.php - - - - <?php phpinfo();"
  # ];
}
