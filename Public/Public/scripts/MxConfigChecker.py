#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Murex Enviroment post built sanity checking tool.

by GMP Env BAU team. """


__author__      = 'tmpbko'
__version__     = '1.2.2'

import pwd
import sys, os
import getopt, re
import unittest
import shutil, tempfile
import subprocess
import zipfile
import getpass
#import json

from subprocess import Popen, PIPE
from xml.dom import minidom

#TODO extract the mappings from table WF_TASK_DBF/GUI
g_wftask_queue_map = {
    'TSPSGRQST01':'p1doc_DLV_P1_dlvSwift_exportMQ',
    'GMPRQST01A':'p1doc_DLV_P1_exportEAIMQ',
    'DCDCNRPLY01':'FINIQ_exportMQ_AckNack_CN',
    'DCDSGRPLY01':'FINIQ_exportMQ_AckNack_SG',
    'DCDCNRQST01':'FINIQ_importInput_MQ_CN',
    'DCDSGRQST01':'FINIQ_importInput_MQ_SG',
    'WSSRPLY01':'export_MessageToWSS_MQ',
    'MERRQST01':'Merva_IN_MQ_importSwift',
    'MERRQST02':'Merva_ACK-NACK_MQ_importSwift',
    'TSPSGRQST01':'Merva_Out_Resend_exportMQ',
    'GMPRPLY01':'RBK_IN_ACK_NACK_ImportMQ',
    'GMPRQST01':'WSS_Out_exportWSSMQ_FX',
    'GMPRQST02':'WSS_Out_exportWSSMQ_MM',
    'GMPRPLY02':'WSS_Out_ImportWSSMQ_response_MM',
    'WSSRQST01':'InboundWSS_importFlatFile',
}

#if not sys.version_info[:2] == (2, 6):
#    print 'run on 2.6+'

###############################################################################
#   1. DB Config file Sanity Checking section                                 #
###############################################################################
class MxEncoder(object):
    "MX encrytion/decrytion algorithm wrapper."

    def __init__(self):
        self.__key = ('L', 'W', 'F', '1', '9', '9', '9')

    def __str_to_byte(self, text):
        """
        Get Hex values from the encrypted string.
        """
        strtext = text.strip()
        byte_arr = []
        index = 0
        for index in range(0, len(text), 4):
            tmpstr = strtext[index:index+4]
            intval = int(tmpstr, 16)
            if intval > 127:
                intval -= 256
            byte_arr.append(intval)
        return byte_arr

    def __decode(self, intarr):
        """
        Decypher the byte sequence.
        """
        cleartext = []
        i1 = i2 = 0;
        while i1 < len(intarr):
            c = intarr[i1]
            c1 = (c & 0xF)  << 4
            c2 = (c & 0xF0) >> 4
            c = c1 | c2
            cleartext.append(c ^ ord(self.__key[i2]))
            if i2 < (len(self.__key) - 1):
                i2 += 1
            else:
                i2 = 0
            i1 += 1
        return cleartext

    def decrypt(self, stext):
        """
        Interface method.
        """
        result = None
        try:
            result = self.__decode(self.__str_to_byte(stext))
            result = ''.join([chr(c) for c in result])
        except Exception, e:
            pass

        return result


class ConfigFileNotExistException(Exception):
    pass


class DBConnection(object):
    """
    DB Connection to MX FIN DB.
    exception throws when config files doesn't exists or db connection fails to establish.
    """
    dbsource_file   = 'fs/public/mxres/common/dbconfig/dbsource.mxres'
    mxg_file        = 'mxg2000_settings.sh'

    def __init__(self, path):
        self.__path = path
        if not self.__checkconfig():
            raise ConfigFileNotExistException("db source files")
        self.__orahome = self.__getorahome(path)
        self.__connstr = self.__getconnstr(path)
        self.__sqlplus = os.path.join(self.__orahome, 'bin/sqlplus')
        os.environ['ORACLE_HOME'] = self.__orahome
        os.environ['LD_LIBRARY_PATH'] = os.path.join(self.__orahome, 'lib')

    def __checkconfig(self):
        return os.path.isfile(self.__path + os.path.sep + self.dbsource_file) \
                and os.path.isfile(self.__path + os.path.sep + self.mxg_file)

    def run_sql(self, sqlstat):
        s = Popen([self.__sqlplus, '-S', self.__connstr], stdin=PIPE, stdout=PIPE, stderr=PIPE)
        #s.stdin.write("""set colsep ,
        #set pagesize 0
        #set trimspool on
        #set feedback off
        #set verify off
        #set heading off""")
        #s.stdin.write(sqlstat)
        (out, errors) = s.communicate('set head off ver off lines 200 pages 0 feed off colsep |\n' \
                                 + sqlstat + ';\nexit\n')
        if errors:
            print("Errors when run the sql '%s' --> %s" % (sqlstat, errors))
        if out:
            lines = out.strip().split('\n')
            return  [[col.strip() for col in line.split('|')] for line in lines]

    def __getorahome(self, path):
        return FileParser('ORACLE_HOME', self.__path + os.path.sep + self.mxg_file).getvar()

    def __getconnstr(self, path):
        fp = FileParser(None, self.__path + os.path.sep + self.dbsource_file)
        params = ('DbUser', 'DbPassword', 'DbHostName', 'DbServerPortNumber', 'DbServerOrServiceName')
        values = fp.getvars(params)
        values[1] = MxEncoder().decrypt(values[1])
        # *values doesn't work
        return '%s/%s@%s:%s/%s' % (values[0], values[1], values[2], values[3], values[4])

    def closeconn(self):
        pass

