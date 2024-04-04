class DuckdbSubstrait < Formula
  desc "Embeddable SQL OLAP Database Management System"
  homepage "https://www.duckdb.org"
  url "https://github.com/drin/duckdb-substrait.git",
      tag:      "v0.10.1",
      revision: "db213416115a757f9d929efae75d6988bdeaf166"
  license "MIT"

  # TODO: how to leverage this for shorter build times
  # bottle do
  #   sha256 cellar: :any,                 arm64_sonoma:   "fdcc4e161ffd32a58fa4b501bcb48979bd6dd17f4e658d7fe0bbe0253ab5dca6"
  #   sha256 cellar: :any,                 arm64_ventura:  "144c60147341b4c5d84226ab7946f10b9b0047eca6a61a35eedb1d6a2da94179"
  #   sha256 cellar: :any,                 arm64_monterey: "b2b0a23fba24c6f2a66ee6ff117c664ef006fb650026961ae01043b2984945a6"
  #   sha256 cellar: :any,                 sonoma:         "efd30f76771d15bc94f654b6c338e8c302dd8287b7c531bc376087267f96811a"
  #   sha256 cellar: :any,                 ventura:        "150dfcfc6ebdeb54b0036538e181db0c113149a09c598536c1679c26ca12cb51"
  #   sha256 cellar: :any,                 monterey:       "6da7e844ceeaceb5deb61d2de2bf9b6b16fd688f1d7d53856089abf14d6a2ebd"
  #   sha256 cellar: :any_skip_relocation, x86_64_linux:   "eeafe8bd37364ecaae03afe78fab87433697263046c278f84d506cabc4da639e"
  # end

  depends_on      "cmake"  => :build
  depends_on      "ninja"  => :build
  uses_from_macos "python" => :build

  conflicts_with  "duckdb", because: "duckdb-substrait independently installs duckdb"

  def install
    cmake_args = %W[
      -DCMAKE_BUILD_TYPE=Release
      -DEXTENSION_STATIC_BUILD=1
      -DBUILD_EXTENSIONS=tpch;json
      -DDUCKDB_EXTENSION_NAMES=substrait
      -DDUCKDB_EXTENSION_SUBSTRAIT_SHOULD_LINK=1
      -DDUCKDB_EXTENSION_SUBSTRAIT_LOAD_TESTS=1
      -DDUCKDB_EXTENSION_SUBSTRAIT_PATH=#{buildpath}
      -DDUCKDB_EXTENSION_SUBSTRAIT_TEST_PATH=#{buildpath}/test
      -DDUCKDB_EXTENSION_SUBSTRAIT_INCLUDE_PATH=#{buildpath}/src/include
      -GNinja
    ]

    # Get all submodules
    system 'git', 'submodule', 'init'
    system 'git', 'submodule', 'update', '--recursive', '--remote'

    # Build artifacts
    build_dpath = 'build-dir-release'
    src_dpath   = 'duckdb'

    # The DuckDB Makefile assume `pwd` is the duckdb dir, we try to not
    # make any assumptions
    system 'cmake', '-S', src_dpath, '-B', build_dpath, *cmake_args, *std_cmake_args
    system 'cmake',   '--build', build_dpath, '--config', 'Release'
    system 'cmake', '--install', build_dpath
  end

  test do
    path = testpath/'weather.sql'
    path.write <<~EOS
      CREATE TABLE weather (temp INTEGER);
      INSERT INTO weather (temp) VALUES (40), (45), (50);
      SELECT AVG(temp) FROM weather;
    EOS

    expected_output = <<~EOS
      ┌─────────────┐
      │ avg("temp") │
      │   double    │
      ├─────────────┤
      │        45.0 │
      └─────────────┘
    EOS

    assert_equal expected_output, shell_output("#{bin}/duckdb < #{path}")
  end
end
