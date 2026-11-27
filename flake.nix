{
  description = "gob | a ruby -> go transpiler";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        ruby = pkgs.ruby_4_0;
        go = pkgs.go_1_27;

        # bundix wraps itself with a bundler built for nixpkgs' *default* ruby,
        # so `bundix -l` would resolve the lockfile against 3.4 and reject every
        # gem that wants >= 4.0.
        bundix = pkgs.bundix.override {
          bundler = pkgs.bundler.override { inherit ruby; };
        };

        gemset = import ./gemset.nix;

        ffiPack = {
          x86_64-linux = { platform = "x86_64-linux-gnu"; sha256 = "0bbmph141hwnn3m4k8hx8nhy1imfjpz87h595ww4n1xf5r6b2gcx"; };
          aarch64-linux = { platform = "aarch64-linux-gnu"; sha256 = "1pw0q28nvllqysx7g9gv6vy2gz6csbiwm8rx37hzbn7zj5pz025j"; };
          aarch64-darwin = { platform = "arm64-darwin"; sha256 = "06q06ylk32yma6ms84sd6cxhlcvp1sbbyal58q51n98r2jpil1qr"; };
          x86_64-darwin = { platform = "x86_64-darwin"; sha256 = "15m4rlngxc2ff6pb4b1a11fbvkxl16vn4jgndh4kacng4c2kjw5a"; };
        }.${system};

        gems = pkgs.bundlerEnv {
          name = "gob-gems";
          inherit ruby;
          gemfile = ./Gemfile;
          lockfile = ./Gemfile.lock;
          groups = [ "default" "development" ];
          gemset = gemset
            // pkgs.lib.optionalAttrs (gemset ? ffi) {
              ffi = gemset.ffi // {
                inherit (ffiPack) platform;
                source = gemset.ffi.source // { inherit (ffiPack) sha256; };
              };
            };
        };

        ast-grep = pkgs.runCommand "ast-grep-0.51.3" { } ''
          install -Dm755 ${pkgs.fetchurl {
            url = "https://github.com/n-at-han-k/rust-builds/releases/download/ast-grep-v0.51.3/ast-grep";
            hash = "sha256-PIuXm5sDJQMnTgQ5xqqsa6Kffo9+gcCM6evFcakPViw=";
          }} $out/bin/ast-grep
        '';

        # matz/spinel attaches only a source archive to its releases (its
        # release.yml runs `make dist`), so there is nothing upstream to
        # fetchurl. Our fork builds the installed prefix per system:
        # github.com/n-at-han-k/spinel/.github/workflows/binaries.yml
        spinelVersion = "2026.10.25-8315-gb09015061";

        # Unpacked rather than installed as one file like ast-grep above,
        # because spinel is a prefix, not a binary: it shells out to `cc` to
        # link each program it emits, and finds libspinel_rt.a and
        # include/ruby/ by resolving /proc/self/exe and looking for a sibling
        # lib/ (exe_dir/resolve_lib_dir in its src/main.c). No prefix is baked
        # in at compile time, so the tree works from the store, and bin/spinel
        # is a relative symlink into lib/spinel/ that /proc/self/exe follows
        # back to the real directory.
        #
        # The Linux executables are statically linked, so they need no
        # patchelf to run here -- the same reason ast-grep's raw install works
        # (that one is static-pie). The bundled libspinel_rt*.a are ordinary
        # glibc objects on purpose: the cc in this shell is what links them
        # into every program spinel compiles, so they have to match its libc,
        # not the builder's.
        spinel = pkgs.runCommand "spinel-${spinelVersion}" { } ''
          mkdir -p $out
          tar -xJf ${pkgs.fetchurl {
            url = "https://github.com/n-at-han-k/spinel/releases/download/binaries-${spinelVersion}/spinel-${spinelVersion}-${system}.tar.xz";
            hash = {
              x86_64-linux = "sha256-s4CC9U2XND6NJzNoNnHvSaMM7xfRfHULeIiSh6Y3+xw=";
              aarch64-linux = "sha256-0N1VrwoyVEsRrF3D3lBp1KlZYSZAYKPC5HGmaprkqCI=";
              aarch64-darwin = "sha256-LPviZrv6NrT7s/oEvIXfQ0j92kJsoV6gZGtWkVs0C1w=";
              x86_64-darwin = "sha256-XBdcBlIrOYcGKqwTxKtPJi2wqqisBOIRTs9m9p6DKMI=";
            }.${system};
          }} -C $out
        '';

        gobVersion =
          builtins.head (builtins.match ''.*VERSION = "([^"]+)".*''
            (builtins.readFile ./lib/gob/version.rb));

        # Only the Ruby that gets compiled. `src = ./.` would drag in refs/
        # (ten submodule checkouts) and res/, and any of it changing would
        # rebuild this for no reason.
        gobSource = pkgs.lib.fileset.toSource {
          root = ./.;
          fileset = pkgs.lib.fileset.unions [ ./lib ./exe ];
        };

        # Spinel has no RubyGems. `require "name"` resolves against -I feature
        # roots at compile time and nothing is searched at runtime -- see its
        # docs/require.md -- so the dependency sources bundlerEnv has already
        # unpacked into the store are handed straight to the compiler. The gem
        # set stays the one Gemfile.lock pins, via gemset.nix, for the devshell
        # too; this only takes a writable copy of it to prune.
        #
        # Copy one gem's source out of the store so a build-time patch can be
        # applied to it. -L matters: the gem directories inside a bundlerEnv
        # are symlinks into per-gem store paths, so a plain cp -r copies links
        # back into the read-only store and every patch fails with EROFS.
        #
        # Each patch ends in an assertion, so a gem bump that moves the code
        # out from under a sed fails here instead of silently compiling the
        # unpatched source.
        patchedGem = { name, glob, script }:
          pkgs.runCommand "${name}-spinel-src" { } ''
            mkdir -p $out
            cp -rL ${gems}/lib/ruby/gems/*/gems/${glob}/. $out/
            chmod -R u+w $out
            ${script}
          '';

        # spinel compiles `autoload` targets eagerly -- with no runtime loading
        # there is no later moment to do it in -- so RakeCompat has to survive
        # the subset even though gob never uses it. It does not: it defines
        # methods in an instance_eval on a dynamic receiver. Drop the autoload.
        thorSrc = patchedGem {
          name = "thor";
          glob = "thor-[0-9]*";
          script = ''
            sed -i '/autoload :RakeCompat/d' $out/lib/thor/base.rb
            ! grep -q RakeCompat $out/lib/thor/base.rb
          '';
        };

        # spinel cannot hold Regexp::Parser beside the parser gem's top-level
        # Parser -- "spinel cannot keep the two apart; rename one of them" --
        # and the nested one is much the cheaper to move: 14 references in
        # regexp_parser, 3 in rubocop, nothing else in the set. The declaration
        # is `class Regexp::Parser`, so the same rewrite catches it.
        #
        # \b after Parser keeps Regexp::ParserError intact while still
        # rewriting Regexp::Parser::Error.
        regexpParserRename = ''
          find $out -name '*.rb' -exec \
            sed -i 's/\bRegexp::Parser\b/Regexp::ReParser/g' {} +
        '';

        regexpParserSrc = patchedGem {
          name = "regexp_parser";
          glob = "regexp_parser-[0-9]*";
          script = regexpParserRename + ''
            # version.rb is the one place that opens the class nested
            # (`class Regexp` / `class Parser`) rather than as a path.
            sed -i 's/^\( *\)class Parser$/\1class ReParser/' \
              $out/lib/regexp_parser/version.rb
            ! grep -rqn 'Regexp::Parser\b' $out --include='*.rb'
            grep -q 'class ReParser' $out/lib/regexp_parser/version.rb
          '';
        };

        rubocopSrc = patchedGem {
          name = "rubocop";
          glob = "rubocop-[0-9]*";
          script = regexpParserRename + ''
            ! grep -rqn 'Regexp::Parser\b' $out --include='*.rb'
          '';
        };

        # The gems whose sources are patched above; their store copies are
        # skipped so the patched root is the only one the compiler sees.
        patchedRoots = [ thorSrc regexpParserSrc rubocopSrc ];

        staticLink = pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isGnu
          "--link -static";
        #
        # Note `exe/gob`'s own `$LOAD_PATH.unshift` is inert under spinel: it
        # keeps $LOAD_PATH as a plain Array that resolves nothing. The roots
        # have to arrive as -I, which is why they are assembled here rather
        # than exported as RUBYLIB.
        # STATUS: this does not build yet, and the wall is not a prune away.
        # After thor, the next refusal is
        #
        #   regexp_parser/parser.rb:6: a class or module named Parser under the
        #   builtin Regexp is not supported beside another definition of
        #   Parser: spinel cannot keep the two apart
        #
        # i.e. Regexp::Parser (regexp_parser) against the parser gem's
        # top-level Parser. Both arrive via rubocop, and rubocop cannot be
        # dropped: every rule in lib/gob/validation/rules/ subclasses
        # RuboCop::Cop::Base, and validation runs on the transpile path
        # (lib/gob.rb) and on every command (lib/gob/cli/base.rb), not just
        # `vet`.
        #
        # Worth knowing before anyone attacks this: the rules do not use
        # rubocop's AST at all. Rules::Cop#on_new_investigation parses with
        # SyntaxTree and walks that, so rubocop is only the harness -- registry,
        # badge, autocorrect, formatter. Owning that plumbing would take
        # rubocop, parser, regexp_parser and prism out of the graph in one go.
        gob = pkgs.stdenv.mkDerivation {
          pname = "gob";
          version = gobVersion;
          src = gobSource;

          # spinel forks the C compiler to link what it emits, and looks it up
          # as plain `cc` -- which is what stdenv puts on PATH.
          nativeBuildInputs = [ spinel ];

          # libc.a, for the -static link below. Without it the link stops at
          # "cannot find -lc: have you installed the static version of the c
          # library?". glibc-only; a Darwin build has no static libSystem and
          # needs none, since libSystem sits at a fixed path on every mac.
          buildInputs = pkgs.lib.optional pkgs.stdenv.hostPlatform.isGnu
            pkgs.glibc.static;

          buildPhase = ''
            runHook preBuild

            # Whole-program inference over this dependency graph overflows the
            # default 16MB stack, and spinel dies on SIGSEGV with no
            # diagnostic at all -- it looks like a compiler bug rather than a
            # resource limit, so it is worth being explicit about.
            ulimit -s unlimited

            # Patched roots first, so a patched gem's require_relative chain
            # stays inside the patched tree. bundler is skipped outright: it is
            # here only because bundlerEnv includes it, nothing in lib/ or exe/
            # requires it, and it vendors its own thor with the same defect.
            roots=(-I lib)
            for dir in ${pkgs.lib.concatMapStringsSep " " (d: "${d}/lib") patchedRoots}; do
              roots+=(-I "$dir")
            done
            for dir in ${gems}/lib/ruby/gems/*/gems/*/lib; do
              case "$dir" in
                */gems/thor-[0-9]*|*/gems/regexp_parser-[0-9]*) continue ;;
                */gems/rubocop-[0-9]*|*/gems/bundler-[0-9]*) continue ;;
              esac
              roots+=(-I "$dir")
            done
            echo "spinel: $(( ''${#roots[@]} / 2 )) feature roots, $(cc --version | head -1)"

            # -static is the whole point of the exercise: a gob that runs
            # without a Ruby, and without this Nix store either. A spinel
            # program needs only libc and libm, so there is nothing else to
            # carry. Note a static glibc cannot do getpwnam, so `~` expansion
            # through the password database is lost (HOME still works).
            spinel exe/gob "''${roots[@]}" ${staticLink} -o gob

            echo "--- linkage of the result ---"
            file gob

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            install -Dm755 gob $out/bin/gob
            runHook postInstall
          '';

          meta = {
            description = "gob, compiled ahead of time by spinel (no Ruby runtime)";
            mainProgram = "gob";
          };
        };

      in
      {

        packages = {
          inherit gob;
          default = gob;
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.pkg-config ];

          buildInputs = [
            gems
            gems.wrappedRuby

            ast-grep
            spinel
            bundix
            pkgs.go-task

            go
            pkgs.gopls

            pkgs.git
            pkgs.libyaml
            pkgs.openssl
          ];

          shellHook = /* bash */ ''
            export BUNDLE_GEMFILE="$PWD/Gemfile"
            export BUNDLE_FROZEN=false
            export RUBYLIB="$PWD/lib''${RUBYLIB:+:$RUBYLIB}"
            export PATH="$PWD/exe''${PATH:+:$PATH}"

            # Services run this shell too, sometimes as a user who cannot write
            # the checkout; skip the regen rather than dump a backtrace.
            if [ -w gemset.nix ]; then bundix -l; fi
          '';
        };
      });
}
