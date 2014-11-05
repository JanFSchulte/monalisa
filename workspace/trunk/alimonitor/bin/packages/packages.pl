


use strict;

use AliEn::UI::Catalogue::LCM::Computer;

my $c=AliEn::UI::Catalogue::LCM::Computer->new({user=>'aliprod'}) or exit(-2);

print "Connected\n";

my (@all)=$c->execute("packman", "-silent", "list", "-all", "-force" );

#print "@all\n";

open (FILE, ">sites.tmp/ALL.packman");
print FILE "@all\n";
close FILE;


my ($sites)=$c->execute("queue", "-silent", "info");

#print Dumper(@$sites);

foreach  my $s  (@$sites) {
  my $site=$s->{site};
  $site =~ s/^.*::(.*)::.*$/$1/;

  print "Doing $s->{site} and $site \n";
  my ($p)=$c->execute("queue", "info", $s->{site}, "-jdl");
  my $packages=${$p}[0]->{jdl};
  $packages =~ /InstalledPackages\s*=\s*{([^}]*)/sm or next;
  $packages=$1;
  $packages =~ s/"//g;
  $packages =~ s/,//g;
  $packages =~ s/^\s*//gm;
  print "HELLO $packages\n";
  open (FILE, "> sites.tmp/$site");
  print FILE $packages;
  close FILE; 
}

