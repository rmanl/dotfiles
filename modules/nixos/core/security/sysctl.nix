{
  "fs.suid_dumpable" = 0;
  # prevent pointer leaks
  "kernel.kptr_restrict" = 2;
  # restrict kernel log to cap_syslog capability
  "kernel.dmesg_restrict" = 1;
  # note: certian container runtimes or browser sandboxes might rely on the following
  # restrict ebpf to the cap_bpf capability
  "kernel.unprivileged_bpf_disabled" = 1;
  # should be enabled along with bpf above
  # "net.core.bpf_jit_harden" = 2;
  # restrict loading tty line disciplines to the cap_sys_module
  "dev.tty.ldisk_autoload" = 0;
  # prevent exploit of use-after-free flaws
  "vm.unprivileged_userfaultfd" = 0;
  # kexec is used to boot another kernel during runtime and can be abused
  "kernel.kexec_load_disabled" = 1;
  # kernel self-protection
  # sysrq exposes a lot of potentially dangerous debugging functionality to unprivileged users
  # 4 makes it so a user can only use the secure attention key. a value of 0 would disable completely
  "kernel.sysrq" = 0;
  # disable unprivileged user namespaces, note: docker, nh, and other apps may need this
  # "kernel.unprivileged_userns_clone" = 0; # commented out because it makes nh and other programs fail
  # restrict all usage of performance events to the cap_perfmon capability
  "kernel.perf_event_paranoid" = 3;

  # network
  # protect against syn flood attacks (denial of service attack)
  "net.ipv4.tcp_syncookies" = 1;
  # protection against time-wait assassination
  "net.ipv4.tcp_rfc1337" = 1;
  # enable source validation of packets received (prevents ip spoofing)
  "net.ipv4.conf.default.rp_filter" = 1;
  "net.ipv4.conf.all.rp_filter" = 1;

  "net.ipv4.conf.all.accept_redirects" = 0;
  "net.ipv4.conf.default.accept_redirects" = 0;
  "net.ipv4.conf.all.secure_redirects" = 0;
  "net.ipv4.conf.default.secure_redirects" = 0;
  # protect against ip spoofing
  "net.ipv6.conf.all.accept_redirects" = 0;
  "net.ipv6.conf.default.accept_redirects" = 0;
  "net.ipv4.conf.all.send_redirects" = 0;
  "net.ipv4.conf.default.send_redirects" = 0;

  # prevent man-in-the-middle attacks
  "net.ipv4.icmp_echo_ignore_all" = 1;

  # ignore icmp request, helps avoid smurf attacks
  "net.ipv4.conf.all.forwarding" = 0;
  "net.ipv4.conf.default.accept_source_route" = 0;
  "net.ipv4.conf.all.accept_source_route" = 0;
  "net.ipv6.conf.all.accept_source_route" = 0;
  "net.ipv6.conf.default.accept_source_route" = 0;
  # reverse path filtering causes the kernel to do source validation of
  "net.ipv6.conf.all.forwarding" = 0;
  "net.ipv6.conf.all.accept_ra" = 0;
  "net.ipv6.conf.default.accept_ra" = 0;

  ## tcp hardening
  # prevent bogus icmp errors from filling up logs.
  "net.ipv4.icmp_ignore_bogus_error_responses" = 1;

  # disable tcp sack
  "net.ipv4.tcp_sack" = 0;
  "net.ipv4.tcp_dsack" = 0;
  "net.ipv4.tcp_fack" = 0;

  # userspace
  # restrict usage of ptrace
  "kernel.yama.ptrace_scope" = 2;

  # aslr memory protection (64-bit systems)
  "vm.mmap_rnd_bits" = 32;
  "vm.mmap_rnd_compat_bits" = 16;

  # only permit symlinks to be followed when outside of a world-writable sticky directory
  "fs.protected_symlinks" = 1;
  "fs.protected_hardlinks" = 1;
  # prevent creating files in potentially attacker-controlled environments
  "fs.protected_fifos" = 2;
  "fs.protected_regular" = 2;

  # randomize memory
  "kernel.randomize_va_space" = 2;
  # exec shield (stack protection)
  "kernel.exec-shield" = 1;

  ## tcp optimization
  # tcp fast open is a tcp extension that reduces network latency by packing
  # data in the sender’s initial tcp syn. setting 3 = enable tcp fast open for
  # both incoming and outgoing connections:
  "net.ipv4.tcp_fastopen" = 3;
  # bufferbloat mitigations + slight improvement in throughput & latency
  "net.ipv4.tcp_congestion_control" = "bbr";
  "net.core.default_qdisc" = "cake";
}
