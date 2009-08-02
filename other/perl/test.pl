use MixrClient;

$p = MixrClient->new( "localhost", 9900 );

print "Store key => value : ";
if( $p->store( "key", "value" ) ) {
  print "ok!\n";
} else {
  print "error!\n";
}

print "Store cle => valeur : ";
if( $p->store( "cle", "valeur" ) ) {
  print "ok!\n";
}   else {
  print "error!\n";
}

print "Get key = ";
my $r = $p->get( "key" );
print $r . "\n";

print "List of keys : \n";
@keys = $p->keys();
foreach $k ( @keys ) {
  print "- $k\n";
}

print "List of values : \n";
@keys = $p->values();
foreach $k ( @keys ) {
  print "- $k\n";
}

my %h = $p->to_hash();
while(($k, $v) = each(%h)) {
  print "$k => $v\n";
}

print "Delete cle : ";
print $p->delete( "cle" )."\n";

print "Is empty : ";
if( $p->is_empty() ) {
  print "yes!\n";
} else {
  print "no!\n";
}

print "Has key 'key' : ";
if( $p->has_key( "key" ) ) {
  print "yes!\n";
} else {
  print "no!\n";
}

print "Has key 'cle' : ";
if( $p->has_key( "cle" ) ) {
  print "yes!\n";
} else {
  print "no!\n";
}

print "Clear !\n";
$p->clear();

print "Is empty : ";
if( $p->is_empty() ) {
  print "yes!\n";
} elsif( not $p->is_empty() ) {
  print "no!\n";
}
