{ ... }:

{
  # SilentSDDM / Rei: original animated blue/violet background and left login.
  # The upstream NixOS module supplies the Qt multimedia/QML dependencies/fonts.
  programs.silentSDDM = {
    enable = true;
    theme = "rei";
    settings = {
      "LoginScreen.VirtualKeyboard".start-hidden = true;
    };
  };
}
