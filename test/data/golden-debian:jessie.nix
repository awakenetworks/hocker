{
  config.docker.images.debian = pkgs.fetchdocker {
    name = "debian";
    registry = "https://registry-1.docker.io/v2/";
    repository = "library";
    imageName = "debian";
    tag = "jessie";
    imageConfig = pkgs.fetchDockerConfig {
      inherit registry repository imageName tag;
      sha256 = "1rwinmvfc8jxn54y7qnj82acrc97y7xcnn22zaz67y76n4wbwjh5";
    };
    imageLayers = let
      layer0 = pkgs.fetchDockerLayer {
        inherit registry repository imageName tag;
        layerDigest = "cd0a524342efac6edff500c17e625735bbe479c926439b263bbe3c8518a0849c";
        sha256 = "1744l0c8ag5y7ck9nhr6r5wy9frmaxi7xh80ypgnxb7g891m42nd";
      };
      in [ layer0 ];
  };
}