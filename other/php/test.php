<?php
require 'mixr_client.php';

$p = new MixrClient();
echo $p->store( "k1", "v1" )."\n";
echo $p->get( "k1" )."\n";
echo $p->store( "k2", "v2" )."\n";
print_r($p->to_hash());
print_r($p->keys());
print_r($p->values());
echo $p->delete( "k2" )."\n";
print_r($p->keys());
print_r($p->values());
$p->clear();
if( $p->is_empty() == true ) {
	echo "Mixr vide !\n";
}
?>