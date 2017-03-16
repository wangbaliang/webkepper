{% extends 'common/base_layout.tpl' %}
{% block page_style %}
    <style type="text/css">
    .app-header-title {
        padding: 15px 0 10px 10px;
        cursor: default;
        color: #fff;
        font-size: 18px;
        font-weight: bold;
        text-shadow: 0 1px 0 #4e691f;
    }
    .app-header-text {
        margin: 0 10px 0 0;
        cursor: default;
        color: #fff;
        font-size: 16px;
        font-weight: bold;
        text-shadow: 0 1px 0 #4e691f;
        float: right;
    }
    </style>
{% endblock %}
{% block bottom_js %}

<script type="text/javascript">
    Ext.Loader.setConfig({
        enabled: true,
        paths: {
            'Ext.ux': '{{ static('assets/plugins/extjs/ux') }}'
        }
    });
    Ext.require('Ext.ux.NewTabCloseMenu');
    Ext.onReady(function () {

        var store = Ext.create('Ext.data.TreeStore', {
            id: 'treeStore',
            proxy:{
                type: 'ajax',
                url: '{{ url("tree") }}'
            }
        });

        Ext.create('Ext.container.Viewport', {
            layout: 'border',
            requires: [
                'Ext.layout.container.Border'
            ],
            items: [{
                xtype: 'container',
                id: 'app-header',
                region: 'north',
                height: 52,
                layout: {
                    type: 'hbox',
                    align: 'middle'
                },
                items:[{
                    xtype: 'component',
                    id: 'app-header-logo',
                    cls: 'app-header-title',
                    html: '简单科技管理后台',
                    flex: 1
                },{
                    xtype: 'component',
                    id: 'app-header-username',
                    cls: 'app-header-text',
                    html: '{{ user.first_name }}{{ user.last_name }} ({{ user.username }})'
                },{
                    xtype: 'component',
                    cls: 'app-header-text',
                    html: '<a href="{{ url('logout') }}">退出</a>'
                }]
            }, {
                region: 'west',
                frame: false,
                split: true,
                collapsible: true,
                id: 'MainMenu',
                title: '系统导航',
                headerPosition: 'top',
                width: 200,
                minWidth: 100,
                items: [
                    {
                        id: 'my_treepanel',
                        xtype: 'treepanel',
                        border: 0,
                        rootVisible: false,
                        store: store
                    }
                ]
                // could use a TreePanel or AccordionLayout for navigational items
            }, {
                region: 'south',
                collapsible: false,
                html: '2007-2025 &copy; 简单科技.',
                split: false,
                height: 22
            }, {
                region: 'center',
                xtype: 'tabpanel',
                id: 'mainTabPanel',
                items: [
                ],
                plugins: new Ext.create('Ext.ux.NewTabCloseMenu',{
                    closeTabText: '关闭当前标签',
                    closeOthersTabsText: '关闭其他',
                    closeAllTabsText: '关闭所有'
                })
            }]
        });

        bindNavToTab("MainMenu", "mainTabPanel");
    });
    /**
     * 获取
     * @param tree
     * @param tabId
     */
    function bindUrl(tabId, nodes, hash, href){
        var result = false;
        for(var i = 0; i < nodes.length; i++) {
            if(result==false){
                var node = nodes[i];
                if(node.isLeaf()){
                    if(hash){
                        var index = hash.indexOf(node.data.href);
                        if(index==0){
                            if(!href){
                                href = node.data.href;
                            }
                            CreateIframeTab(tabId, "tab_"+node.data.id, node.data.text, href);
                            result = true;
                        }
                    }
                    else{
                        //选择第一个叶子节点，openable=true:首页不可关闭
                        if(!href){
                            href = node.data.href;
                        }
                        CreateIframeTab(tabId, "tab_"+node.data.id, node.data.text, href, true);
                        result = true;
                    }
                }
                else{
                    result = bindUrl(tabId, node.childNodes, hash, href)
                }
             }
             else{
                 break;
             }
         }
        return result;
    }

    function afterBind(tree,tabId){
        //console.log("afterBind");
        tree.on('load', function (tre, records, successful, operation, node, opts) {
            bindUrl(tabId, records, '');

            var remark = window.location.hash;

            if(remark) {
                var href = getPar("next");
                if(href){
                    href = decodeURIComponent(href.replace(remark,''));
                }else{
                   href = remark;
                }
                //console.log(href);
                bindUrl(tabId, records, remark, href);
            }
            else {
                //缺省展示双师小班的课程列表
                bindUrl(tabId, records, '#/nc/course_list');
            }
        });
    }
{#    function findchildnode(node){#}
{#        var childnodes = node.childNodes;#}
{#        for(var i=0;i<childnodes.length;i++){  //从节点中取出子节点依次遍历#}
{#            var rootnode = roonodes[i];#}
{#            //alert(rootnode.text);#}
{#            if(rootnode.childNodes.length>0){  //判断子节点下是否存在子节点#}
{#                findchildnode(rootnode);    //如果存在子节点  递归#}
{#            }#}
{#        }#}
{#    }#}

    function bindNavToTab(accordionId, tabId) {
        //console.log('bindNavToTab开始');
        var accordionPanel = Ext.getCmp(accordionId);
        if (!accordionPanel) return;

        var treeItems = accordionPanel.queryBy(function (cmp) {
            if (cmp && cmp.getXType() === 'treepanel') return true;
            return false;
        });
        if (!treeItems || treeItems.length == 0) return;

        for (var i = 0; i < treeItems.length; i++) {
            var tree = treeItems[i];
            afterBind(tree, tabId);
            tree.on('itemclick', function (view, record, htmlElement, index, event, opts) {

                var href = record.data.href;
                if (!href) return false;

                // 阻止事件传播
                event.stopEvent();
                // 修改地址栏
                window.location.hash = href;
                href = href.replace('#','');
                // 新增Tab节点
                return CreateIframeTab(tabId, "tab_"+record.data.id, record.data.text, href);
            });
        }
        //console.log('bindNavToTab结束.');
    }

    function CreateIframeTab(tabpanelId, tabId, tabTitle, iframeSrc, openable) {
        //console.log('iframeSrc:'+iframeSrc);
        iframeSrc = iframeSrc.replace('#','');
        var tabpanel = Ext.getCmp(tabpanelId);
        if (!tabpanel) return;  //未找到tabpanel，返回
        //寻找id相同的tab
        var tab = Ext.getCmp(tabId);
        var html =  '<iframe id="tab_frame'+tabId+'" name="tab_frame'+tabId+'" style="overflow:auto;' +
                'width:100%; height:100%;" src="' + iframeSrc + '" frameborder="0"></iframe>';

        if (tab) {
            //刷新tab
            //console.log('刷新tab');
            tabpanel.setActiveTab(tab);
            Ext.get(tabId).dom.innerHTML = html;
            return false;
        }
        var closable = true;
        if(openable){
            closable = false;
        }
        //console.log('closable:'+(closable?"1":"0"));
        //新建一个tab，并将其添加到tabpanel中
        tab = tabpanel.add({
            id: tabId,
            title: tabTitle,
            closable: closable,
            html: html
        });
{#        tab.on("show",function(tab, eOpts){#}
{#            if(!tab.isEverActive){#}
{#                tab.isEverActive = 1;#}
{#            }else{#}
{#                tab.isEverActive = 2;#}
{#            }#}
{#        })#}
        tabpanel.setActiveTab(tab);
        return false;
    }
</script>
{% endblock %}
{% block body %}
{% endblock %}
