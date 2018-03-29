import kazoo.handlers
from kazoo.client import KazooClient
import os
import re
import time
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

class ZkApiException(Exception):
    pass

class TzKazooClient(KazooClient):
    def __init__(self, servers=['127.0.0.1:2181'], timeout=3):
        for server in servers:
            super(TzKazooClient, self).__init__(server, timeout)
            try:
                self.start(timeout)
                bool = True
            except kazoo.handlers.threading.TimeoutError as e:
                bool = False
                continue
            break
        if not bool:
            self.__error('The zookeeper connection failed!')

    def __create(self, path, value):
        value = value.strip()
        try:
            if self.exists(path):
                data,stat = self.get(path)
                if data != value:
                    print '[UPDATE] %s %s' % (path, value)
                    self.set(path, value)
            else:
                print '[CREATE] %s %s' % (path, value)
                self.create(path, value, makepath=True)
        except Exception as e:
            self.__error(e)

    def push(self, local_dir, top_path='/', with_local_path=False):
        try:
            for root, dirs, files in os.walk(local_dir, onerror=self.__error):
                for name in files:
                    file = os.path.join(root, name)
                    f = open(file)
                    content = f.read()
                    f.close()
                    if not with_local_path:
                        zk_path = '/' + top_path.strip('/') + '/' + file[re.match(local_dir, file).end():].strip('/')
                    else:
                        zk_path = '/' + top_path.strip('/') + '/' + file.strip('/')
                    self.__create(zk_path, content)
        except Exception as e:
            self.__error(e)

    def pull(self, local_dir='/tmp', top_path='/'):
        top_path = '/' + top_path.strip('/')
        childrens = self.get_children(top_path)
        if childrens == []:
            value = self.get(top_path)[0]
            if value == '':
                try:
                    os.makedirs(local_dir + top_path)
                except OSError:
                    pass
            else:
                f = open(local_dir + top_path, 'wb')
                f.write(value)
                f.close()
        else:
            try:
                os.makedirs(local_dir + top_path)
            except OSError:
                pass
            for children_path in childrens:
                self.pull(local_dir, top_path + '/' + children_path)

    def clean(self, top_path, match=None, backup=True):
        try:
            if not match:
                if top_path.strip('/') == '':
                    self.__error('Can not remove the root of all directory!')
                for children in self.get_children(top_path):
                    zk_path = '/' + top_path.strip('/') + '/' + children
                    self.clean_path(zk_path, backup)
            else:
                for children in self.get_children(top_path):
                    if re.match(r'%s' % match, children):
                        zk_path = '/' + top_path.strip('/') + '/' + children
                        self.clean_path(zk_path, backup)
        except Exception as e:
            self.__error(e)

    def clean_path(self, path, backup):
        if backup and not re.match('backup', path.strip('/')):
            print 'backup %s' % path
            self.backup(path)
        print 'delete %s' % path
        self.delete(path, recursive=True)

    def backup(self, top_path, mark=None):
        try:
            if not mark:
                mark = time.strftime('%Y-%m-%d-%H:%M:%S',time.localtime(time.time()))
            if self.get_children(top_path) == []:
                content = self.get(top_path)[0]
                zk_path = '/backup/' + mark + '/' + top_path.strip('/')
                self.__create(zk_path, content)
            else:
                for children in self.get_children(top_path):
                    if children == 'backup':
                        continue
                    children_path = '/' + top_path.strip('/') + '/' + children.strip('/')
                    self.backup(children_path, mark)
                    content = self.get(children_path)[0]
                    zk_path = '/backup/' + mark + children_path
                    self.set(zk_path, content)
        except Exception as e:
            self.__error(e)

    def clean_backup(self):
        try:
            self.delete('/backup', recursive=True)
        except Exception as e:
            self.__error(e)

    def __error(self, err):
        raise ZkApiException(err)

if __name__ == '__main__':
    '''
    zkCli = TzKazooClient(servers=['127.0.0.1:2181'], timeout=3)
    '''
    pass
