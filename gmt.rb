class Gmt < Formula
  desc "Tools for processing and displaying xy and xyz datasets"
  homepage "http://gmt.soest.hawaii.edu/"
  url "ftp://ftp.soest.hawaii.edu/gmt/gmt-5.4.2-src.tar.xz"
  mirror "ftp://ftp.star.nesdis.noaa.gov/pub/sod/lsa/gmt/gmt-5.4.2-src.tar.xz"
  mirror "ftp://gd.tuwien.ac.at/pub/gmt/gmt-5.4.2-src.tar.xz"
  mirror "ftp://ftp.iris.washington.edu/pub/gmt/gmt-5.4.2-src.tar.xz"
  sha256 "ddcd63094aeda5a60f541626ed7ab4a78538d52dea24ba915f168e4606e587f5"

  bottle do
    sha256 "6d25598cde38cd50a97d1297c270397d5fdb2c7a92ab6317f4441e331bfefaae" => :sierra
    sha256 "b6ae9d8fae42bd8a3794cc30099a6e4cd724d70dbb23ea8ba7110573268a37e1" => :el_capitan
    sha256 "51ff3a7285a3af1126ef9ce4fcaf3e27dbbba1fddd9b1244cb6a31f5b8aad8cf" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "gdal"
  depends_on "netcdf"
  depends_on "fftw"
  depends_on "pcre"

  conflicts_with "gmt4", :because => "both versions install the same binaries"

  resource "gshhg" do
    url "ftp://ftp.soest.hawaii.edu/gmt/gshhg-gmt-2.3.7.tar.gz"
    mirror "ftp://ftp.star.nesdis.noaa.gov/pub/sod/lsa/gmt/gshhg-gmt-2.3.7.tar.gz"
    mirror "ftp://gd.tuwien.ac.at/pub/gmt/gshhg-gmt-2.3.7.tar.gz"
    mirror "ftp://ftp.iris.washington.edu/pub/gmt/gshhg-gmt-2.3.7.tar.gz"
    sha256 "9bb1a956fca0718c083bef842e625797535a00ce81f175df08b042c2a92cfe7f"
  end

  resource "dcw" do
    url "ftp://ftp.soest.hawaii.edu/gmt/dcw-gmt-1.1.2.tar.gz"
    mirror "ftp://ftp.star.nesdis.noaa.gov/pub/sod/lsa/gmt/dcw-gmt-1.1.2.tar.gz"
    mirror "ftp://gd.tuwien.ac.at/pub/gmt/dcw-gmt-1.1.2.tar.gz"
    mirror "ftp://ftp.iris.washington.edu/pub/gmt/dcw-gmt-1.1.2.tar.gz"
    sha256 "f719054f8d657e7b10b5182d4c15bc7f38ef7483ed05cdaa9f94ab1a0008bfb6"
  end

  def install
    gshhgdir = buildpath/"gshhg"
    dcwdir = buildpath/"dcw"

    args = std_cmake_args.concat %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DGMT_INSTALL_TRADITIONAL_FOLDERNAMES:BOOL=FALSE
      -DGMT_INSTALL_MODULE_LINKS:BOOL=TRUE
      -DGMT_DOCDIR=#{share}/doc/gmt
      -DGMT_MANDIR=#{man}
      -DGSHHG_ROOT=#{gshhgdir}
      -DCOPY_GSHHG:BOOL=TRUE
      -DDCW_ROOT=#{dcwdir}
      -DCOPY_DCW:BOOL=TRUE
      -DNETCDF_ROOT=#{Formula["netcdf"].opt_prefix}
      -DGDAL_ROOT=#{Formula["gdal"].opt_prefix}
      -DPCRE_ROOT=#{Formula["pcre"].opt_prefix}
      -DFFTW3_ROOT=#{Formula["fftw"].opt_prefix}
      -DLICENSE_RESTRICTED:BOOL=FALSE
      -DFLOCK:BOOL=TRUE
    ]

    mkdir "build" do
      gshhgdir.install resource("gshhg")
      dcwdir.install resource("dcw")
      system "cmake", "..", *args
      system "make", "install"
    end
  end

  def caveats; <<-EOS.undent
      GMT 5 is mostly (but not 100%) compatible with previous versions.
      Moreover, the compatibility mode is expected to exist only during a
      transitional period.

      If you want to continue using GMT 4:
      `brew install gmt4`

      We agreed to the `triangle` license
      (http://www.cs.cmu.edu/~quake/triangle.html) for you.
      If this is unacceptable you should uninstall.
    EOS
  end

  test do
    # Test command sourced from Purdue University
    # Prof. Eric Calais, 'Graphs and Maps with GMT'
    # http://web.ics.purdue.edu/~ecalais/teaching/gmt/GMT_1.pdf
    system "#{bin}/pscoast -R0/360/-70/70 -Jm1.2e-2i -Ba60f30/a30f15 -Dc -G240 -W1/0 -P > GMT_mercator.ps"
    assert File.exist? "GMT_mercator.ps"
  end
end
