<? 
//--> RssReader
    class RssReader { 
        var $url; 
        var $data;  

        function RssReader ($url){ 
            $this->url; 
            $this->data = implode ("", file ($url)); 
        }  

        function get_items (){ 
            preg_match_all ("/<item .*>.*<\/item>/xsmUi", $this->data, $matches); 
            $items = array (); 
            foreach ($matches[0] as $match){ 
                $items[] = new RssItem ($match); 
            } 
            return $items; 
        } 
    }  
//-->  fin: RssReader
//-->  RssItem
    class RssItem { 
	
        var $title, $url, $description,$enclosure;  

        function RssItem ($xml){ 
            $this->populate ($xml); 
        }  

        function populate ($xml){ 
            preg_match ("/<title> (.*) <\/title>/xsmUi", $xml, $matches); 
            $this->title = $matches[1]; 
            preg_match ("/<link> (.*) <\/link>/xsmUi", $xml, $matches); 
            $this->url = $matches[1]; 
            preg_match ("/<description> (.*) <\/description>/xsmUi", $xml, $matches); 
            $this->description = $matches[1]; 			
//              preg_match ('/<enclosure url\=\"(.*)\" length\=\"(.*)\" type=\"image\/jpg\"\/>/xsmUi', $xml, $matches); 
              preg_match ('/<enclosure (.*) \/>/xsmUi', $xml, $matches); 			  
            $this->enclosure = $matches[1]; 
    }  

    function get_title (){ 
        return utf8_decode($this->title); 
        }  

        function get_url (){ 
        return utf8_decode($this->url); 
        }  

        function get_description (){ 
//          return $this->description; 
			$this->description = preg_replace('/\<\!\[CDATA\[/ms', "", $this->description);	 												
			$this->description = preg_replace('/\]\]\>/ms', "", $this->description);	 																					
			return htmlentities( utf8_decode($this->description) );
        } 
		
       function get_enclosure (){ 
		   if(    strlen( $this->enclosure ) > 0 )
		   {
	//		    return $this->enclosure; 
               $img = explode ('"', $this->enclosure ); 	   
			   return utf8_decode($img[1]);
		   }
		   else
		   return "No Image";
        } 
		
    } 
//-->  end: RssItem	
?> 

<? 
//include('class.php');//archivo donde este el class 
//$rss = new RssReader ("http://dedydamy.com/feed");//aqui donde esta http://dedydamy.com/feed  tienes que poner la url de tu feed o rss
//Instancia a clase
$rss = new RssReader ('http://www.jc-mouse.net/feed/rss');
//aca hacemos un foreach para el array de las entradas que se muestren en el feed 
foreach ($rss->get_items () as $item){ 
	echo( ($item->get_title())."<br />");//escribimos titulo 
	echo( ($item->get_url())."<br />");///url del post 
	echo("Descripcion: ".($item->get_description())."<br />");//descripcion o lo principal del post 
	echo("Imagen: ".($item->get_enclosure())."<br />");//imagen
	echo("<hr><br />"); 
} 
?> 