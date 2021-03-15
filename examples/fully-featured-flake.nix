{
  description = "A highly awesome system configuration.";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/release-20.09;
    unstable.url = github:nixos/nixpkgs/nixos-unstable;
    nur.url = github:nix-community/NUR;
    utils.url = github:gytis-ivaskevicius/flake-utils-plus;

    home-manager = {
      url = github:nix-community/home-manager/master;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim = {
      url = github:neovim/neovim?dir=contrib;
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };


  outputs = inputs@{ self, nixpkgs, unstable, nur, utils, home-manager, neovim }:
    utils.lib.systemFlake {

      # Required arguments
      inherit self inputs;

      # Default architecture to be used for `nixosProfiles` defaults to "x86_64-linux". Might get renamed in near future
      defaultSystem = "aarch64-linux";

      # Channel definitions. `channels.<name>.{input,overlaysFunc,config}`
      channels.nixpkgs = {
        # Channel input to import
        input = nixpkgs;

        # Channel specific overlays
        overlaysFunc = channels: [
          (final: prev: { inherit (channels.unstable) zsh; })
        ];

        # Channel specific configuration. Overwrites `channelsConfig` argument
        config = {
          allowUnfree = false;
        };
      };

      # Additional channel input
      channels.unstable.input = unstable;
      channels.unstable.overlaysFunc = channels: [
        (final: prev: {
          neovim-nightly = neovim.defaultPackage.${prev.system};
        })
      ];


      # Default configuration values for `channels.<name>.config = {...}`
      channelsConfig = {
        allowBroken = true;
        allowUnfree = true;
      };

      # Profiles, gets parsed into `nixosConfigurations`
      nixosProfiles = {
        # Profile name / System hostname
        Morty = {
          # System architecture. Defaults to `defaultSystem` argument
          system = "x96_64-linux";
          # <name> of the channel to be used
          channelName = "unstable";
          # Extra arguments to be passed to the modules. Overwrites `sharedExtraArgs` argument
          extraArgs = {
            abc = 123;
          };
          # Host specific configuration. Same as `sharedModules`
          modules = [
            (import ./configurations/Morty.host.nix)
          ];
        };
      };

      # Extra arguments to be passed to modules
      sharedExtraArgs = { inherit utils; };

      # Overlays, gets applied to all `channels.<name>.input`
      sharedOverlays = [
        # Overlay imported from `./overlays`. (Defined below)
        self.overlays
        # Nix User Repository overlay
        nur.overlay
      ];

      # Shared modules/configurations between `nixProfiles`
      sharedModules = [
        home-manager.nixosModules.home-manager
        (import ./modules)
        {
          # Sets sane `nix.*` defaults. Please refer to implementation/readme for more details.
          nix = utils.lib.nixDefaultsFromInputs inputs;

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];



      ### Postfix of keys below might change in soon future.

      # Evaluates to `packages.<system>.attributeKey = "attributeValue"`
      packagesFunc = channels: { attributeKey = "attributeValue"; };
      # Evaluates to `defaultPackage.<system>.attributeKey = "attributeValue"`
      defaultPackageFunc = channels: { attributeKey = "attributeValue"; };
      # Evaluates to `apps.<system>.attributeKey = "attributeValue"`
      appsFunc = channels: { attributeKey = "attributeValue"; };
      # Evaluates to `defaultApp.<system>.attributeKey = "attributeValue"`
      defaultAppFunc = channels: { attributeKey = "attributeValue"; };
      # Evaluates to `devShell.<system>.attributeKey = "attributeValue"`
      devShellFunc = channels: { attributeKey = "attributeValue"; };
      # Evaluates to `checks.<system>.attributeKey = "attributeValue"`
      checksFunc = channels: { attributeKey = "attributeValue"; };

      # All other values gets passed down to the flake
      overlay = import ./overlays;
      abc = 132;
      # etc

    };
}




