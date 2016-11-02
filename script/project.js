// Bearbeiter:DK Dario Kampkaspar, kampkaspar@hab.de

// neu 2016-11-02 DK 
$(function() {$("body").dblclick(function(){
	zeige();})});

function ladeDRW (suchbegriff) {
  suchbegriff = escape(suchbegriff);
  breite = screen.availWidth;
  hoehe = screen.availHeight;
  if (breite > 800) {
  	breite = 800;
  }
  drw=window.open("http://drw-www.adw.uni-heidelberg.de/drw-cgi/metasuche_ext?execterm="+suchbegriff,"drw","width="+breite+",height="+hoehe+",left=0,top=0,scrollbars=yes,resizable=yes,toolbar=yes");
  drw.focus();
}

function zeige () {
  //vgl. http://de.selfhtml.org/navigation/suche/index.htm?Suchanfrage=selectionStart
  if (window.getSelection) {
  ladeDRW(window.getSelection());
  } else if (document.getSelection) {
  ladeDRW(document.getSelection());
  } else if (document.selection) {
  ladeDRW(document.selection.createRange().text);
  }
}