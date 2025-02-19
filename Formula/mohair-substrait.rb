class MohairSubstrait < Formula
  desc     "Shared library to interface with Substrait and Mohair protocols"
  homepage "https://github.com/drin/mohair-substrait.git"
  url      "https://github.com/drin/mohair-substrait.git",
    tag: "v3.0.1",
    commit: "17385055440d6124f723d904fc0d51b8b5e79b4b"
  license "Apache-2.0"

  depends_on "abseil-static"   => :build
  depends_on "protobuf-static" => :build

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
    sys_options = %W[
      -DCC=clang
      -DCXX=clang++
      -Ddefault_library=both
    ]

    system 'meson', 'setup'    , build_dpath
    system 'meson', 'configure', *std_meson_args, *sys_options, build_dpath

    system 'meson', 'compile', '-C', build_dpath
    system 'meson', 'install', '-C', build_dpath
  end
end
