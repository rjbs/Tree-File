#!perl

use strict;
use warnings;

use File::Path qw(rmtree);
use Test::More 'no_plan';
use YAML qw(DumpFile);

BEGIN { use_ok("Tree::File::YAML"); }

my $dir = "examples/nonlockable";
my $lockfile = "examples/.lock";

SKIP: {
  skip "can't test nonlockability of a dir when root!", 4 if ($> == 0);
  mkdir $dir if not -d $dir;
  DumpFile("$dir/test", 1);
  -e $lockfile or open(my $fh, ">$lockfile") or die "Can't open $lockfile: $!";
  chmod 0000, $lockfile;
  
  my $config = eval { Tree::File::YAML->new($dir); };
  is($@, "", "can load root");
  ok($config->{readonly}, "config has gone readonly");
  is($config->get("test"), 1, "config is still readable");

  eval {
    $config->set(write => 2);
    $config->write;
  };
  like($@, qr/set called on readonly tree/, "write fails (readonly)");
  
  rmtree([$dir]);
  chmod 0644, $lockfile;
  unlink $lockfile;
}
