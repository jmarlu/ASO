import uno
from pathlib import Path
from com.sun.star.beans import PropertyValue
W=Path(__file__).resolve().parent

def prop(name,value):
 p=PropertyValue();p.Name=name;p.Value=value;return p
ctx=uno.getComponentContext()
resolver=ctx.ServiceManager.createInstanceWithContext('com.sun.star.bridge.UnoUrlResolver',ctx)
remote=resolver.resolve('uno:socket,host=localhost,port=2018;urp;StarOffice.ComponentContext')
desktop=remote.ServiceManager.createInstanceWithContext('com.sun.star.frame.Desktop',remote)
doc=desktop.loadComponentFromURL(uno.systemPathToFileUrl(str(W/'formato.docx')),'_blank',0,(prop('Hidden',True),))
try:
 indexes=doc.getDocumentIndexes()
 assert indexes.Count==1, indexes.Count
 idx=indexes.getByIndex(0)
 idx.CreateFromOutline=True;idx.Level=2
 for lev in (1,2):
  tokens=[(prop('TokenType','TokenHyperlinkStart'),),(prop('TokenType','TokenEntryText'),),(prop('TokenType','TokenTabStop'),prop('TabStopRightAligned',True),prop('TabStopFillCharacter','.')),(prop('TokenType','TokenPageNumber'),),(prop('TokenType','TokenHyperlinkEnd'),)]
  uno.invoke(idx.LevelFormat,'replaceByIndex',(lev,uno.Any('[][]com.sun.star.beans.PropertyValue',tuple(tokens))))
 for _ in range(2):
  doc.refresh();idx.update();doc.getTextFields().refresh()
 doc.storeAsURL(uno.systemPathToFileUrl(str(W/'reparado.docx')),(prop('FilterName','Office Open XML Text'),prop('Overwrite',True)))
 doc.storeToURL(uno.systemPathToFileUrl(str(W/'reparado.pdf')),(prop('FilterName','writer_pdf_Export'),prop('Overwrite',True)))
 print('Índices:',indexes.Count,'Páginas:',doc.CurrentController.PageCount)
finally:doc.close(True)
