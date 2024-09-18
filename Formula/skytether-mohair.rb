class SkytetherMohair < Formula
  desc     "Mohair is the query processing layer of Skytether for cooperative query decomposition"
  homepage "https://research.aldrinmontana.com/"
  url      "https://github.com/drin/mohair.git",
    tag: "v0.2.0",
    revision: "54fd307a510d11d90f2575bddc48c6a8e3af6467"
  license  "Apache-2.0"

  depends_on "meson" => :build
  depends_on "cmake" => :build
  depends_on "ninja" => :build

  def install
    build_dpath = 'build-dir'

    ohai "#{std_meson_args}"

    # Build artifacts
    system 'meson', 'setup'  , *std_meson_args, build_dpath, '.'
    system 'meson', 'compile',            '-C', build_dpath
    system 'meson', 'install',            '-C', build_dpath
  end
end
