{
  description = "template";

  outputs = _: {
    templates.default = {
      path = ./plutarch;
      description = "Template for Plutarch project";
    };
  };
}
