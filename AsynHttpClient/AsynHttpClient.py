#!/usr/bin/python

import http.client
import ssl
import collections
import os
import time
import json
import queue
import sys
import multiprocessing
import logging
import configparser
import shutil
from urllib.parse import urlparse
from urllib.parse import urlencode
from collections import OrderedDict

TimeStamp = time.strftime('%Y%m%d_%H%M%S')
OutFolder = 'output'
fn_out = 'out'
fn_err = 'err'
fn_log = 'log'
fn_cfg = 'config.ini'
fn_rty = 'manualRetry.json'
CurrOutFolder = os.path.join(OutFolder, TimeStamp)
filename_out = os.path.join(CurrOutFolder, fn_out)
filename_err = os.path.join(CurrOutFolder, fn_err)
filename_log = os.path.join(CurrOutFolder, fn_log)
FORMAT = '%(asctime)s [%(levelname)-8s] %(message)s'

class url:
    def __init__(self):
        self.url = ''
        self.url6 = ''
        self.ext_url = ''
        self.ext_dict = OrderedDict({})
        self.domain = ''
        self.fullpath = ''
        self.__query_url = ''
        self.__query_dict = OrderedDict({})
        
    def __url_sub(self):
        self.__query_dict = self.ext_dict.copy()
        self.__query_url = self.ext_url
        for k, v in self.ext_dict.items():
            if self.__query_url.find( '{'+ k+ '}') >= 0:
                self.__query_url = self.__query_url.replace( '{'+ k+ '}',v)
                self.__query_dict.pop(k)
                
    def url_parse(self):
        self.url = self.url.lower()
        if not self.url.startswith('http'):
            self.url = ''.join(('//', self.url))
        self.url6 = urlparse(self.url)
        self.domain = self.url6.netloc
        self.fullpath = ''
        #'scheme://netloc/path;params?query#fragment'
        if self.url6.path != '':
            self.fullpath = self.url6.path
        if self.url6.params != '':
            self.fullpath = ';'.join((self.fullpath, self.url6.params))
        if self.url6.query != '':
            self.fullpath = '?'.join((self.fullpath, self.url6.query))
        if self.url6.fragment != '':
            self.fullpath = '#'.join((self.fullpath, self.url6.fragment))
        
    def url_decode(self):
        self.__url_sub()
        if self.__query_dict:
            self.url = '?'.join((self.__query_url, urlencode(self.__query_dict)))
        else:
            self.url = self.__query_url
        self.url_parse()
        
class AsynHttpClient():
    def __init__(self):
        self.url = url()
        self.url_queue = queue.Queue()
        self.thro_queue = queue.Queue()
        self.autoRetry = 1
        self.throttling = 5
    
    def ConnectUrlQueue(self, eq=None, rq=None):
        p = multiprocessing.Pool(multiprocessing.cpu_count())
        m = multiprocessing.Manager()
        d = m.dict()
        oq = m.Queue()
        if eq == None:
            eq = m.Queue()
            logmsg = 'Start Connecting URLs:'
            logging.info (logmsg)     
        if rq == None:
            rq = m.Queue()
        while not self.url_queue.empty():
            self.url = self.url_queue.get()
            self.url.url_decode()
            domain = self.url.domain
            url = self.url
            d[domain] = d.get(domain, 0) + 1
            if d[domain] > self.throttling:
                d[domain] -= 1
                logmsg = '{:21}Connecting to {DM} >= {th}, Will Retry Later'.format('', DM=domain, th=self.throttling)
                logging.warning (logmsg)
                self.thro_queue.put(self.url)
            else:
                p.apply_async(ConnectUrl, args=(domain, self.url.fullpath, d, eq, url, rq, ), callback=collect_results)

                with open(filename_out, 'a') as fpout:
                    fpout.close()     
   
        p.close()
        p.join()
        
        # Throttled Entries Retry
        if not self.thro_queue.empty():
            logmsg = 'Retry Throttled URLs:'
            logging.info ('')
            logging.info (logmsg)
            self.url_queue, self.thro_queue = self.thro_queue, self.url_queue
            self.ConnectUrlQueue(eq)
        
        # Connection Error Handling
        if self.autoRetry > 0:
            logmsg = 'Auto Retry for Failed URLs:'
            logging.info ('')
            logging.info (logmsg)
            self.autoRetry -= 1
            self.url_queue, eq = eq, self.url_queue
            self.ConnectUrlQueue()
        
        elif (self.thro_queue.empty() and not eq.empty()):
            with open(filename_err, 'a') as fp:
                while not eq.empty():
                    new_url = eq.get()
                    url_dict = {'ext_url':new_url.ext_url, 'ext_dict':new_url.ext_dict} 
                    json.dump(url_dict, fp)
                    fp.write('\n')
                fp.close()            
                
        if not rq.empty():
            with open(filename_out, 'a') as fp:
                while not rq.empty():
                    Result = rq.get()
                    json.dump(Result, fp)
                    fp.write('\n')
                fp.close()             
                
    def UrlQueueRead(self, fname, lp=None):
        with open(fname, 'r') as fp:
            for i, line in enumerate(fp):
                if (lp == None or int(lp) == i+1):
                    new_url = url()
                    try:
                        new_url.ext_url = json.loads(line)['ext_url']
                        new_url.ext_dict = json.loads(line)['ext_dict']
                    except:
                        raise Exception('Line {0} not in good Json format'.format(i+1))
                    self.url_queue.put(new_url)
            fp.close()        

            
    def ReadConfig(self):
        settings = configparser.ConfigParser()
        settings._interpolation = configparser.ExtendedInterpolation()
        settings.read(fn_cfg)
        settings.sections()
        try:
            self.autoRetry = int(settings.get('Connection', 'AutoRetry'))
            logmsg = 'Reading from {CFG}: AutoRetry = {AR}'.format(CFG=fn_cfg, AR=self.autoRetry)
            logging.info (logmsg)
        except:
            pass
        try:
            self.throttling = int(settings.get('Connection', 'Throttling'))
            logmsg = 'Reading from {CFG}: Throttling = {TH}'.format(CFG=fn_cfg, TH=self.throttling)
            logging.info (logmsg)
        except:
            pass
        logging.info('')

            
