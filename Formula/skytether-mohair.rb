class SkytetherMohair < Formula
  desc     "Mohair is the query processing layer of Skytether for cooperative query decomposition"
  license  "Apache-2.0"
  homepage "https://research.aldrinmontana.com/"
  url      "https://github.com/drin/mohair.git",
      tag:      "v0.1.0",
      revision: "8b9b943f389c879614c1a09062fbaa67d43f0419"

  depends_on      "cmake"            => :build
  depends_on      "ninja"            => :build
  depends_on      "git-lfs"          => [:build, :test]
  uses_from_macos "python"           => :build
  depends_on      "duckdb-substrait"

  def install
    build_dirpath = 'build-dir-release'

    # Build artifacts
    system 'meson',   'setup',       build_dirpath, *std_meson_args
    system 'meson', 'compile', '-C', build_dirpath
    system 'meson', 'install', '-C', build_dirpath
  end

  test do
    # Checkout a file for testing
    test_infile   = buildpath / 'resources' / 'examples' / 'average-expression.substrait'
    test_expected = buildpath / 'resources' / 'examples' / 'result.split-avg-expr.txt'

    system 'git', 'lfs',    'fetch', '--', test_infile
    system 'git', 'lfs',    'fetch', '--', test_expected

    system 'git', 'lfs', 'checkout', '--', test_infile
    system 'git', 'lfs', 'checkout', '--', test_expected

    assert_equal shell_output("cat #{test_expected}"), shell_output("#{bin}/mohair #{test_infile}")
  end
end
