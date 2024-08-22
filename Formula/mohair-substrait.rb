class MohairSubstrait < Formula
  desc     "Shared library to interface with Substrait and Mohair protocols"
  homepage "https://github.com/drin/mohair-substrait.git"
  url      "https://github.com/drin/mohair-substrait.git",
    tag: "v0.1.2",
    commit: "7c210c96b1d19316d6ad23c6be4a0eb1856014b3"
  license "Apache-2.0"

  depends_on "abseil"   => :build
  depends_on "protobuf" => :build

  depends_on "meson"    => :build
  depends_on "cmake"    => :build
  depends_on "ninja"    => :build

  def install
    # Get all submodules
    system 'git', 'submodule', 'init'
    system 'git', 'submodule', 'update', '--recursive', '--remote'

    # Build artifacts
    build_dpath = 'build-dir-release'

    # Build and install the code
    system 'meson', 'setup'    , build_dpath
    system 'meson', 'configure', *std_meson_args, build_dpath

    system 'meson', 'compile', '-C', build_dpath
    system 'meson', 'install', '-C', build_dpath
  end
end
