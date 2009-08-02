use IO::Socket;
use strict;

package MixrClient;

sub new {
  my( $class, $host, $port ) = @_; 
  
  bless { _host => $host, _port => $port }, $class;
}

sub __action {
  my( $self, $action ) = @_;
  
  my $sock = IO::Socket::INET->new(Proto     => "tcp",
                                PeerAddr  => $self->{_host},
                                PeerPort  => $self->{_port})
                          || die "Failed : $!";
  $sock->autoflush(1);
  
  print $sock $action;
  my $response = <$sock>;
  
  close $sock;
  
  return $response;
}

sub store {
  my( $self, $k, $v ) = @_;
  
  my $r = $self->__action( "SET\@".$k."|".$v );
  if( $r eq "true" ) {
    return( 1 );
  } else {
    return( 0 );
  }
}

sub get {
  my( $self, $k ) = @_;
  
  my $r = $self->__action( "GET\@".$k );
  $r =~ s/\"//g;
  
  return eval{$r};
}

sub keys {
  my $self = shift;
  
  my $r = $self->__action( "KEYS\@" );
  $r =~ s/^\"//;
  $r =~ s/\[/\(/g;
  $r =~ s/\"$//;
  $r =~ s/\]/\)/g;

  return eval $r;
}

sub values {
  my $self = shift;

  my $r = $self->__action( "VALUES\@" );
  $r =~ s/^\"//;
  $r =~ s/\[/\(/g;
  $r =~ s/\"$//;
  $r =~ s/\]/\)/g;
  
  return eval $r;
}

sub delete {
  my( $self, $k ) = @_;
  
  my $r = $self->__action( "DELETE\@".$k );
  $r =~ s/\"//g;
  
  return eval{$r};
}

sub clear {
  my $self = shift;
  
  $self->__action( "CLEAR\@" );
  return;
}

sub is_empty {
  my $self = shift;
  
  return( not length( $self->keys() ) );
}

sub has_key {
  my( $self, $k ) = @_;
  
  my @keys = $self->keys();
  foreach my $key ( @keys ) {
    return $k if( $key eq $k );
  }
  
  return undef;
}

sub has_value {
  my( $self, $v ) = @_;

  my @values = $self->values();
  foreach my $value ( @values ) {
    return $v if( $value eq $v );
  }
  
  return undef;
}

sub length {
  my $self = shift;
  
  return( length( $self->keys() ) );
}

sub to_hash {
  my $self = shift;
  
  my %r = ();
  
  my @keys = $self->keys();
  foreach my $key ( @keys ) {
    $r{$key} = $self->get( $key );
  }
  
  return %r;
}
1;