class ServiceRepo(object):
    """
    Murex Services list generator.
    """
    def __init__(self, env):
        self.__env = env
        self.__dir = '/tmp/mxsrvices'
        self.__credential_file = os.path.join(self.__env, "fs/public/mxres/common/dbconfig/credentials.properties")
        self.__config = '/tmp/mxservices_list.mxres'

    def __generate_config(self):
        # firstly check if the config folder exists.
        if not os.path.exists(self.__dir):
            os.makedirs(self.__dir)
        node = self.__env.split('/')[3]
        adminpwd = self.__getadminpass()

        content = """
<?xml version="1.0"?>
<project name="GMPEnv" basedir="." >
   <MxInclude MxAnchor="murex.mxres.script.middleware.tasks.mxres#AUTHENTICATION" MxAnchorType="Include"/>
   <MxInclude MxAnchor="murex.mxres.script.middleware.tasks.mxres#LIST_SERVERS" MxAnchorType="Include"/>
   <property environment="env"/>
   <target name="listservers" description="list servers">
      <murex.middleware.access.authentication user="ADMIN" password="%s" crypted="Y"/>
      <murex.middleware.access.listServers outputFile="/tmp/mxsrvices/list-of-servers_%s.xml"/>
   </target>
</project>
""" % (adminpwd, node)
        try:
            fh = open(self.__config, 'w')
            fh.write(content)
            fh.close()
        except Exception, e:
            printf("Error while generating config file under %s" % self.__env)
            return False
        return True

    def __getadminpass(self):
        ulist = DBConfig(self.__env).get_credentials('ADMIN')
        return ulist[1]

    def __runscript(self):
        command = '%s/launchmxj.app -scriptant /MXJ_ANT_BUILD_FILE:%s /MXJ_ANT_TARGET:listservers' % (self.__env, self.__config)
        FNULL = open(os.devnull, 'w')
        p = subprocess.Popen([command], cwd=self.__env, shell=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
        p.communicate()

    def generate(self):
        if self.__generate_config():
            self.__runscript()


class MQTask(object):
    """
    MQ Task validation.
    list all, indicate possible queue name with issues.
    """
    #TODO check again of the config file name
    config_file  = 'mxmlexchange/exportworkflowconfig.xml'
    shell_file   = 'mxmlexchange/exportworkflow.sh'
    shell_name   = './exportworkflow.sh'
    mxg_file     = 'mxg2000_settings.sh'

    def __init__(self, path):
        self.__path = path
        self.__config = os.path.join(self.__path, self.config_file.split('/')[1])
        self.__shell  = os.path.join(self.__path, self.shell_file.split('/')[1])

    def __generate_config(self):
        content = """<?xml version="1.0"?>
          <!DOCTYPE ProcessingScriptQuery>
          <ProcessingScriptQuery>
              <wf:workflow>
                  <wf:code>PCGLOBAL_P1</wf:code>
                  <wf:subCode>Exchange</wf:subCode>
              </wf:workflow>
          </ProcessingScriptQuery>"""
        try:
            fh = open(self.__config, 'w')
            fh.write(content)
            fh.close()
        except Exception, e:
            printf("Error while generating config file under %s" % self.__path)
            return None
        return self.__config

    def __generate_sscript(self):
        orig_shell = os.path.join(self.__path, self.shell_file)
        jdk64 = FileParser('JAVAHOME_64', os.path.join(self.__path, self.mxg_file), 'FP').getvar()
        jdk64 = os.path.join(jdk64, 'bin')
        try:
            fh_out = open(self.__shell, 'w')
            for line in open(orig_shell, 'r'):
                #TODO check the processing script again
                if line.find('=http') != -1:
                    fh_out.write('export PATH=%s:$PATH\n' % jdk64)
                fh_out.write(line)
            fh_out.close()

            # change the permission
            cmd = "chmod 755 %s" % self.__shell
            p = subprocess.Popen(cmd,shell=True,stdout=subprocess.PIPE)
            p.communicate()

        except Exception, e:
            printf("Error while generating script file under %s" % self.__path)
            return None
        return self.__shell

    def __handle_zipfile(self):
        zfile = os.path.join(self.__path, 'workflow.zip')
        if not os.path.isfile(zfile):
            raise ConfigFileNotExistException("workflow zip file")
        # unzip to tmp directory
        tmpdir = tempfile.mkdtemp()
        tmp_zipfile = os.path.join(tmpdir, 'workflow.zip')
        shutil.move(zfile, tmp_zipfile)
        # extract the files
        znfile = zipfile.ZipFile(tmp_zipfile)
        znfile.extractall(tmpdir)
        # now extract all queues
        result_map = self.__parse_result(tmpdir)
        shutil.rmtree(tmpdir)
        return result_map

    def __parse_result(self, adir):
        #TODO check the extracted files name
        eligible_files = [f for f in os.listdir(adir) if f.startswith('workflow.document')]
        pattern = r'.*name="Queue">(.+)</Property>.*'
        pattern2 = r'([A-Z]{5,15}\d{1,3}).*'
        prog = re.compile(pattern)
        qprog = re.compile(pattern2)
        queuemap = {}
        # avoid using with for compa
        for f in eligible_files:
            for line in open(os.path.join(adir, f), 'r'):
                # assume the queue name has naming conv
                r = prog.match(line)
                if r:
                    qstr = r.group(1)
                    qname = qstr.split('.')[-1]
                    qr = qprog.match(qname)
                    if qr:
                        queue = qr.group(1)
                        queuemap[qstr] = queue
                    else:
                        queuemap[qstr] = qname
        return queuemap

    def __execute_sshell(self):
        FNULL = open(os.devnull, 'w')
        p = subprocess.Popen([self.shell_name], cwd=self.__path, stderr=FNULL, stdout=subprocess.PIPE)
        p.communicate()

    def __format_output(self, qmap):
        unknow_q = 'UNKNOWN'
        output_list = []
        for k, v in qmap.iteritems():
            task = unknow_q
            note = ''
            if g_wftask_queue_map.has_key(v):
                task = g_wftask_queue_map[v]
            if k.split('.')[-1] == v:
                note = '<---'
            output_list.append('%-30s%-30s%-10s' % (task, k, note))
        return output_list


    def get_queues(self):
        self.__generate_config()
        self.__generate_sscript()
        self.__execute_sshell()
        qmap = self.__handle_zipfile()
        queues = self.__format_output(qmap)
        self.__clean_up()
        return queues

    def __clean_up(self):
        os.remove(self.__config)
        os.remove(self.__shell)


class FileParser(object):
    """
    File Parser util.
    """
    def __init__(self, var, src, afilter=None):
        self.__var = var
        self.__src = src
        self.__filter = afilter

    def getvar(self):
        for line in open(self.__src, 'r'):
            line = line.strip()
            if line.startswith(self.__var):
                if self.__filter:
                    if re.search(self.__filter, line):
                        next
                    else:
                        return line.strip().split('=')[1]
                else:
                    return line.strip().split('=')[1]

    def getvars(self, params):
        tags = list(params[:])
        tagmap = {}
        for line in open(self.__src):
            if any(s in line for s in tags):
                parts = re.split('[<>/]+', line.strip())
                thetag = parts[1]
                thevalue = parts[2]
                tagmap[thetag] = thevalue
                tags.remove(thetag)

        return list(tagmap[a] for a in params)

    def getvar_from_xml(self):
        label = ""
        if not os.path.isfile(self.__src):
            return None

        for line in open(self.__src):
            if re.search(self.__var, line):
                parts = re.split('[<>/]+', line.strip())
                label = parts[2]
                break
        return label

    def getdb_accounts(self):
        """Specifically for credential file, do not use for other purpose."""
        account_passwd_map = {}
        accounts = set()
        doc = minidom.parse(self.__src)
        itemlist = doc.getElementsByTagName('MxAnchor')

        for item in itemlist:
            code = item.attributes['Code'].value
            commands = item.getElementsByTagName('DefaultCommand')
            user = commands[0].childNodes[0].data.strip().split(':')[1]
            passwd = commands[1].childNodes[0].data.strip().split(':')[1]
            tmplist = (user, passwd)
            account_passwd_map[code.strip()] = tmplist
            accounts.add(user)

        return (list(accounts), account_passwd_map)


def singleton(class_):
    """
    Singleton decorator.
    """
    instances = {}
    def getinstance(*args, **kwargs):
        if class_ not in instances:
            instances[class_] = class_(*args, **kwargs)
        return instances[class_]
    return getinstance


class MXEnv(object):
    """
    Murex Enviroments on this box.
    """
    possible_path = ['/app/CCR', '/app/TSPSG']
    env_label_file = 'fs/public/mxres/guiclient/profile/client.mxres'

    def __init__(self):
        self.__user = getpass.getuser()
        self.__path = self.__find_owner(self.possible_path)
        self._all_envs = self.__find_all_envs()
        self._live_envs = self.__find_live_envs()

    def __find_all_envs(self):
        env_map = {}
        p = self.__path
        potential_list = [os.path.join(p,name) for name in os.listdir(p) if os.path.isdir(os.path.join(p,name))]

        for v in potential_list:
            if re.match('.*t\d+$', v) and os.path.isfile(os.path.join(v, 'pmx')):
                envlbl = FileParser('Name', os.path.join(v, self.env_label_file)).getvar_from_xml()
                env_map[envlbl] = v
        return env_map

    def __find_live_envs(self):
        env_map = {}
        #TODO use the monitoring script logic
        FNULL = open(os.devnull, 'w')
        cmd = "ps -eo user,pid,comm |grep %s|grep %s|awk '{print $2}'|xargs pwdx|awk '{print $2}'|sort|uniq"
        cmd = cmd % (self.__user, "java")
        pos = subprocess.Popen(cmd,shell=True,stdout=subprocess.PIPE,stderr=FNULL)
        output = pos.communicate()[0]
        potential_list = output.strip().split('\n')

        all_env = self._all_envs
        #edict = {v: k for k, v in all_env.iteritems()}
        edict = {}
        for k, v in all_env.iteritems():
            edict[v] = k

        for v in potential_list:
            if v in edict:
                #envlbl = FileParser('Name', os.path.join(v, env_label_file)).getvar_from_xml()
                envlbl = edict[v]
                env_map[envlbl] = v

        return env_map

    def __find_owner(self, plist):
        for p in plist:
            if os.path.isdir(p) and pwd.getpwuid(os.stat(p).st_uid).pw_name == self.__user:
                return p


class DBConfig(object):
    """
    MxCrendentials.
    """
    credential_file   = 'fs/public/mxres/common/dbconfig/mxservercredential.mxres'

    def __init__(self, env):
        self.__env = env
        self.__fp  = FileParser(None, os.path.join(env, self.credential_file))

    def __compose_sql(self):
        accounts, accmap = self.__fp.getdb_accounts()
        accounts.sort()
        self.__accmap = accmap
        self.__accounts = accounts
        userlist = "'%s'" % accounts[0]
        for u in accounts[1:]:
            userlist += ",'%s'" % u
        return "select M_LABEL, M_PASSWORD from MX_USER_DBF where M_LABEL in (%s)" % userlist

    def __parse_result(self, rs):
        #TODO check the real oracle result format
        rmap = {}
        for line in rs:
            rmap[line[0]] = line[1]

        status_ok   = '---> OK'
        status_fail = '---> Mismatch'

        status = status_fail
        result = []
        for task, rec in self.__accmap.iteritems():
            user, passtr_file = rec
            if rmap.has_key(user):
                passtr_db = rmap[user]
                if passtr_file == passtr_db:
                    status = status_ok
                else:
                    status = status_fail + " " + passtr_db
            result.append("%-30s%-15s%-50s%-35s" % (task, user, passtr_file, status))
        return result

    def get_credentials(self, user=None):
        conn = DBConnection(self.__env)
        if user:
            sql = "select M_LABEL, M_PASSWORD from MX_USER_DBF where M_LABEL = '%s'" % user
            result = conn.run_sql(sql)
            return result[0]

        sql = self.__compose_sql()
        result = conn.run_sql(sql)
        if result:
            return self.__parse_result(result)
        return None

###############################################################################
def getdistenv():
    """
    extract services information from xml result.
    """
    root_fld = '/tmp/mxsrvices'
    xmlfiles = [ os.path.join(root_fld, f) for f in os.listdir(root_fld) if os.path.isfile(os.path.join(root_fld,f)) ]

    envmap = {}
    for xmlf in xmlfiles:
        DOMTree = minidom.parse(xmlf)
        collection = DOMTree.documentElement
        launchers = collection.getElementsByTagName('MX_MIDDLEWARE_SERVICES')[0]
        service = launchers.getElementsByTagName('LauncherHome')

        service_list = []
        for mrv in service:
            installationCodeTag = mrv.getElementsByTagName('InstallationCode')[0]
            installationCode = installationCodeTag.childNodes[0].data
            hostTag = mrv.getElementsByTagName('Host')[0]
            host = hostTag.childNodes[0].data
            uidTag = mrv.getElementsByTagName('UID')[0]
            uid = uidTag.childNodes[0].data
            ctimeTag = mrv.getElementsByTagName('CreationTime')[0]
            ctime  = ctimeTag.childNodes[0].data

            tmplist = [installationCode, host, uid, ctime]
            service_list.append(tmplist)
        tag = os.path.basename(xmlf).split('_')[1].split('.')[0].upper()
        envmap[tag] = service_list
    print json.dumps(envmap)

def checkall():
    """check all the db config and workflow config of the enviroments."""
    allenv = MXEnv()
    emap = allenv._live_envs
    for tag, path in emap.iteritems():
        print("Checking %s on %s" % (tag, path))
        # 1. check MQ
        qt = MQTask(path)
        qlist = qt.get_queues()
        print("check result of workflow tasks of %s:" % tag)
        for line in qlist:
            print("*%s" % line)
        # 2. check db config
        dc = DBConfig(path)
        rlist = dc.get_credentials()
        print("check result of DB Accounts of %s:" % tag)
        for line in rlist:
            print("*%s" % line)

def checkdbconfig(env):
    """check the db config of the env """
    envpath = validate_env_input(env, MXEnv()._all_envs)
    rlist = DBConfig(envpath).get_credentials()
    print("List of accounts on %s:" % env)
    for line in rlist:
        print("*%s" % line)

def generatesrvlist():
    """
    generate service list file."
    """
    env = MXEnv()
    aenvs = env._live_envs
    for e, p in aenvs.iteritems():
        try:
            rep = ServiceRepo(p)
            rep.generate()
        except Exception, e:
            print("Error during %s service list generation" % e)

def listenv():
    """
    list all active env in this server
    """
    env = MXEnv()
    penvs = env._live_envs
    for e, p in penvs.iteritems():
        print("%-15s%-30s" % (e, p))

def validate_env_input(env, emap):
    """
    Validate env tag from user input.
    """
    taglist = emap.keys()
    plist   = emap.values()
    pathlist = [p.split(os.path.sep)[-1] for p in plist]

    envpath = None
    if env in taglist:
        envpath = emap[env]
    elif env in pathlist:
        envpath = plist[pathlist.index(env)]
    else:
        print('Non existence env, use Env label or folder name, eg. UAT8, tspuat8')
        sys.exit(2)
    return envpath

def checkwfconfig(env):
    """
    check workflow config of the env.
    """
    envpath = validate_env_input(env, MXEnv()._live_envs)
    qt = MQTask(envpath)
    qlist = qt.get_queues()
    print("List of workflow tasks on %s:" % env)
    for line in qlist:
        print("*%s" % line)

def decryptit(ciphertext):
    """
    Decrypt the password from ciphertext.
    """
    encoder = MxEncoder()
    print(encoder.decrypt(ciphertext))


###############################################################################
#   3. Entry method, for arguments validation                                 #
###############################################################################

def usage():
    print("""usage: %s [-a|-d|-h|-l|-r|-w|-s] [Env]
    -a: check all enviroments, both db config and workflow config
    -d: check db config of the Env
    -h: help
    -l: list all active enviroments
    -r: reveal password
    -s: generate service list in the active env
    -w: check workflow config of the Env""" % sys.argv[0])

def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'adhlrwsc')
    except getopt.error, msg:
        sys.stdout = sys.stderr
        print(msg)
        usage()
        sys.exit(1)
    if not opts:
        usage()
        sys.exit(1)

    func = checkwfconfig
    reqarg = False
    for o, a in opts:
        if o == '-a': func = checkall
        elif o == '-d': func = checkdbconfig; reqarg = True
        elif o == '-h': func = usage
        elif o == '-l': func = listenv
        elif o == '-r': func = decryptit; reqarg = True
        elif o == '-w': func = checkwfconfig; reqarg = True
        elif o == '-s': func = generatesrvlist
        elif o == '-c': func = getdistenv

    if reqarg:
        if args and args[0] != '-':
            func(args[0])
        else:
            usage()
    else:
        func()


