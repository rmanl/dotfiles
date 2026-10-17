{
  outputs = _: {
    domain = "example.invalid";
    email.gitHub = "ci@example.invalid";
    location = { };
    networking.ports.tcp.ssh = 22;
    userFullName = "CI Stub";
  };
}
