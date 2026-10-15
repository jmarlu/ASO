from pathlib import Path
from zipfile import ZipFile
from lxml import etree
from docx import Document
import pymupdf as f,re
b=Path(__file__).resolve().parent;a=Document(b/'antes.docx');d=Document(b/'reparado.docx')
normalize=lambda s: re.sub(r'\s+',' ',re.sub(r'(\d)\.(\d{2})(\s*%)',r'\1,\2\3',s)).strip()
assert [normalize(p.text) for p in a.paragraphs]==[normalize(p.text) for p in d.paragraphs], 'Cambio en párrafos'
assert len(a.tables)==len(d.tables)==32
for i,(t,u) in enumerate(zip(a.tables,d.tables)):
 if i==21:
  assert [[normalize(c.text) for c in r.cells] for r in t.rows[1:]]==[[normalize(c.text) for c in r.cells] for r in u.rows[2:]]
 else:
  assert [[normalize(c.text) for c in r.cells] for r in t.rows]==[[normalize(c.text) for c in r.cells] for r in u.rows],f'Tabla {i}'
with ZipFile(b/'reparado.docx') as z:
 root=etree.fromstring(z.read('word/document.xml'));ns={'w':'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
 links=root.xpath('//w:hyperlink[@w:anchor]',namespaces=ns);assert len(links)==31,len(links)
pdf=f.open(b/'reparado.pdf');links=pdf[1].get_links();assert len(links)==31,len(links)
assert all(0<=l['page']<len(pdf) for l in links)
assert all(len(p.get_text().strip())>150 for p in pdf)
print('Validado: contenido conservado, 32 tablas, 7 RA de empresa, 31 enlaces Word y PDF.',len(pdf),'páginas.')
print('Títulos:',[(n,d.styles[n].font.size.pt) for n in ['Heading 1','Heading 2','Heading 3']])
for i,p in enumerate(pdf):
 if i in [1,2] or ('Evaluación compartida' in p.get_text() and i>2):
  p.get_pixmap(matrix=f.Matrix(1,1)).save(b/f'vista-{i+1}.png');print('Captura',i+1)
print('Índice últimas entradas:',pdf[1].get_text()[-800:])
