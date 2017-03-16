# -*- coding: utf-8 -*-
"""
Thrift帮助类, 提供Thrift一些操作辅助.
"""

from thriftpy.protocol import (
    TBinaryProtocolFactory,
    TMultiplexedProtocolFactory,
)
from thriftpy.server import TThreadedServer
from thriftpy.thrift import TProcessor, TMultiplexedProcessor, TClient
from thriftpy.transport import (
    TBufferedTransportFactory,
    TServerSocket,
    TSocket,
)


__all__ = ['ThriftClient', 'create_thrift_server', 'create_multiplexed_server']


def create_thrift_server(service, handler, socket_config,
                         server_cls=TThreadedServer):
    """
    创建Thrift Server对象。
    """
    return server_cls(TProcessor(service, handler),     # processor
                      TServerSocket(**socket_config),   # transport
                      TBufferedTransportFactory(),      # transportFactory
                      TBinaryProtocolFactory())         # protocolFactory


def create_multiplexed_server(services, socket_config,
                              server_cls=TThreadedServer):
    """
    创建多路复用的Thrift Server
    :param services: 多路复用服务定义，如：[(service1, handler1, service_name1),
    (service2, handler2, service_name2),...]
    :param socket_config: Server的socket参数
    :param server_cls: 启动的服务器类型
    :return: Server对象
    """
    processor = TMultiplexedProcessor()
    for service, handler, service_name in services:
        processor.register_processor(service_name, TProcessor(service, handler))

    return server_cls(processor,                        # processor
                      TServerSocket(**socket_config),   # transport
                      TBufferedTransportFactory(),      # transportFactory
                      TBinaryProtocolFactory())         # protocolFactory


class ThriftClient(object):
    """
    Thrift Client类封装。
    """
    def __init__(self, service, socket_config, service_name=None):
        trans_socket = TSocket(**socket_config)
        self.__transport = TBufferedTransportFactory()\
            .get_transport(trans_socket)
        if service_name:
            protocol_factory = TMultiplexedProtocolFactory(
                TBinaryProtocolFactory(), service_name)
        else:
            protocol_factory = TBinaryProtocolFactory()
        protocol = protocol_factory.get_protocol(self.__transport)
        self.__client = TClient(service, protocol)
        self.__is_open = False

    def __del__(self):
        if self.__is_open:
            self.__transport.close()

    def __getattr__(self, item):
        if not self.__is_open:
            self.__transport.open()
            self.__is_open = True
        return getattr(self.__client, item)


class ServiceName(object):
    """
    Alias class that can be used as a decorator for making methods callable
    through other names (or "aliases").
    Note: This decorator must be used inside an @aliased -decorated class.
    For example, if you want to make the method shout() be also callable as
    yell() and scream(), you can use alias like this:

        @ServiceName('yell', 'scream')
        def shout(message):
            # ....
    """

    def __init__(self, *aliases):
        """Constructor."""
        self.aliases = set(aliases)

    def __call__(self, f):
        """
        Method call wrapper. As this decorator has arguments, this method will
        only be called once as a part of the decoration process, receiving only
        one argument: the decorated function ('f'). As a result of this kind of
        decorator, this method must return the callable that will wrap the
        decorated function.
        """
        f._aliases = self.aliases
        return f


def service_handler(aliased_class):
    """
    Decorator function that *must* be used in combination with @alias
    decorator. This class will make the magic happen!
    @aliased classes will have their aliased method (via @alias) actually
    aliased.
    This method simply iterates over the member attributes of 'aliased_class'
    seeking for those which have an '_aliases' attribute and then defines new
    members in the class using those aliases as mere pointer functions to the
    original ones.

    Usage:
        @service_handler
        class MyClass(object):
            @ServiceName('coolMethod', 'myKinkyMethod')
            def boring_method():
                # ...

        i = MyClass()
        i.coolMethod() # equivalent to i.myKinkyMethod() and i.boring_method()
    """
    original_methods = aliased_class.__dict__.copy()
    for name, method in original_methods.iteritems():
        if hasattr(method, '_aliases'):
            # Add the aliases for 'method', but don't override any
            # previously-defined attribute of 'aliased_class'
            for alias in method._aliases - set(original_methods):
                setattr(aliased_class, alias, method)
    return aliased_class
