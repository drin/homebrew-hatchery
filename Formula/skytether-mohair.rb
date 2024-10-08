class SkytetherMohair < Formula
  desc     "Mohair is the query processing layer of Skytether for cooperative query decomposition"
  homepage "https://research.aldrinmontana.com/"
  url      "https://github.com/drin/mohair.git",
    tag: "v0.3.0",
    revision: "40bccb6a0ec8004c0ee3b7b4fafe963d62fed4b6"
  license  "Apache-2.0"

  depends_on "meson" => :build
  depends_on "cmake" => :build
  depends_on "ninja" => :build

  depends_on "mohair-substrait" => :build

  def install
    build_dpath = 'build-dir'

    ohai "#{std_meson_args}"

    # Build artifacts
    system 'meson', 'setup'  , *std_meson_args, build_dpath, '.'
    system 'meson', 'compile',            '-C', build_dpath
    system 'meson', 'install',            '-C', build_dpath
  end
end
