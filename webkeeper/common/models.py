# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models
from django.core.urlresolvers import reverse

# Create your models here.


class NavItems(models.Model):
    # _id = models.CharField(max_length=10, unique=True)
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=50, unique=True)
    title = models.CharField(max_length=50)
    icon = models.CharField(max_length=50, blank=True, default='fa-folder-open')
    level = models.SmallIntegerField()
    parent = models.ForeignKey('self', related_name='children', null=True)

    @classmethod
    def get_menu_data(cls):
        top_menus = cls.objects.all().order_by('level')
        length = len(top_menus)
        hash_map = []
        root = []
        for i in xrange(0, length):
            hash_map.append(False)
            # 初始化节点hash表
        for i in xrange(0, length):
            if hash_map[i]:
                continue
            has_son = cls.__has_child(top_menus, i, length)
            node = cls.__to_node(top_menus, i, has_son)  # 当前节点构造完成
            if has_son:  # 如果当前节点不是叶子节点,则从他开始向下探索给他加儿子
                cls.__get_all_its_son(top_menus, node, i, length, hash_map)
                hash_map[i] = True  # 穷搜之后，当前节点断子绝孙
            root.append(node)  # 对当前节点的子孙全添加完之后，加入根
        return root

    # data = [{"id": "001", "text": "detention", "href":'#', "leaf": True }, { "text": "homework", "expanded": True,
    # "children": [{ "id": "002", "text": "book report", "href":'#', "leaf": True }, { "id": "003", "text": "algebra",
    #  "href":'#', "leaf": True}] }, { "id": "004", "text": "buy lottery tickets", "href":'#', "leaf": True}];

    @classmethod
    def __get_all_its_son(cls, root_list, current_node, current_index, length, hash_map):
        son_index = cls.__get_first_child_index_between(root_list, current_index, current_index+1, length) - 1
        # 子索引的起点自减一位开始重新算
        for i in xrange(current_index, length):
            son_index = cls.__get_first_child_index_between(root_list, current_index, son_index+1, length)
            if son_index < 0:  # 如果没有子节点了，则退出
                return
            son_has_son = cls.__has_child(root_list, son_index, length)
            son_node = cls.__to_node(root_list, son_index, son_has_son)
            if son_has_son:  # 如果当前不是叶子节点,则向下深搜，搜完之后，挂在当前节点上
                cls.__get_all_its_son(root_list, son_node, son_index, length, hash_map)
                hash_map[son_index] = True  # 如果联系所有子节点，则当前节点断子绝孙
            else:
                hash_map[son_index] = True  # 如果是叶子节点，则当前节点断子绝孙
            current_node['children'].append(son_node)

    @classmethod
    def __has_child(cls, root_list, current_index, length):
        return cls.__get_first_child_index_between(root_list, current_index, current_index+1, length) >= 0

    @classmethod
    def __get_first_child_index_between(cls, root_list, current_index, start_index, length):
        if current_index == length or current_index < 0:
            return -1  # 如果已经到末尾，则无节点
        else:
            current_id = root_list[current_index].id
            start = start_index
            for i in xrange(start, length):
                if root_list[i].parent_id == current_id:
                    return i
        return -1  # 如果检索了一圈都没有索引号，则无节点

    @classmethod
    def __to_node(cls, root_list, current_index, has_child):
        if not has_child:
            return {
                'id':  root_list[current_index].id,
                'text': root_list[current_index].title,
                'href': "#" + reverse(root_list[current_index].name),
                'leaf': True
            }
        else:
            return{
                'id': root_list[current_index].id,
                'text': root_list[current_index].title,
                "expanded": True,
                'children': []
            }


def nav_items_data(request):
    return {
        'side_nav_data': NavItems.get_menu_data()
    }
