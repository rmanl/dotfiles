[
  # make it harder to influence slab cache layout
  "slab_nomerge"
  # randomizes page allocator freelist, improving security by
  # making page allocations less predictable
  "page_alloc.shuffle=1"
  # enables kernel page table isolation, which mitigates meltdown and
  # prevents some kaslr bypasses
  "pti=on"
  # randomizes the kernel stack offset on each syscall
  # making attacks that rely on a deterministic stack layout difficult
  "randomize_kstack_offset=on"
  # disables vsyscalls, they've been replaced with vdso
  "vsyscall=none"
  # disables debugfs, which exposes sensitive info about the kernel
  "debugfs=off"
  # certain exploits cause an "oops", this makes the kernel panic if an "oops" occurs
  "oops=panic"
  # only alows kernel modules that have been signed with a valid key to be loaded
  # making it harder to load malicious kernel modules
  # can make virtualbox or nvidia drivers unusable
  "module.sig_enforce=1"
  # prevents user space code excalation
  "lockdown=confidentiality"
]
