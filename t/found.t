#!perl

use strict;
use warnings;
use Test::More 'no_plan';
BEGIN { use_ok 'Tree::File::YAML' }

{ # test default behavior
  my $tree = Tree::File::YAML->new("examples/simplest");
  isa_ok($tree, "Tree::File::YAML");
  is(
     $tree->get("/date"),
     "November 5th",
     "get returns value unchanged"
    );
}

{ # test with custom closure
  my $found = sub {
    my ($self, $id, $data) = @_;
    if ($id eq "date") {
      $data = sprintf("the events for %s were %s",
		      $data,
		      $self->get("events")
		     );
    } elsif (ref $data eq "ARRAY") {
      $data = join ", ", map "'$_'", @$data;
    }
    return $data;
  };
  my $tree = Tree::File::YAML->new("examples/simplest",
				   { found => $found });
  isa_ok($tree, "Tree::File::YAML");
  is(
     $tree->get("/date"),
     "the events for November 5th were 'gunpowder treason', 'plot'",
     "get returns modified value"
    );
}