def ConnectUrl(domain, fullpath, d, eq, url, rq):
    logmsg = 'Process #{:<11} Connecting to {DM}{FP}'.format(os.getpid(), DM=domain, FP=fullpath)
    logging.info (logmsg)
    conn = http.client.HTTPSConnection(domain, context=ssl._create_unverified_context())
    Result = {}
    try:
        conn.request("GET",fullpath)
        rt = conn.getresponse()
        data = rt.read()
        Result['DM'] = domain
        Result['FP'] = fullpath
        Result['ST'] = rt.status
        Result['RS'] = rt.reason
        Result['DT'] = str(data)
    except:
        Result['DM'] = domain
        Result['FP'] = fullpath
        Result['ST'] = -1
        Result['RS'] = 'Invalid URL'
        Result['DT'] = ''
    conn.close()    
    d[domain]-=1
    if (Result['ST'] >= 400 or Result['ST'] == -1):
        eq.put(url)
    else:
        rq.put(Result)
    return Result

def collect_results(Result):
    logmsg = '#{:3} {:15} Reply from {DM}{FP}'.format(Result['ST'], Result['RS'], DM=Result['DM'], FP=Result['FP'])
    if (Result['ST'] >= 400 or Result['ST'] == -1):
        logging.error (logmsg)
    elif (Result['ST'] >= 300):
        logging.warning (logmsg)
    else:
        logging.info (logmsg)

def init():
    os.chdir(os.path.dirname(sys.argv[0]))
    if not os.path.exists(OutFolder):
        os.makedirs(OutFolder)
    if not os.path.exists(CurrOutFolder):
        os.makedirs(CurrOutFolder)
    logging.basicConfig(level=logging.DEBUG, format=FORMAT, datefmt='%H:%M:%S')
    file_handler = logging.FileHandler(filename_log)
    file_handler.setFormatter(logging.Formatter(FORMAT))
    logging.getLogger().addHandler(file_handler)    

def usage():
    print ()
    print ('Usage: ')
    print ('e.g.: ')  
    print ('    python {0} unittest.json'.format(sys.argv[0]))   
    print ('e.g.: ')
    print ('    python {0} manualRetry.json 4'.format(sys.argv[0]))  
    
def main(filename, lp=None):
    init()
    Client = AsynHttpClient()
    Client.ReadConfig()
    if lp == None:
        Client.UrlQueueRead(filename)
    else:
        Client.UrlQueueRead(filename, lp)
    Client.ConnectUrlQueue()
    shutil.copy(filename_err, fn_rty)
    
if __name__ == "__main__":
    if len(sys.argv) == 2:
        try:
            main(sys.argv[1])
        except BaseException as e:
            print (e)
            usage()
            sys.exit(1)
    elif len(sys.argv) == 3:
        try:
            main(sys.argv[1], sys.argv[2])
        except BaseException as e:
            print (e)
            usage()
            sys.exit(1)
    else:
        print ('Script Expect 1 or 2 paramters')
        usage()
        sys.exit(1)


