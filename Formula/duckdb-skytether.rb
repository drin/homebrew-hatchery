class DuckdbSkytether < Formula
  desc "Embeddable SQL OLAP Database Management System"
  homepage "https://www.duckdb.org"
  url "https://github.com/drin/duckdb-skytether.git",
    tag: "v0.4.0",
    commit: "96087e2efce994e438abe1d9acdfd816535d060d"
  license "MIT"

  depends_on      "cmake"  => :build
  depends_on      "ninja"  => :build
  uses_from_macos "python" => :build

  conflicts_with  "duckdb",
    because: "duckdb-skytether independently installs duckdb"

  conflicts_with  "duckdb-substrait",
    because: "duckdb-skytether independently includes duckdb-substrait"

  def install
    cmake_args = %W[
      -DCMAKE_BUILD_TYPE=Release
      -DEXTENSION_STATIC_BUILD=1
      -DBUILD_EXTENSIONS=tpch;json
      -DDUCKDB_EXTENSION_NAMES=substrait;arrow
      -DDUCKDB_EXTENSION_SUBSTRAIT_SHOULD_LINK=1
      -DDUCKDB_EXTENSION_SUBSTRAIT_LOAD_TESTS=1
      -DDUCKDB_EXTENSION_SUBSTRAIT_PATH=#{buildpath}/subprojects/duckdb-substrait
      -DDUCKDB_EXTENSION_SUBSTRAIT_TEST_PATH=#{buildpath}/subprojects/duckdb-substrait/test
      -DDUCKDB_EXTENSION_SUBSTRAIT_INCLUDE_PATH=#{buildpath}/subprojects/duckdb-substrait/src/include
      -DDUCKDB_EXTENSION_ARROW_SHOULD_LINK=1
      -DDUCKDB_EXTENSION_ARROW_LOAD_TESTS=1
      -DDUCKDB_EXTENSION_ARROW_PATH=#{buildpath}/subprojects/duckdb-arrow
      -DDUCKDB_EXTENSION_ARROW_TEST_PATH=#{buildpath}/subprojects/duckdb-arrow/test
      -DDUCKDB_EXTENSION_ARROW_INCLUDE_PATH=#{buildpath}/subprojects/duckdb-arrow/src/include
      -GNinja
    ]

    # Get all submodules
    system 'git', 'submodule', 'init'
    system 'git', 'submodule', 'update', '--recursive', '--remote'

    # Build artifacts
    build_dpath = 'build-dir-release'
    src_dpath   = 'subprojects/duckdb'

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
