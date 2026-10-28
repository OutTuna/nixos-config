{ appimageTools, fetchurl, lib }:

let
  pname = "helium";
  version = "0.20.1.1";
  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
    sha256 = "d4b789b25d0a9ae12c76671e444e8a85edcf828e0419c678d18c41fb1ac3030e";
  };
  contents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;
  extraInstallCommands = ''
    install -Dm644 ${contents}/helium.desktop $out/share/applications/helium.desktop
    substituteInPlace $out/share/applications/helium.desktop \
      --replace-fail "Exec=helium" "Exec=$out/bin/helium"
    install -Dm644 ${contents}/helium.png $out/share/icons/hicolor/256x256/apps/helium.png
  '';
  meta = {
    description = "Private, fast, and honest web browser";
    homepage = "https://helium.computer";
    mainProgram = "helium";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.gpl3Only;
  };
}
