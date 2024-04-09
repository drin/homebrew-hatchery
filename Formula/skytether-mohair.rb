class SkytetherMohair < Formula
  desc     "Mohair is the query processing layer of Skytether for cooperative query decomposition"
  license  "Apache-2.0"
  homepage "https://research.aldrinmontana.com/"
  url      "https://github.com/drin/mohair.git",
      tag:      "v0.1.0",
      revision: "e5d0cef2d524e4445f256036f6387f668dedbb13"

  depends_on "git-lfs"                => [:build, :test]
  depends_on "cmake"                  => :build
  depends_on "ninja"                  => :build
  depends_on "apache-arrow-substrait" => :build
  depends_on "duckdb-substrait"       => :build

  uses_from_macos "python"            => :build

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
