<?php
class MixrClient {
	public function __construct( $h = "localhost", $p = 9900 ) {
		$this->host = $h;
		$this->port = $p;
	}
	
	private function __action( $c ) {
		$socket = socket_create( AF_INET, SOCK_STREAM, SOL_TCP );
		$result = socket_connect( $socket, $this->host, $this->port );
		socket_write( $socket, $c, strlen($c) );
		$r = "";
		while( $out = socket_read($socket, 2048) ) {
		    $r = $r . $out;
		}
		socket_close( $socket );
		return( $r );
	}
	
	private function __eval( $r ) {
		eval( "\$result = $r;" );
		return( $result );
	}
	
	private function __eval_a( $r ) {
		$r = str_replace( "]", "", str_replace( "[", "", $r ) );
		eval( "\$result = array(".$r.");" );
		return( $result );
	}
	
	public function store( $k, $v ) {
		return $this->__eval( $this->__action( "SET@".$k."|".$v ) );
	}
	
	public function get( $k ) {
		return $this->__eval( $this->__action( "GET@".$k ) );
	}
	
	public function keys() {
    return $this->__eval_a( $this->__action( "KEYS@" ) );
  }

	public function values() {
		return $this->__eval_a( $this->__action( "VALUES@" ) );
	}
	
	public function delete( $k ) {
    return $this->__eval( $this->__action( "DELETE@".$k ) );
	}
	
	public function clear() {
    $this->__action( "CLEAR@" );
  }

	public function is_empty() {
		return( count( $this->keys() ) == 0 );
	}
	
	public function length() {
		return( count( $this->keys() ) );
	}
	
	public function has_key( $k ) {
		return in_array( $k, $this->keys() );
	}

	public function has_value( $v ) {
		return in_array( $v, $this->values() );
	}
	
	public function to_hash() {
		$keys = $this->keys();
		$r = array();
		foreach( $keys as $k ) {
			$r[$k] = $this->get( $k );
		}
		return( $r );
	}
}
?>