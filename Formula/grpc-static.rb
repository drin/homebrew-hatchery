class GrpcStatic < Formula
  desc "Next generation open source RPC library and framework"
  homepage "https://grpc.io/"
  license "Apache-2.0"
  url "https://github.com/grpc/grpc.git",
      tag:      "v1.70.1",
      revision: "5e099002c1600c580ebe1e6741f8ff8b182ffea4"
  head "https://github.com/grpc/grpc.git", branch: "master"

  # There can be a notable gap between when a version is tagged and a
  # corresponding release is created, so we check releases instead of the Git
  # tags. Upstream maintains multiple major/minor versions and the "latest"
  # release may be for an older version, so we have to check multiple releases
  # to identify the highest version.
  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_releases
  end

  # bottle do
  #   sha256 cellar: :any,                 arm64_sequoia: "4e31fe75933f4ce9e0e785f10cdb1dd5f40f8c53a047d718c488a414299fd8e8"
  #   sha256 cellar: :any,                 arm64_sonoma:  "e150fc7f960fbd9fe7857763326f856a57bd046f79f2287f391741fdb806cb97"
  #   sha256 cellar: :any,                 arm64_ventura: "03c8e59489b68d2dcc2136bdc9778ea64d4cee9d0bf79b9bac2d4d0fdb5f3d6b"
  #   sha256 cellar: :any,                 sonoma:        "341f8b7373ba10ec2619bbf50b33f49400297e8aa6cc2c3e8ad1601b4a4eaba0"
  #   sha256 cellar: :any,                 ventura:       "ef1733175ff5b0b6e7e74a4a4e900439804e1965769cb974b9e4dcd7df3e35a1"
  #   sha256 cellar: :any_skip_relocation, x86_64_linux:  "1938279adb82b44de2f05d19919890ac246385ac35e3eac82833628caf603dc7"
  # end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "cmake"    => :build
  depends_on "libtool"  => :build
  depends_on "pkgconf"  => :test
  depends_on "abseil-static"
  depends_on "c-ares"
  depends_on "openssl@3"
  depends_on "protobuf-static"
  depends_on "re2"

  uses_from_macos "zlib"

  on_macos do
    depends_on "llvm" => :build if DevelopmentTools.clang_build_version <= 1100
  end

  conflicts_with "grpc",
    because: "grpc-static installs grpc as a static library and is otherwise the same as grpc"

  fails_with :clang do
    build 1100
    cause "Requires C++17 features not yet implemented"
  end

  def install
    #ENV.llvm_clang if OS.mac? && (DevelopmentTools.clang_build_version <= 1100)
    ENV.llvm_clang if OS.mac? && (DevelopmentTools.clang_build_version <= 1100)
    args = %W[
      -DCMAKE_CXX_STANDARD=17
      -DCMAKE_CXX_STANDARD_REQUIRED=TRUE
      -DCMAKE_INSTALL_RPATH=#{rpath}
      -DgRPC_BUILD_TESTS=OFF
      -DgRPC_INSTALL=ON
      -DgRPC_ABSL_PROVIDER=package
      -DgRPC_CARES_PROVIDER=package
      -DgRPC_PROTOBUF_PROVIDER=package
      -DgRPC_SSL_PROVIDER=package
      -DgRPC_ZLIB_PROVIDER=package
      -DgRPC_RE2_PROVIDER=package
    ]

    linker_flags = []
    linker_flags += %w[-undefined dynamic_lookup] if OS.mac?

    args << "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,#{linker_flags.join(",")}" if linker_flags.present?

    build_dir = "_build"
    system "cmake", "-S", ".", "-B", build_dir, *args, *std_cmake_args
    system "cmake",       "--build", build_dir
    system "cmake",     "--install", build_dir

    # The following are installed manually, so need to use CMAKE_*_LINKER_FLAGS
    linker_flags += %W[-rpath #{rpath} -rpath #{rpath(target: HOMEBREW_PREFIX/"lib")}]
    cli_args = %W[
      -DCMAKE_EXE_LINKER_FLAGS=-Wl,#{linker_flags.join(",")}
      -DgRPC_BUILD_TESTS=ON
      -DgRPC_ABSL_PROVIDER=package
      -DgRPC_CARES_PROVIDER=package
      -DgRPC_PROTOBUF_PROVIDER=package
      -DgRPC_SSL_PROVIDER=package
      -DgRPC_ZLIB_PROVIDER=package
      -DgRPC_RE2_PROVIDER=package
    ]

    cli_build_dir = "_cli_build"
    system "cmake", "-S", ".", "-B", cli_build_dir, *cli_args, *std_cmake_args
    system "cmake",       "--build", cli_build_dir, "--target", "grpc_cli"

    bin.install "#{cli_build_dir}/grpc_cli"
    lib.install (buildpath/"#{cli_build_dir}").glob(shared_library("libgrpc++_test_config", "*"))
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <grpc/grpc.h>
      int main() {
        grpc_init();
        grpc_shutdown();
        return GRPC_STATUS_OK;
      }
    CPP
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["openssl@3"].opt_lib/"pkgconfig"
    pkg_config_flags = shell_output("pkg-config --cflags --libs libcares protobuf re2 grpc++").chomp.split
    system ENV.cc, "test.cpp", "-L#{Formula["abseil-static"].opt_lib}", *pkg_config_flags, "-o", "test"
    system "./test"

    output = shell_output("#{bin}/grpc_cli ls localhost:#{free_port} 2>&1", 1)
    assert_match "Received an error when querying services endpoint.", output
  end
end

