{ stdenv, lib, fetchFromGitHub, gettext, zsh, pinentry, cryptsetup, gnupg, makeWrapper }:

stdenv.mkDerivation rec {
  name = "tomb-${version}";
  version = "2.5";

  src = fetchFromGitHub {
    owner  = "dyne";
    repo   = "Tomb";
    rev    = "v${version}";
    sha256 = "1wk1aanzfln88min29p5av2j8gd8vj5afbs2gvarv7lvx1vi7kh1";
  };

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    # if not, it shows .tomb-wrapped when running
    substituteInPlace tomb \
      --replace 'TOMBEXEC=$0' 'TOMBEXEC=tomb'
  '';

  buildPhase = ''
    # manually patch the interpreter
    sed -i -e "1s|.*|#!${zsh}/bin/zsh|g" tomb
  '';

  installPhase = ''
    install -Dm755 tomb       $out/bin/tomb
    install -Dm644 doc/tomb.1 $out/share/man/man1/tomb.1

    ln -s ${gnupg}/bin/gpg $out/bin/gpg

    wrapProgram $out/bin/tomb \
      --prefix PATH : $out/bin:${lib.makeBinPath [ cryptsetup gettext pinentry ]}
  '';

  meta = with stdenv.lib; {
    description = "File encryption on GNU/Linux";
    homepage    = https://www.dyne.org/software/tomb/;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ peterhoeg ];
    platforms   = platforms.linux;
  };
}
