use strict;
use warnings;

use Test::More 'no_plan';

use File::Path;
use File::Temp;

BEGIN { use_ok("Tree::File::YAML"); }

my $tree = Tree::File::YAML->new("examples/simple");

my $data = { aliens => { invaders   => [ qw(zim v orbs decepticons)    ],
                         'lost way' => [ "alf", "ray walston", "e.t."  ] },
             armies => { german     => { soldiers  => [ qw(schultz klink) ],
                                         prisoners => [ "hogan", "chuck norris", 
                                                        "the rest of the gang" ] } },
             stooges=> [ qw(larry moe curly shemp) ]
           };

isa_ok($tree,                "Tree::File::YAML", "the root");

is_deeply($tree->data, $data, "total initial data matches");

my $tmpdir = File::Temp::tempdir( CLEANUP => 1 );

File::Path::rmtree($tmpdir); # to ensure that it will be created on request

# write out the tree unchanged
$tree->write($tmpdir);
ok(1, "survived writing of unchanged copy");

# read the written copy and compare it
my $copied = Tree::File::YAML->new($tmpdir);
isa_ok($copied, "Tree::File::YAML");

is_deeply($tree->data, $copied->data, "copied and reloaded unchanged");

ok(-d "$tmpdir",         "simple (root) created as a dir");
ok(-f "$tmpdir/stooges", "simple/stooges created as a normal file");
ok(-d "$tmpdir/armies",  "simple/armies created as a dir");

# create and write out one branch of the tree
ok(
  $copied->set("/armies/german/ranks", { colonel => "Oberst" }),
  "create a value"
);

$copied->get("/armies/german")->write();
ok(1, "survived write of existing branch w/new data");

TODO: {
  local $TODO = "figure out how to write branches without writing parents";

  eval { $copied->get("/armies/german/ranks")->write(); };
  ok(not($@), "survived write of new data under file branch");
}
