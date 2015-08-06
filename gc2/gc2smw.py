#!/usr/bin/env python

from IPython import embed
import json
import codecs
import re
from lxml import html

geodata_file = 'output/geodata.csv'
gc2file = 'gc2/gc2.json'

def generate(tables):
    gfile = codecs.open(geodata_file, 'w', 'utf-8')
    header = 'Titel,Geodata[Titel],Geodata[Beskrivelse],Geodata[Skema],Geodata[Tabelnavn],Geodata[Laggruppe],Geodata[SRID],Geodata[Geometritype],Geodata[KLE-numre],Geodata[Dataansvar],Geodata[URL],Fritekst\n'
    gfile.write(header)

    count = 0
    for table in tables:
        count += 1
        if table['extra'] != None:
            extra = 'Emne_' + table['extra']
        else:
            extra = ''

        if table['layergroup'] == None:
            layergroup = ''
        elif re.match('.*Ungrouped.*', table['layergroup']):
            layergroup = 'Ungrouped'
        elif table['layergroup'] != None:
            layergroup = table['layergroup']

        if table['f_geometry_column'] != None:
            f_geometry_column = table['f_geometry_column']
        else:
            f_geometry_column = ''
        if table['_key_'] != None:
            key = table['_key_']
        else:
            key = ''
        if table['tilecache'] != None:
            tilecache = table['tilecache']
        else:
            tilecache = ''
        if table['bitmapsource'] != None:
            bitmapsource = table['bitmapsource']
        else:
            bitmapsource = ''
        if table['f_table_abstract'] == "":
            f_table_abstract = ''
        elif table['f_table_abstract'] != None:
            f_table_abstract  = html.fromstring(table['f_table_abstract']).text_content()
        else:
            f_table_abstract = ''
        if table['single_tile'] != None:
            single_tile = table['single_tile']
        else:
            single_tile = ''

        if isinstance(table['baselayer'], (bool)):
            baselayer = str(table['baselayer'])
        else:
            baselayer = ''

        baselayer = str(table['baselayer'])

        if table['baselayer'] == True:
            baselayer = 'true'
        elif table['baselayer'] == False:
            baselayer = 'false'
        else:
            baselayer = ''
            
        if table['type'] != None:
            ttype = table['type']
        else:
            ttype = ''
        if table['wmssource'] != None:
            wmssource = table['wmssource']
        else:
            wmssource = ''
        if table['sort'] != None:
            ssort = table['sort']
        else:
            ssort = ''
        if table['f_table_schema'] != None:
            f_table_schema = table['f_table_schema']
        else:
            f_table_schema = ''
        if table['srid'] != None:
            srid = table['srid']
        else:
            srid = ''
        if table['data'] != None:
            ddata = table['data']
        else:
            ddata = ''
        pagetitle = 'Geodata_' + table['f_table_name'] # this can't be empty, it's the page title
        if table['f_table_name'] != None:
            f_table_name = table['f_table_name']
        else:
            f_table_name = ''
        if table['f_table_title'] != None:
            f_table_title = table['f_table_title']
        else:
            f_table_title = ''
        if table['coord_dimension'] != None:
            coord_dimension   = table['coord_dimension']
        else:
            coord_dimension = ''
        gc2url = 'http://ballerup.mapcentia.com/apps/viewer/ballerup/%s/#stamenToner/12/12.3342/55.7363/%s.%s' % (f_table_schema, f_table_schema, f_table_name)
        line = '"%s_%s","%s","%s","%s","%s","%s","%s","%s","%s",Bruger:Ldg,"%s",[[Category:Geodata]]\n' % (pagetitle, count, f_table_title, f_table_abstract, f_table_schema, f_table_name, layergroup, srid, ttype, extra, gc2url)
        gfile.write(line)
    gfile.close()


if __name__ == '__main__':
    with open(gc2file) as data_file:    
        gc2data = json.load(data_file)
    gc2tables = gc2data['data']
    embed()
