{ pkgs ? import <nixpkgs> {}}:
with pkgs;
mkShell {
  nativeBuildInputs = [
    flutter
  ];

  LD_LIBRARY_PATH = lib.makeLibraryPath [
    sqlite.out
  ];
}
