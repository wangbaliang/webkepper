{% extends 'common/base_layout.tpl' %}
{% block title %}调研问卷详细信息{% endblock %}
{% block page_style %}
    <link rel="stylesheet" type="text/css" href="{{ static('assets/plugins/extjs/writer.css') }}" rel="stylesheet" type="text/css"/>
    <script src="{{ static('assets/plugins/extjs/ext/view.js') }}" type="text/javascript"></script>
    <script src="{{ static('assets/js/nc/survey.js') }}" type="text/javascript"></script>
{% endblock %}
{% block bottom_js %}
<script type="text/javascript">
    var titles = {surveyTypeStr:"调研类型",title:"调研标题", state:"发布状态",userName:"发布人", publishTime:"发布时间",
        endTime:"结束时间"};
    if('{{survey_type}}' == "0"){
        titles["count"] = '调研次数';
        titles["surveyCourses"] = '关联班级';
    }
    titles["questionsStr"] = '调研题目';

    Ext.onReady(function () {
        var url = WebRoot + '/nc/ajax/survey_detail/{{survey_type}}/{{survey_id}}';
        var myPanel = createViewPannel(titles, url, '调研问卷详细信息');
        var myView = Ext.create('Ext.container.Viewport', {
            layout: 'anchor',
            items:[myPanel],
            autoScroll:true
         });
{#        var view = createView(titles, url, '调研问卷详细信息');#}
    });

</script>
{% endblock %}
{% block body %}
{% endblock %}