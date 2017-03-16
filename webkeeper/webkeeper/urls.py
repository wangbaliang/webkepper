from django.conf.urls import patterns, include, url
from django.contrib import admin
from django.views.generic.base import RedirectView

urlpatterns = patterns(
    '',
    # Examples:
    # url(r'^$', 'webkeeper.views.home', name='home'),
    # url(r'^blog/', include('blog.urls')),

    url(r'^admin/', include(admin.site.urls)),

    url(r'^$', 'common.views.home', name='home'),
    url(r'^index$', 'common.views.welcome', name='index'),
    url(r'^logout$', 'common.views.logout', name='logout'),

    url(r'^ax/login$', 'common.views.login', name='login'),
    url(r'^ax/register$', 'common.views.register', name='register'),

    url(r'^nc/', include('nc.urls')),
    url(r'^tutor/', include('tutor.urls')),
    url(r'^tree$', 'common.views.tree', name='tree'),

)
