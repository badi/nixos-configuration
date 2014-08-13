

{ pkgs }:

let

  cronScriptHeader = pkgs.writeScript "cron-script-header" ''
    ${pkgs.coreutils}/bin/echo "=================================="
    ${pkgs.coreutils}/bin/date
  '';

  zfsSnapshotKeepCount = "90";
  zfsRootPool = "tank";

  zfsSnapshotScript = pkgs.writeScript "zfs-snapshot" ''
    $(${cronScriptHeader})

    pool=$1
    keep=$2

    zfs=${pkgs.linuxPackages.zfs}/sbin/zfs
    grep=${pkgs.gnugrep}/bin/grep
    sort=${pkgs.coreutils}/bin/sort
    head=${pkgs.coreutils}/bin/head
    tail=${pkgs.coreutils}/bin/tail
    xargs=${pkgs.findutils}/bin/xargs

    $zfs snapshot -r $pool@$(date +%F-%T)
    $zfs list -t snapshot -o name \
         | $grep $pool@ \
	 | $sort -r \
	 | $tail -n +$keep \
	 | $xargs -n 1 $zfs destroy -r
    '';

in

{

  enable = true;
  systemCronJobs = [

  #    /-------------------- minute
  #    | /------------------ hour
  #    | | /---------------- day of month
  #    | | | /-------------- month
  #    | | | | /------------ day of week
  #    | | | | |
  #    * * * * *

     # every day at 6am
      "0 6 * * * root ${zfsSnapshotScript} ${zfsRootPool} ${zfsSnapshotKeepCount} >>/var/log/zfs-snapshot.log 2>&1"

      # every day at 6:30 am
      "30 6 * * * root bash -l -c 'nix-channel --update'"
    ];

}