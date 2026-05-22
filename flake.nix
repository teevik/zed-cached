{
  description = "Cached Zed editor builds";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zed.url = "github:zed-industries/zed";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      zed,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        livekit-libwebrtc = nixpkgs.legacyPackages.${system}.livekit-libwebrtc;

        # HACK: remove when https://github.com/zed-industries/zed/issues/54225 is fixed
        package = zed.packages.${system}.default;
        patchedPackage = package.overrideAttrs (oldAttrs: {
          env = (oldAttrs.env or { }) // {
            LK_CUSTOM_WEBRTC = livekit-libwebrtc;
          };
          cargoArtifacts = oldAttrs.cargoArtifacts.overrideAttrs (oldAttrs': {
            env = (oldAttrs'.env or { }) // {
              LK_CUSTOM_WEBRTC = livekit-libwebrtc;
            };
          });
        });
      in
      {
        packages = {
          default = patchedPackage;
          zed-editor = patchedPackage;
        };
      }
    );
}
