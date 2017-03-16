<!DOCTYPE html>
<html>
<!-- BEGIN HEAD -->
<head>
<meta charset="utf-8"/>
<title>{% block title %}简单科技网站系统管理后台{% endblock %}</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<meta content="{% block page_description %}{% endblock %}" name="description"/>
<meta content="mars" name="author"/>
<link rel="shortcut icon" type="image/png" href="{{ static('assets/img/favicon.ico') }}"/>
<!-- BEGIN GLOBAL MANDATORY STYLES -->
<!-- END GLOBAL MANDATORY STYLES -->
<!-- BEGIN THEME STYLES -->
<link rel="stylesheet" type="text/css" href="{{ static('assets/plugins/extjs/packages/ext-theme-neptune/build/resources/ext-theme-neptune-all.css') }}" />
<!-- END THEME STYLES -->

{% if debug_mode %}
<script src="{{ static('assets/plugins/extjs/ext-all-debug.js') }}" type="text/javascript"></script>
{% else %}
<script src="{{ static('assets/plugins/extjs/ext-all.js') }}" type="text/javascript"></script>
{% endif %}

<script src="{{ static('assets/plugins/extjs/packages/ext-locale/ext-locale-zh_CN.js') }}" type="text/javascript"></script>
<script src="{{ static('assets/js/common.js') }}" type="text/javascript"></script>

{% block page_style %}{% endblock %}
<script type="text/javascript">
    var WebRoot = "";
</script>
</head>
<!-- BEGIN BODY -->
<body id="body" class="{% block body_class %}{% endblock %}">
{% block body %}{% endblock %}
{% block bottom_js %}{% endblock %}
</body>
<!-- END BODY -->
</html>
