#!/usr/bin/env python3
 # -*- coding: utf-8 -*-

from IPython import embed
import json
import codecs
import re
from lxml import html
import mwclient
import urllib
import requests
from config import Config

cfg = Config(file('/opt/gc2/gc2smw.cfg'))

username = cfg.username
password = cfg.password
site = mwclient.Site(cfg.site, path=cfg.path)
gc2_url = cfg.gc2_url
table_whitelist = gc2.table_whitelist

site.login(username, password)

geodata_tables = []

template = """{{Geodata
|Titel=%s
|Beskrivelse=%s
|Skema=%s
|Tabelnavn=%s
|Laggruppe=%s
|SRID=%s
|Geometritype=%s
|KLE-numre=%s
|Dataansvar=%s
|URL=%s
|GUID=%s
}}
"""

def delete_cat(category):
    """ Deletes all pages in category """
    for page in site.Categories[category]:
        page.delete()

def generate(tables):

    count = 0
    for table in tables:

        t = {}
        count += 1

        if table['uuid'] != None:
            guid = table['uuid']
        else:
            guid = '' # should NEVER happen, maybe implement somme syslogging

        if table['extra'] != None:
            if table['extra'].strip() != None:
                extra = 'Emne_' + table['extra'].strip()
            else:
                extra = ''
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
            # this should never happen, the key field in GC2 JSON is assumed to
            # be unique identifier
            key = str(count)
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
            # we will include only those tables for which the schema:
            # 1. starts with _XX_ both X'es being digits, and
            # 2. NOT _00_
            included = False # we are whitelisting tables
            if re.search('^_[0-9]{2}_.*', f_table_schema):
                if f_table_schema[:4] != '_00_':
                    included = True
        else:
            f_table_schema = '' # probably not possible? Just being safe

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
        if f_table_name in table_whitelist:
            included = True
        if table['f_table_title'] != None:
            f_table_title = table['f_table_title']
        else:
            f_table_title = ''
        if table['coord_dimension'] != None:
            coord_dimension   = table['coord_dimension']
        else:
            coord_dimension = ''
        gc2url = 'http://ballerup.mapcentia.com/apps/viewer/ballerup/%s/#stamenToner/12/12.3342/55.7363/%s.%s' % (f_table_schema, f_table_schema, f_table_name)

        if f_table_title != '':
            pagename = f_table_title
        else:
            if f_table_name != '':
                pagename = f_table_name
            else:
                pagename = "ERROR" # cross fingers it's unique in GC2?
        t['title'] = 'Geodata_%s' % pagename

        t['contents'] = template % (f_table_title, f_table_abstract, f_table_schema, f_table_name, layergroup, srid, ttype, extra, 'Bruger:Ldg', gc2url, guid)
        # Time to sort out the _00_ grundkort and others without _XX_
        if included:
            geodata_tables.append(t)
    return geodata_tables

if __name__ == '__main__':
    # Step 1: Load gc2 json into SMW pages
    response = urllib.urlopen(gc2_url)
    gc2data = json.loads(response.read())
    gc2tables = gc2data['data']
    tables = generate(gc2tables)
    # Step 2: Delete SMW pages in the Geodata category
    delete_cat('Geodata')
    # Step 3: Create new pages for all the SMW pages generated in step 1
    for table in tables:
        page = site.Pages[table['title']]
        page.save(table['contents'], summary = 'GC2 geodata batch import')
