{pkgs, config, lib, ... }:

let
  themeFile = config.lib.stylix.colors {
    template = builtins.readFile ./template.mustache;
    extension = ".json";
  };

  themePackageJson = pkgs.writeText "package.json" (builtins.toJSON {
    name = "stylix";
    displayName = "Stylix";
    description = "Theme configured as part of your NixOS configuration.";
    version = "0.0.0";
    publisher = "Stylix";
    engines.vscode = "^1.43.0";
    categories = [ "Themes" ];
    contributes.themes = [{
      label = "Stylix";
      uiTheme = "vs";
      path = "./themes/stylix.json";
    }];
    "__metadata" = {
      id = "6f0404ee-0463-4def-80f1-515adc5389fc";
      publisherDisplayName = "Stylix";
      publisherId = "b78a1e2c-a0b3-413a-8196-1b3e8ca3865b";
    };
  });

  themeExtension = let
    vscodeExtUniqueId = "Stylix.stylix";
    vscodeExtPublisher = "Stylix";
    version = "0.0.0";
  in pkgs.runCommandLocal "stylix-vscode" {
    inherit vscodeExtUniqueId vscodeExtPublisher version;
  } ''
    mkdir -p $out/share/vscode/extensions/${vscodeExtUniqueId}/themes
    ln -s ${themePackageJson} $out/share/vscode/extensions/${vscodeExtUniqueId}/package.json
    ln -s ${themeFile} $out/share/vscode/extensions/${vscodeExtUniqueId}/themes/stylix.json
  '';

in {
  options.stylix.targets.vscode.enable =
    config.lib.stylix.mkEnableTarget "VSCode" true;

  config = lib.mkIf config.stylix.targets.vscode.enable {
    programs.vscode = {
      extensions = [ themeExtension ];
      userSettings."workbench.colorTheme" = "Stylix";
    };
  };
}

