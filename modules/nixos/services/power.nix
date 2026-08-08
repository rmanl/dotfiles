{
  flake.nixosModules.power = {
    services = {
      irqbalance.enable = true;
      logind.settings.Login.HandlePowerKey = "suspend";
      power-profiles-daemon.enable = false;

      tlp = {
        enable = true;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance"; # intel only
          CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power"; # intel only
          CPU_BOOST_ON_AC = 1;
          CPU_BOOST_ON_BAT = 0;
          CPU_HWP_DYN_BOOST_ON_AC = 1; # intel only
          CPU_HWP_DYN_BOOST_ON_BAT = 1; # intel only
          START_CHARGE_THRESH_BAT0 = 50;
          STOP_CHARGE_THRESH_BAT0 = 90;
          NVME_APST_ON_AC = 0;
          NVME_APST_ON_BAT = 1;
          AHCI_RUNTIME_PM_ON_AC = "on";
          AHCI_RUNTIME_PM_ON_BAT = "auto";
          PCIE_ASPM_ON_AC = "default";
          PCIE_ASPM_ON_BAT = "powersave";
          RUNTIME_PM_ON_AC = "on";
          RUNTIME_PM_ON_BAT = "auto";
          USB_AUTOSUSPEND = 1;
          WIFI_PWR_ON_AC = "off";
          WIFI_PWR_ON_BAT = "on";
          WOL_DISABLE = "Y";
        };
      };
    };

    boot.kernel.sysctl = {
      # vm performance
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 100;
      "vm.dirty_ratio" = 10;
      "vm.dirty_background_ratio" = 5;
      "vm.dirty_writeback_centisecs" = 1500;

      # network performance
      "net.core.rmem_max" = 2500000;
    };
  };
}
