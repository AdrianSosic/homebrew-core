class Kpcli < Formula
  desc "Command-line interface to KeePass database files"
  homepage "https://kpcli.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/kpcli/kpcli-3.3.pl"
  sha256 "04de984d6b79bdeb84689bf8eaa0e2e3aa8756b7cca9ffdf36e1a9d1c0f1cdfc"
  revision 1

  bottle do
    cellar :any
    sha256 "5f59575c4711bcc72d546ce158c202fdd38bc548471ff35067bce662d071a8a2" => :catalina
    sha256 "6911dd04b9f3bbe7dc2cfc4c6fc53079e4a71b40c1718c64291d3f1086fc4c8b" => :mojave
    sha256 "c1b3100690e04b1b00e9034c6a65e2117e088788efc0d849f8cc9cb350219a0e" => :high_sierra
  end

  depends_on "readline"

  resource "File::KeePass" do
    url "https://cpan.metacpan.org/authors/id/R/RH/RHANDOM/File-KeePass-2.03.tar.gz"
    sha256 "c30c688027a52ff4f58cd69d6d8ef35472a7cf106d4ce94eb73a796ba7c7ffa7"
  end

  resource "Crypt::Rijndael" do
    url "https://cpan.metacpan.org/authors/id/L/LE/LEONT/Crypt-Rijndael-1.13.tar.gz"
    sha256 "cd7209a6dfe0a3dc8caffe1aa2233b0e6effec7572d76a7a93feefffe636214e"
  end

  resource "Sort::Naturally" do
    url "https://cpan.metacpan.org/authors/id/B/BI/BINGOS/Sort-Naturally-1.03.tar.gz"
    sha256 "eaab1c5c87575a7826089304ab1f8ffa7f18e6cd8b3937623e998e865ec1e746"
  end

  resource "Term::ShellUI" do
    url "https://cpan.metacpan.org/authors/id/B/BR/BRONSON/Term-ShellUI-0.92.tar.gz"
    sha256 "3279c01c76227335eeff09032a40f4b02b285151b3576c04cacd15be05942bdb"
  end

  resource "Term::Readline::Gnu" do
    url "https://cpan.metacpan.org/authors/id/H/HA/HAYASHI/Term-ReadLine-Gnu-1.35.tar.gz"
    sha256 "575d32d4ab67cd656f314e8d0ee3d45d2491078f3b2421e520c4273e92eb9125"
  end

  resource "Data::Password" do
    url "https://cpan.metacpan.org/authors/id/R/RA/RAZINF/Data-Password-1.12.tar.gz"
    sha256 "830cde81741ff384385412e16faba55745a54a7cc019dd23d7ed4f05d551a961"
  end

  resource "Clipboard" do
    url "https://cpan.metacpan.org/authors/id/S/SH/SHLOMIF/Clipboard-0.22.tar.gz"
    sha256 "9fdb4dfc2e9bc2f3990b5b71649094dfe83aa12172c5a1809cf7e8b3be295ca7"
  end

  resource "Mac::Pasteboard" do
    url "https://cpan.metacpan.org/authors/id/W/WY/WYANT/Mac-Pasteboard-0.011.tar.gz"
    sha256 "bd8c4510b1e805c43e4b55155c0beaf002b649fe30b6a7841ff05e7399ba02a9"
  end

  resource "Capture::Tiny" do
    url "https://cpan.metacpan.org/authors/id/D/DA/DAGOLDEN/Capture-Tiny-0.46.tar.gz"
    sha256 "5d7a6a830cf7f2b2960bf8b8afaac16a537ede64f3023827acea5bd24ca77015"
  end

  def install
    ENV.prepend_create_path "PERL5LIB", libexec/"lib/perl5"
    ENV.prepend_path "PERL5LIB", libexec/"lib"

    resources = [
      "File::KeePass",
      "Crypt::Rijndael",
      "Sort::Naturally",
      "Term::ShellUI",
      "Data::Password",
      "Clipboard",
      "Mac::Pasteboard",
      "Capture::Tiny",
    ]
    resources.each do |r|
      resource(r).stage do
        system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}"
        system "make", "install"
      end
    end

    resource("Term::Readline::Gnu").stage do
      # Prevent the Makefile to try and build universal binaries
      ENV.refurbish_args

      system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}",
                     "--includedir=#{Formula["readline"].opt_include}",
                     "--libdir=#{Formula["readline"].opt_lib}"
      system "make", "install"
    end

    libexec.install "kpcli-#{version}.pl" => "kpcli"
    chmod 0755, libexec/"kpcli"
    (bin/"kpcli").write_env_script("#{libexec}/kpcli", :PERL5LIB => ENV["PERL5LIB"])
  end

  test do
    system bin/"kpcli", "--help"
  end
end
