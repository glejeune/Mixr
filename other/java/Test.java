import net.rubyfr.MixrClient;
import java.io.*;

public class Test {
  public static void main( String arg[] ) {
    MixrClient p = new MixrClient();
    System.out.println( p.store( "cle", "valeur" ) );
    System.out.println( p.get( "cle" ) );
    System.out.println( p.store( "key", "value" ) );
    
    System.out.println( "hasKey( cle ) = " + p.hasKey( "cle" ) );
    System.out.println( "hasKey( truc ) = " + p.hasKey( "truc" ) );
    
    System.out.println( "hasValue( value ) = " + p.hasValue( "value" ) );
    System.out.println( "hasValue( truc ) = " + p.hasValue( "truc" ) );
    
    System.out.println( "empty : " + p.isEmpty() );
    
    System.out.println( "Liste des clés : " );
    String[] k = p.keys();
    System.out.println( k.length );
    for( int x = 0; x < k.length; x++ ) {
      System.out.println( k[x] );
    } 
    
    System.out.println( "Liste des valeurs : " );
    String[] v = p.values();
    System.out.println( v.length );
    for( int x = 0; x < v.length; x++ ) {
      System.out.println( v[x] );
    }
    
    System.out.println( "DELETE cle : ");
    System.out.println( p.delete( "cle" ) );
    
    System.out.println( "Taille : " + p.length() );
    
    System.out.println( "CLEAR" );
    p.clear();
    
    System.out.println( "Liste des valeurs : " );
    String[] w = p.values();
    System.out.println( w.length );
    for( int x = 0; x < w.length; x++ ) {
      System.out.println( x + " : " + w[x] );
    }
    
    System.out.println( "empty : " + p.isEmpty() );
  }
}