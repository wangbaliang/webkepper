{% extends 'common/base_layout.tpl' %}
{% block title %}双师课堂后台登录{% endblock %}
{% block bottom_js %}
 <script type="text/javascript">
	var win,loginForm;
    //返回json数组
	function getArrayByJson(json) {
		var obj = new Function("return " + json)();
		return obj;
	}
{#    console.log();#}
    //alert(window.location);
    //登录
    function login()
    {
        var form = loginForm.getForm();
		if (form.isValid()) {
			// 验证合法后使用加载进度条
			// 提交到服务器操作
            //alert(Ext.util.Cookies.get("csrftoken"));
			form.submit({
				waitTitle: '请稍等',
				waitMsg: '正在登录...',
				//method : 'get',// 提交方法post或get
				params : {'csrfmiddlewaretoken':Ext.util.Cookies.get("csrftoken")},
				// 提交成功的回调函数
				success : function(form, action) {
					if (action.result.result == 'ok') {
                        location.reload();
                        showProgress("登录成功，请等待跳转...");
					} else {
						Ext.Msg.alert('提示',action.result.message);
					}
                    return false;
				},
				// 提交失败的回调函数
				failure: function(form, action) {
                    if(action.message){
                       Ext.Msg.alert('错误', action.message);
                    }
                    else{
                        Ext.Msg.alert('错误', '登录失败，请重新登录');
                    }
				}
			});
		}
    }

    //在页面加载完成之后执行
	Ext.onReady(function() {
        //var a =  Ext.util.Cookies.get('csrftoken');
        //alert(a);
		//Ext.state.Manager.setProvider(new Ext.state.CookieProvider());
		// 使用表单提示
		Ext.QuickTips.init();
		Ext.form.Field.prototype.msgTarget = 'side';
		// 定义表单
		loginForm =  Ext.create('Ext.form.Panel',{
			//labelAlign : 'top',
            url : '{{ url("login") }}',// 文件路径
            //url: 'https://www.baidu.com//',
			frame : false,
			//monitorValid : true,// 把有formBind:true的按钮和验证绑定
			//id : 'login',
            border : false,
			width : 350,
            bodyPadding: 10,
			// 定义表单元素
			// 指定容器中的元素
			items : [{
				border : false,
				width : 300,
				layout : 'form', // 右边列再分成上下两行
				items : [{
					xtype: 'textfield',
					name: 'username',
					fieldLabel: '用户名',
					allowBlank: false,
					width : 200,
					enableKeyEvents: true,
					// 为空时提示信息
					blankText : '用户名不能为空',
                    listeners : {
                        specialkey: function (field, e) {
                            if (e.getKey() == Ext.EventObject.ENTER) {
                                login();
                            }
                        }
                    }
				}, {
					xtype: 'textfield',
					name: 'password',
					inputType: 'password',
					fieldLabel: '密码',
					allowBlank: false,
					width : 200,
					blankText : '密码不能为空',
					enableKeyEvents: true,
					cls: 'password',
                    listeners : {
                        specialkey: function (field, e) {
                            if (e.getKey() == Ext.EventObject.ENTER) {
                                login();
                            }
                        }
                    }
				}]
			}]
            ,
			buttons : [{
				text : '登录',
				formBind : true,
				type : 'button',
				// 定义表单提交事件
				handler : login
			}, {
				text : '取消',
				handler : function() {
					loginForm.form.reset();
				}// 重置表单
			}]
		});
		// 定义窗体

		// 构建一个窗口面板容器
		win = new Ext.Window({
			// 窗口面板标题
			title : '双师课堂后台管理',
			// 窗口面板宽度
			width : 360,
			// 不容许任意伸缩大小
			resizable : false,
			// 面板是否可以关闭及打开
			collapsible : false,
			// 关闭功能是否可以关闭及打开
			closable: false,
			// 窗体拖拽 默认是TRUE
			draggable : false,
			defaults : {
				// 容器内元素是否显示边框
				border : false
			},
			items : [
				// 指定内部元素所占宽度1表示100% .5表示50%
				//columnWidth : 1,
				// 把表单面板容器增加入其中,使之成为窗口面板容器的子容器
				//items :
				loginForm
			]
		});
		win.show();// 显示窗体
	});
</script>
{% endblock %}