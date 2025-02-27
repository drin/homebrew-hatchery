class SkytetherMohair < Formula
  desc     "Mohair is the query processing layer of Skytether for cooperative query decomposition"
  homepage "https://research.aldrinmontana.com/"
  url      "https://github.com/drin/mohair.git",
    tag: "v2.2.0",
    revision: "358e9c1430b8b4c933e6b97a9592be813aa98041"
  license  "Apache-2.0"

  depends_on "meson"   => :build
  depends_on "cmake"   => :build
  depends_on "ninja"   => :build

  # depends_on "git"     => :build
  # depends_on "git-lfs" => :build

  depends_on "mohair-substrait"       => :build
  depends_on "apache-arrow-substrait" => :build

  def install
    build_dpath = 'build-dir'

    ohai "#{std_meson_args}"

    # Build artifacts
    system 'meson', 'setup'  , *std_meson_args, build_dpath, '.'
    system 'meson', 'compile',            '-C', build_dpath
    system 'meson', 'install',            '-C', build_dpath
  end
end
