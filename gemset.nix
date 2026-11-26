{
  addressable = {
    dependencies = ["public_suffix"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qnyv445xndwiks86azzq22pih1b3nlx5q6nbbb1vw5d070bj4sy";
      type = "gem";
    };
    version = "2.10.0";
  };
  ansi = {
    dependencies = ["logger"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1aam7qgkvri5bj75jv2bp5frxm4zzz0vpmwn618mz8bmlcqahr84";
      type = "gem";
    };
    version = "1.6.1";
  };
  ast = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10yknjyn0728gjn6b5syynvrvrwm66bhssbxq8mkhshxghaiailm";
      type = "gem";
    };
    version = "2.4.3";
  };
  bigdecimal = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rng45p4vc3f6nac44cnylwch7rj4zsff3icdz6c7garwpjy3sv1";
      type = "gem";
    };
    version = "4.1.3";
  };
  builder = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pw3r2lyagsxkm71bf44v5b74f7l9r7di22brbyji9fwz791hya9";
      type = "gem";
    };
    version = "3.3.0";
  };
  decode = {
    dependencies = ["prism" "rbs"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0id8n5a020kpmdzjs6gvgpm1lj6i3maw1vpshw4vdw86s953crzm";
      type = "gem";
    };
    version = "0.30.0";
  };
  diff-lcs = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1mb3nfmnv5gyaxcw10fzdr4jrvx198bq38akiw7vai99xi95v2kh";
      type = "gem";
    };
    version = "2.0.0";
  };
  drb = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wrkl7yiix268s2md1h6wh91311w95ikd8fy8m5gx589npyxc00b";
      type = "gem";
    };
    version = "2.2.3";
  };
  ffi = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bbmph141hwnn3m4k8hx8nhy1imfjpz87h595ww4n1xf5r6b2gcx";
      type = "gem";
    };
    version = "1.17.4";
  };
  gem_kit = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0dx9w041lqzr4jd0m9as0v5v6n3fj2hcg74p2gyswr2y2a6zc5v9";
      type = "gem";
    };
    version = "0.2.0";
  };
  gem_kit-release = {
    dependencies = ["gem_kit" "thor"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "03j729pb5a2i3is4am4mzikwbr89vjxkcsijjj5abplia3z2n6y9";
      type = "gem";
    };
    version = "0.4.0";
  };
  json = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1n1v9rhb19cnf1a89s6yvvhw394jy8qnqx9sg8bn12g5zpwcrrrw";
      type = "gem";
    };
    version = "3.1.0";
  };
  json-schema = {
    dependencies = ["addressable" "bigdecimal"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wxxilfijidxfsv51smfbbif3cgf1fardc4z2pyqnd3jsw9n3gy0";
      type = "gem";
    };
    version = "6.2.1";
  };
  language_server-protocol = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1w5p8c2145lmqzr25bxh4ikzjm6k8y1k5lriqqdpw9pq730w1wjy";
      type = "gem";
    };
    version = "3.17.0.6";
  };
  lint_roller = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11yc0d84hsnlvx8cpk4cbj6a4dz9pk0r1k29p0n1fz9acddq831c";
      type = "gem";
    };
    version = "1.1.0";
  };
  logger = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00q2zznygpbls8asz5knjvvj2brr3ghmqxgr83xnrdj4rk3xwvhr";
      type = "gem";
    };
    version = "1.7.0";
  };
  minitest = {
    dependencies = ["drb" "prism"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vh733a365lw2dpa8zvdmr35715kfrm9hqsli8g67248maakadzz";
      type = "gem";
    };
    version = "6.1.0";
  };
  minitest-reporters = {
    dependencies = ["ansi" "builder" "minitest" "ruby-progressbar"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11531cvklpc1j7m8il5i70dqrwmnd7qlsi95wn51glrsnw7jircc";
      type = "gem";
    };
    version = "1.8.0";
  };
  ostruct = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04nrir9wdpc4izqwqbysxyly8y7hsfr4fsv69rw91lfi9d5fv8lm";
      type = "gem";
    };
    version = "0.6.3";
  };
  parallel = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vvs2sar7wnw70j1jc1kv1k23m5grc0ci3bbrcf6mkh18683wnpp";
      type = "gem";
    };
    version = "2.3.0";
  };
  parser = {
    dependencies = ["ast" "racc"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13z5jwb190xmvxq9kmdz82mi306bkl78h4fqw9g446dryxmggy32";
      type = "gem";
    };
    version = "3.3.14.0";
  };
  prettier_print = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ybgks9862zmlx71zd4j20ky86fsrp6j6m0az4hzzb1zyaskha57";
      type = "gem";
    };
    version = "1.2.1";
  };
  prism = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11ggfikcs1lv17nhmhqyyp6z8nq5pkfcj6a904047hljkxm0qlvv";
      type = "gem";
    };
    version = "1.9.0";
  };
  public_suffix = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08znfv30pxmdkjyihvbjqbvv874dj3nybmmyscl958dy3f7v12qs";
      type = "gem";
    };
    version = "7.0.5";
  };
  racc = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0byn0c9nkahsl93y9ln5bysq4j31q8xkf2ws42swighxd4lnjzsa";
      type = "gem";
    };
    version = "1.8.1";
  };
  rainbow = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0smwg4mii0fm38pyb5fddbmrdpifwv22zv3d3px2xx497am93503";
      type = "gem";
    };
    version = "3.1.1";
  };
  rake = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "009p524zl0p0kfa65nii8wdmaigkmawv9pbvlcffky7islmmp0nb";
      type = "gem";
    };
    version = "13.4.2";
  };
  rbs = {
    dependencies = ["logger" "prism" "tsort"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0x067q8cdam4kv5dc09iq2nzca8qm2kdl0dr22gc0ny0vj3bixsi";
      type = "gem";
    };
    version = "4.2.0";
  };
  regexp_parser = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0fwarpnqm6b0vy4yx3mhrx12zi0v435d0ywm8q4z1rjp9y0lf18x";
      type = "gem";
    };
    version = "2.13.4";
  };
  rubocop = {
    dependencies = ["json" "language_server-protocol" "lint_roller" "parallel" "parser" "rainbow" "regexp_parser" "rubocop-ast" "ruby-progressbar" "unicode-display_width"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1xigcyc13kn6lc0gs59m2zw5p7y508bqm1jgacx1rsg88sngwxzx";
      type = "gem";
    };
    version = "1.92.3";
  };
  rubocop-ast = {
    dependencies = ["ast" "parser" "prism" "racc"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0x6mrbfs8x8qz1abnpczb4wgam0g110r6by7whm51ml5hk988y82";
      type = "gem";
    };
    version = "1.53.0";
  };
  rubocop-disable_syntax = {
    dependencies = ["lint_roller" "rubocop"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gppdbw0pxl5ygadykr7gi1mknzp0pv6bv4mx5s2zz5kfdbn8q8y";
      type = "gem";
    };
    version = "0.2.0";
  };
  rubocop-nathank = {
    dependencies = ["decode" "lint_roller" "prism" "rubocop"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gsim1h8va09kflcsi899bg5dq7sdlwsp3qji6b8s1rbh7nr2wwd";
      type = "gem";
    };
    version = "2.1.0";
  };
  ruby-progressbar = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cwvyb7j47m7wihpfaq7rc47zwwx9k4v7iqd9s1xch5nm53rrz40";
      type = "gem";
    };
    version = "1.13.0";
  };
  syntax_tree = {
    dependencies = ["prettier_print"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ggi6p7xxjsj42q8pp0yz6z7dbwlbr6fjbs4qnafr667jab5mqjn";
      type = "gem";
    };
    version = "6.3.0";
  };
  thor = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wsy88vg2mazl039392hqrcwvs5nb9kq8jhhrrclir2px1gybag3";
      type = "gem";
    };
    version = "1.5.0";
  };
  thor-completion = {
    dependencies = ["json-schema" "thor"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0dm2z4ci3av1f0zzwv1clyhpps86dbl14mibh0ld96557kik5rmb";
      type = "gem";
    };
    version = "0.0.5";
  };
  tsort = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17q8h020dw73wjmql50lqw5ddsngg67jfw8ncjv476l5ys9sfl4n";
      type = "gem";
    };
    version = "0.2.0";
  };
  unicode-display_width = {
    dependencies = ["unicode-emoji"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04xnl0zwpjjvxipd6rdnxkm11pfhbhhi3179yzv51nqi9dmacyjb";
      type = "gem";
    };
    version = "3.3.0";
  };
  unicode-emoji = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1kp89lja8ii7l6f0bq5vdxq1p3kxr3a2qmmhdc38qdwh6akjzh0i";
      type = "gem";
    };
    version = "4.3.0";
  };
}