# Unit tests
###############################################################################
class TestDecryptFunctions(unittest.TestCase):

    def test_decrypt(self):
        encoder = MxEncoder()
        ciphertext = '00d0003100b000870077'
        cleartext  = encoder.decrypt(ciphertext)
        self.assertEqual('ADMIN', cleartext)

        ciphertext = '001200230052007500d00010000000a7'
        cleartext  = encoder.decrypt(ciphertext)
        self.assertEqual('mecf4896', cleartext)

        ciphertext = '00c3002200f3005400b000c0001000b7'
        cleartext  = encoder.decrypt(ciphertext)
        self.assertEqual('puyt2587', cleartext)

    def test_decrypt_malformat(self):
        encoder = MxEncoder()
        ciphertext = '4#!@#$$$$$$$'
        cleartext  = encoder.decrypt(ciphertext)
        self.assertEqual(None, cleartext)


    def test_encrypt(self):
        pass


#TODO mock the files
class TestFileParsers(unittest.TestCase):

    def test_findvar(self):
        fp = FileParser('ORACLE_HOME', '/tmp/mxg2000_settings.sh')
        value = fp.getvar()
        self.assertEqual('/app/oracle/oracleclient_023', value)
        # test filter
        fp = FileParser('JAVAHOME', '/tmp/mxg2000_settings.sh', 'i586')
        value = fp.getvar()
        self.assertEqual('/app/linux/jdk_1.7.38', value)
        # test non exists
        fp = FileParser('GHOST_HOME', '/tmp/mxg2000_settings.sh')
        value = fp.getvar()
        self.assertEqual(None, value)

    def test_findvar_from_xml(self):
        fp = FileParser('EnvironmentName', '/tmp/client.mxres')
        value = fp.getvar_from_xml()
        self.assertEqual('UAT8', value)

    def test_findvars(self):
        fp = FileParser(None, '/tmp/client.mxres')
        params = ('DbUser', 'DbPassword', 'DbHostName', 'DbServerPortNumber', 'DbServerOrServiceName')
        values = fp.getvars(params)
        self.assertEqual('FIN', values[0])
        self.assertEqual('00f30033004700200035002500f000b7', values[1])
        self.assertEqual('TSPCUSG01', values[2])
        self.assertEqual('1522', values[3])
        self.assertEqual('tspua8', values[4])

    def test_getaccounts(self):
        fp = FileParser(None, '/tmp/mxcredentials.mxres')
        accounts, amap = fp.getdb_accounts()
        self.assertEqual(3, len(accounts))
        expected_accounts = ['MUREXFO', 'MUREXBO', 'ADMIN']
        expected_accounts.sort()
        accounts.sort()
        self.assertListEqual(expected_accounts, accounts)



if __name__ == '__main__':
    #unittest.main()
    main()


