{ lib
, buildDotnetModule
, fetchFromGitHub
, dotnetCorePackages
, dbus
, libxcursor
, libxi
, libxrandr
, libGL
, mpv
, tesseract5
}:

buildDotnetModule rec {
  pname = "subtitleedit";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "SubtitleEdit";
    repo = "subtitleedit";
    tag = "v${version}";
    hash = "sha256-3WwRXD1JhZisJ/1sOF91PvrklfjCiI2Ena4i8AdLcm0=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  env.APP_VER_DISPLAY = version;
  env.APP_VER_FULL = "${version}.0";

  enableParallelBuilding = false;

  projectFile = "src/ui/UI.csproj";
  nugetDeps = ./deps.json;

  executables = [ "SubtitleEdit" ];

  runtimeDeps = [
    dbus
    libxcursor
    libxi
    libxrandr
    libGL
  ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ tesseract5 ])
  ];

  dotnetFlags = [
    "-p:TargetFramework=net10.0"
  ];

  postPatch = ''
    substituteInPlace src/ui/Logic/VideoPlayers/LibMpvDynamic/LibMpvDynamicPlayer.cs --replace-fail '"/usr/local/lib",' '"/usr/local/lib", "${lib.getBin mpv}/bin",'
    substituteInPlace src/ui/Logic/Config/Se.cs --replace-fail 'folders.Add("/usr/local/bin");' 'folders.Add("/usr/local/bin"); folders.Add("${lib.getBin tesseract5}/bin");'
  '';

  postInstall = ''
    install -Dm644 -t $out/share/applications installer/flatpak/dk.nikse.subtitleedit.desktop
    install -Dm655 -t $out/share/icons/hicolor/256x256/apps src/ui/Assets/SE.png
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Subtitle editor";
    longDescription = ''
      With Subtitle Edit you can easily adjust a subtitle if it is out of sync with
      the video in several different ways. You can also use it for making
      new subtitles from scratch (using the time-line /waveform/spectrogram)
      or for translating subtitles.
    '';
    homepage = "https://nikse.dk/subtitleedit";
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      # deps
      binaryBytecode
      # some deps
      binaryNativeCode
    ];
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ /*lilyinstarlight*/ ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    mainProgram = "SubtitleEdit";
  };
}
