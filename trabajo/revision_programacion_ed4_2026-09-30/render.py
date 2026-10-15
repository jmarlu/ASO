import uno
from pathlib import Path
from com.sun.star.beans import PropertyValue
W=Path(__file__).resolve().parent
def prop(name,value):p=PropertyValue();p.Name=name;p.Value=value;return p
ctx=uno.getComponentContext();resolver=ctx.ServiceManager.createInstanceWithContext('com.sun.star.bridge.UnoUrlResolver',ctx)
remote=resolver.resolve('uno:socket,host=localhost,port=2017;urp;StarOffice.ComponentContext')
desktop=remote.ServiceManager.createInstanceWithContext('com.sun.star.frame.Desktop',remote)
doc=desktop.loadComponentFromURL(uno.systemPathToFileUrl(str(W/'adaptada.docx')),'_blank',0,(prop('Hidden',True),))
try:
 search=doc.createSearchDescriptor();search.SearchString='[[ASO_TOC]]';found=doc.findFirst(search)
 if found:
  cursor=doc.Text.createTextCursorByRange(found);found.String=''
  idx=doc.createInstance('com.sun.star.text.ContentIndex');idx.CreateFromOutline=True;idx.Level=2;idx.Title='';idx.IsProtected=False
  doc.Text.insertTextContent(cursor,idx,False)
  for lev in (1,2):
   tokens=[(prop('TokenType','TokenHyperlinkStart'),),(prop('TokenType','TokenEntryText'),),(prop('TokenType','TokenTabStop'),prop('TabStopRightAligned',True),prop('TabStopFillCharacter','.')),(prop('TokenType','TokenPageNumber'),),(prop('TokenType','TokenHyperlinkEnd'),)]
   uno.invoke(idx.LevelFormat,'replaceByIndex',(lev,uno.Any('[][]com.sun.star.beans.PropertyValue',tuple(tokens))))
  for name in ['Contents 1','Contents 2']:
   s=doc.StyleFamilies.getByName('ParagraphStyles').getByName(name);s.CharHeight=10;s.ParaTopMargin=0;s.ParaBottomMargin=50;s.ParaKeepTogether=False
   if name=='Contents 2':s.ParaLeftMargin=450
 for _ in range(2):
  doc.refresh();indexes=doc.getDocumentIndexes()
  for i in range(indexes.Count):indexes.getByIndex(i).update()
  doc.getTextFields().refresh()
 doc.storeAsURL(uno.systemPathToFileUrl(str(W/'final.docx')),(prop('FilterName','Office Open XML Text'),prop('Overwrite',True)))
 doc.storeToURL(uno.systemPathToFileUrl(str(W/'final.pdf')),(prop('FilterName','writer_pdf_Export'),prop('Overwrite',True)))
 print('Indexes',doc.getDocumentIndexes().Count,'pages',doc.CurrentController.PageCount)
finally:doc.close(True)
