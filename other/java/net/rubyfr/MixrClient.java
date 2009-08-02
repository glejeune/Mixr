package net.rubyfr;

import java.io.*;
import java.net.*;

/**
 * @author greg
 */
public class MixrClient {
  private String host;
  private int port;
  
  public MixrClient( String h, int p ) {
    initialize( h, p );
  }
  
  public MixrClient() {
    initialize( "localhost", 9900 );
  }
  
  public void initialize( String h, int p ) {
    this.host = h;
    this.port = p;
  }
  
  private String action( String c ) {
    try {
      Socket socket = new Socket( this.host, this.port );
      
      BufferedReader plec = new BufferedReader(
          new InputStreamReader(socket.getInputStream())
        );
      
      PrintWriter pred = new PrintWriter(
          new BufferedWriter(
          new OutputStreamWriter(socket.getOutputStream())),
          true );
      
      // envoi d'un message
      pred.write( c );
      pred.flush();
      
      // lecture de l'écho
      String r = plec.readLine();

      pred.close();
      plec.close();
      socket.close();
      
      return( r );
    } catch (UnknownHostException ex) { 
      ex.printStackTrace(); 
    } catch (SocketException ex) { 
      ex.printStackTrace(); 
    } catch (IOException ex) { 
      ex.printStackTrace(); 
    }
    
    return( null );
  }
  
  private Boolean eval_b( String d ) {
    if( d.equals( "true" ) ) {
      return true;
    } else {
      return false;
    }
  }
  
  private String eval_s( String s ) {
    return( s.replaceAll( "\"", "" ) );
  }
  
  private String[] eval_a( String s ) {
    String[] t = s.replaceAll( "[\\[|\\]]", "" ).split( "," );
    if( t.length == 1 && t[0].equals( "" ) ) {
      return( new String[0] );
    }
    String[] r = new String[t.length];
    for( int i = 0; i < t.length; i++ ) {
      r[i] = eval_s( t[i] );
    }
    return( r );
  }
  
  public Boolean store( String k, Object v ) {
    return this.eval_b( this.action( "SET@"+k+"|"+v.toString() ) );
  }
  
  public String get( String k ) {
    return this.eval_s( this.action( "GET@"+k ) );
  }
  
  public String[] keys() {
    return this.eval_a( this.action( "KEYS@" ) );
  }
  
  public String[] values() {
    return this.eval_a( this.action( "VALUES@" ) );
  }
  
  public String delete( String k ) {
    return this.eval_s( this.action( "DELETE@"+k ) );
  }
  
  public void clear( ) {
    this.action( "CLEAR@" );
    return;
  }
  
  public int length( ) {
    return this.eval_a( this.action( "KEYS@" ) ).length;
  }
  
  public Boolean isEmpty() {
    return( this.eval_a( this.action( "KEYS@" ) ).length == 0 );
  }
  
  public Boolean hasKey( String k ) {
    String ks[] = this.keys();
    for( int x = 0; x < ks.length; x++ ) {
      if( ks[x].equals( k ) ) {
        return true;
      }
    }
    return false;
  }

  public Boolean hasValue( String v ) {
    String vs[] = this.values();
    for( int x = 0; x < vs.length; x++ ) {
      if( vs[x].equals( v ) ) {
        return true;
      }
    }
    return false;
  }
}